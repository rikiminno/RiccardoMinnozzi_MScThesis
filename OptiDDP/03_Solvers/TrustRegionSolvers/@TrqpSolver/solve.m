function [updateLaw, q] = solve(obj, problem, phaseManager)
% method to solve the TRQP problem defined by the gradient and hessian
% computed from the quadratic expansion

% set the empty constraint information
q = [];

% get the current problem quadratic model
[J_a, J_aa] = obj.getProblemModel(problem);

% set the scaling matrix
n = size(J_aa, 1);
D = obj.defineScaling(n, problem.problemToSolve);

% adjust the trust region radius to ensure that ||s|| < obj.Delta
Delta = obj.Delta / sqrt(n);

if 0 ~= nnz(J_aa) && all(isfinite(J_aa), 'all') && all(isfinite(J_a), 'all')

    % shift the Hessian by the defined scaling
    J_aa = J_aa + obj.settings.HesShift * eye(n);

    % initialize the solution update
    J_aa_inv = - inv(J_aa);
    da = J_aa_inv * J_a;

    % loop over all components
    for i = 1:n

        % truncate all (scaled) components over the Delta
        if abs(D(i, :) * da) > Delta

            % compute the shift required to truncate the current (scaled)
            % component
            gamma = (Delta - D(i, :) * da) / J_a(i);

            % apply the shift
            J_aa_inv(i, i) = J_aa_inv(i, i) + gamma;

            % invert the sign of the current eigenvalue (if negative)
            if (da(i) * (J_aa_inv(i, :) * J_a)) < 0
                J_aa_inv(i, :) =  - J_aa_inv(i, :);
            end
        end

    end
    % assign the output values
    J_aa = -inv(J_aa_inv);
    J_aa_inv = inv(J_aa);
    da = - J_aa_inv * J_a;

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
else
    % feed-through zeros when partials are null
    J_aa_inv = zeros(size(J_aa));
    da = zeros(size(J_aa, 1), 1);
end

% build the update law output object
updateLaw = obj.buildUpdateLaw(problem, da, J_a, J_aa, J_aa_inv);
end