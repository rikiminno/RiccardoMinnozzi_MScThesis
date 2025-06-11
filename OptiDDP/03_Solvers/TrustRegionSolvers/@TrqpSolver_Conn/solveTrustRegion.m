function [da, J_a, J_aa, J_aa_inv] = solveTrustRegion(obj, problem)
% method to solve the trust region subproblem and output only the trust
% region related quantities

% retrieve the problem quadratic model
[J_a, J_aa] = obj.getProblemModel(problem);

% define trust region scaling
n = size(J_aa, 1);
D = obj.defineScaling(n, problem.problemToSolve);
S = inv(D);

% scale quadratic model
J_a = S' * J_a;
J_aa = S' * J_aa * S;

% NOTE: to avoid having terms that become too large, one could also impose
% a lower bound on the positive-definiteness of J_aa (hence setting a
% minimum value for its eigenvalues)

% run the TrqpSolver only if the problem is non-zero and finite
if 0 ~= nnz(J_aa) && all(isfinite(J_aa), 'all') && all(isfinite(J_a), 'all')

    % apply tuned Hessian shift (if any)
    J_aa = J_aa + obj.settings.HesShift * eye(n);

    % set the algorithm naming convention
    H = J_aa;
    g = J_a;
    Delta = obj.Delta;
    n = size(H, 1);

    % initialize the Hessian shift uncertainty interval
    lambda_L = max([0, - min(diag(H)), ...
        norm(g)/Delta - min([obj.initHrowNorm(H, 1), norm(H, "fro"), norm(H, inf)])]);
    lambda_U = max([0, norm(g)/Delta - min(diag(H)), ...
        norm(g)/Delta + min([obj.initHrowNorm(H, -1), norm(H, "fro"), norm(H, inf)])]);

    % check and adjust the extremes if needed
    if lambda_L > lambda_U, lambda_U = lambda_L; end

    % initialize the Hessian shift
    lambda = norm(g) / Delta;
    u = [];
    alpha = [];
    s = [];

    % initialize algorithm iterations
    converged = false;
    iterCount = 1;
    while ~converged && iterCount <= obj.settings.maxIter

        % STEP 1
        H_l = H + lambda * eye(n);
        try
            L = chol(H_l, "lower");
            % STEP 1-a
            s = (L*L') \ (- g);
            if norm(s) < Delta
                % lambda is greater than the solution
                currentSet = "G";
                % check the interior convergence
                converged = obj.checkInteriorConvergence(lambda_L, s, Delta);
                if converged
                    whichCase = "interior";
                    break;
                end
            else
                % lambda is smaller than the foreseen solution
                currentSet = "L";
            end
        catch
            % factorization not successful, the current lambda
            % is not feasible
            currentSet = "N";
        end

        % STEP 2
        % update the uncertainty region bounds
        if currentSet == "G", lambda_U = lambda;
        else, lambda_L = lambda; end

        % STEP 3
        if currentSet == "L" || currentSet == "G"

            % STEP 3-a
            % update the uncertainty region bounds
            w = L \ s;
            if ~all(isfinite(w)), w = zeros(size(w)); end
            % check to avoid division by 0
            if norm(w) ~= 0
                lambda_p = lambda + ((norm(s) - Delta)/ Delta) * ...
                    (norm(s)/norm(w))^2;
            else
                lambda_p = lambda;
            end

            % STEP 3-b
            % use the linpack method to find the model reduction
            if currentSet == "G"
                % i
                u = obj.LINPACK(L);
                % ii
                lambda_L = max(lambda_L, lambda - u' * (H_l * u));
                % iii
                alpha_p = fzero(@(alpha) norm(s + alpha*u) - Delta, [0 2 * Delta]);
                alpha_m = fzero(@(alpha) norm(s + alpha*u) - Delta, [-2 * Delta 0]);
                % only store the alpha solution that corresponds to the
                % lowest quadratic model value
                quadModel = @(step) 0.5 * step' * (H * step) + g' * step;
                if quadModel(s + alpha_p * u) <= quadModel(s + alpha_m * u)
                    alpha = alpha_p;
                else
                    alpha = alpha_m;
                end
                s = s + alpha * u;
            end

        else
            % STEP 3-c
            [delta, v] = obj.partialFactorization(H_l);
            % STEP 3-d
            lambda_L = max(lambda_L, lambda + delta / norm(v));
        end

        % STEP 4
        [converged, whichCase] = obj.checkTerminationCriteria(obj, ...
            s, Delta, currentSet, lambda, H_l, u, alpha);
        if converged, break; end

        % STEP 5
        if currentSet == "L" && ~all(g==0)
            lambda = lambda_p;
            s = obj.computeStep(H, g, lambda);
        elseif currentSet == "G"
            try
                % STEP 5-a
                H_lp = H + lambda_p * eye(n);
                chol(H_lp, "lower");
                lambda = lambda_p;
                s = obj.computeStep(H, g, lambda);
            catch
                % STEP 5-b
                % in this case, lambda_p is in N
                lambda_L = max(lambda_L, lambda_p);
                % check lambda_L for interior convergence
                converged = obj.checkInteriorConvergence(lambda_L, s, Delta);
                if converged
                    whichCase = "interior";
                    break;
                else
                    % update the new lambda using the geometric
                    % mean
                    lambda = max(sqrt(lambda_L * lambda_U), ...
                        lambda_L + obj.settings.theta * abs(lambda_U - lambda_L));
                end
            end
        else
            % update the new lambda using the geometric
            % mean
            lambda = max(sqrt(lambda_L * lambda_U), ...
                lambda_L + obj.settings.theta * (lambda_U - lambda_L));

        end

        % update iterations counter
        iterCount = iterCount + 1;
    end

    % update the Hessian shift according to the convergence
    % case
    if converged
        switch whichCase
            case "easy"
                s = obj.computeStep(H, g, lambda);
            case "hard"
                s = obj.computeStep(H, g, lambda) + alpha * u;
            case "interior"
                lambda = 0;
                s = obj.computeStep(H, g, lambda);
        end

        % store solution values
        J_aa = H + lambda * eye(n);
        if any(eig(J_aa) <= 0), J_aa = zeros(size(H)); end
        da = s;

        % re-scale trust region solution
        J_a = D * J_a;
        J_aa = D' * J_aa * D;
        J_aa_inv = inv(J_aa);
        da = S * da;

        % DEBUGGING (insert here)

    else
        % assign zero solution if no convergence has been reached in the
        % specified number of iterations

        J_aa_inv = zeros(size(J_aa));
        da = zeros(size(J_aa, 1), 1);
    end

    % if only the gradient is non-zero and finite, set the step along the
    % gradient with magnitude Delta
elseif 0 ~= nnz(J_a) && all(isfinite(J_a), 'all') && all(isfinite(J_a), 'all')

    % compute the trust region step from a line search
    Delta = obj.Delta;
    alpha = Delta/norm(J_a);

    % check and assign solution
    linModel = @(s) J_a' * s;
    da = alpha .* J_a;
    if linModel(da) > linModel(- da), da = - da; end
    J_aa_inv = zeros(size(J_aa));
    J_aa = zeros(size(J_aa));

else
    % just return a full zeros matrix when the update is null
    J_aa_inv = zeros(size(J_aa));
    J_aa = zeros(size(J_aa));
    J_a = zeros(size(J_aa, 1), 1);
    da = zeros(size(J_aa, 1), 1);
end

% assign trqp solution (reject non-finite solutions)
if ~all(isfinite(J_aa), 'all') || ~all(isfinite(da), 'all') || ...
        ~all(isfinite(J_aa_inv), 'all') || ~all(isfinite(J_a), 'all')
    J_aa = zeros(size(J_aa));
    J_aa_inv = zeros(size(J_aa));
    J_a = zeros(size(J_aa, 1), 1);
    da = zeros(size(J_aa, 1), 1);
end

end

