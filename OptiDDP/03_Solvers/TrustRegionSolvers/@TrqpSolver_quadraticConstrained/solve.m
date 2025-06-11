function [updateLaw, q] = solve(obj, problem, phaseManager)
% function that solves the current problem for the quadratic update law
% that satisfies the defined constraints

% solve the unconstrained trust region problem using the Conn solver
Conn_solver = TrqpSolver_Conn(obj.settings, obj.eps_1, obj.Delta);
Conn_solver = Conn_solver.setTrustRegionRadius(obj.Delta);
[da, J_a, J_aa, J_aa_inv] = Conn_solver.solveTrustRegion(problem);

% in case of parameters or multipliers build the linear update law
if problem.problemToSolve ~= ProblemVariant.controls
    updateLaw = obj.buildUpdateLaw(problem, da, J_a, J_aa, J_aa_inv);
    q = [];

    % in case of controls solve the full constrained problem
else

    % TODO: in the case of constraints being violated by a lot, the current
    % trust region radius may be too strict to allow the control update to
    % satisfy the constraints again, therefore the procedure for trust
    % region radius relaxation found in " FULLY STOCHASTIC TRUST-REGION
    % SEQUENTIAL QUADRATIC PROGRAMMING FOR EQUALITY-CONSTRAINED
    % OPTIMIZATION PROBLEMS" should be implemented

    % estimate the active set and compute the related values and partials
    [q, nEq] = obj.estimateActiveSet(problem, phaseManager, da);

    % only solve the constrained problem if there are active constraints
    if ~isempty(q)
        J = problem.J;

        % SOLVE THE KKT CONDITIONS
        [nx, nu, nw, nl, ~, ~] = phaseManager.getInputSizes();

        %  - FEED FORWARD TERMS

        % assemble extra inputs
        extraParams = [];
        extraParams.q = q;
        extraParams.J_u = J_a;
        extraParams.J_uu = J_aa;
        extraParams.nu = nu;
        extraParams.nEq = nEq;
        extraParams.Delta = Delta;

        % solve equation and rebuild outputs
        options = optimoptions('fsolve', 'Algorithm', 'levenberg-marquardt', ...
            'FunctionTolerance', obj.settings.eps_path_feas, 'Display', 'off');
        FF = fsolve(@(x) feed_forward(x, extraParams), zeros(nu + nEq, 1), options);
        du_0 = FF(1 : nu, 1);
        Lambda = FF(nu + 1 : nu + nEq, 1);

        % - FEEDBACK TERMS

        % initializations
        U_x = zeros(nu, nx);
        U_w = zeros(nu, nw);
        U_l = zeros(nu, nl);
        Lambda_x = zeros(nEq, nx);
        Lambda_w = zeros(nEq, nw);
        Lambda_l = zeros(nEq, nl);
        U_xx = zeros(nu, nx, nx);
        Lambda_xx = zeros(nEq, nx, nx);
        U_ww = zeros(nu, nw, nw);
        Lambda_ww = zeros(nEq, nw, nw);
        U_ll = zeros(nu, nl, nl);
        Lambda_ll = zeros(nEq, nl, nl);
        U_xw = zeros(nu, nx, nw);
        U_wx = zeros(nu, nw, nx);
        Lambda_xw = zeros(nEq, nx, nw);
        Lambda_wx = zeros(nEq, nw, nx);
        U_xl = zeros(nu, nx, nl);
        U_lx = zeros(nu, nl, nx);
        Lambda_xl = zeros(nEq, nx, nl);
        Lambda_lx = zeros(nEq, nl, nx);
        U_wl = zeros(nu, nw, nl);
        U_lw = zeros(nu, nl, nw);
        Lambda_wl = zeros(nEq, nw, nl);
        Lambda_lw = zeros(nEq, nl ,nw);

        % only set the partials if the path constraints are reasonably
        % satisfied (BYPASSED)
        for p = 1 : length(q), viol(p) = q.y; end
        if max(abs(viol)) < obj.settings.eps_path_feas || true

            % define the M and H matrices using the solved Lambda and du_0
            M = zeros(nu + nEq, nu + nEq);
            H = zeros(nu + nEq, nu + nEq);
            M(1 : nu, 1 : nu) = J_aa;
            for i = 1 : nEq
                M(nu + i, 1 : nu) = q(i).u;
                M(1 : nu, nu + i) = q(i).u';
                H(1 : nu, 1 : nu) = H(1 : nu, 1 : nu) + Lambda(i, 1) * q(i).uu;
                H(nu + i, 1 : nu) = du_0' * q(i).uu;
                H(1 : nu, nu + i) = q(i).uu * du_0;
            end
            invMat = inv(M + H);
            if any(~isfinite(invMat), "all"), invMat = zeros(size(invMat)); end

            % -- FIRST ORDER FEEDBACK

            % assemble the constant terms
            a_x = zeros(nu + nEq, nx);
            b_x = zeros(nu + nEq, nx);
            a_w = zeros(nu + nEq, nw);
            b_w = zeros(nu + nEq, nw);
            a_l = zeros(nu + nEq, nl);
            a_x(1 : nu, 1 : nx) = J.ux;
            a_w(1 : nu, 1 : nw) = J.uw;
            a_l(1 : nu, 1 : nl) = J.ul;
            for i = 1 : nEq
                a_x(nu + i, 1 : nx) = q(i).x;
                a_w(nu + i, 1 : nw) = q(i).w;
                b_x(1 : nu, 1 : nx) = b_x(1 : nu, 1 : nx) + Lambda(i, 1) * q(i).ux;
                b_x(nu + i, 1 : nx) = du_0' * q(i).ux;
                b_w(1 : nu, 1 : nw) = b_w(1 : nu, 1 : nw) + Lambda(i, 1) * q(i).uw;
                b_w(nu + i, 1 : nw) = du_0' * q(i).uw;
            end

            % solve for U_x
            sol_x = - invMat * (a_x + b_x);
            U_x = sol_x(1 : nu, 1 : nx);
            Lambda_x = sol_x(nu + 1 : nu + nEq, 1 : nx);

            % solve for U_w
            sol_w = - invMat * (a_w + b_w);
            U_w = sol_w(1 : nu, 1 : nw);
            Lambda_w = sol_w(nu + 1 : nu + nEq, 1 : nw);

            % solve for U_l
            sol_l = - invMat * a_l;
            U_l = sol_l(1 : nu, 1 : nl);
            Lambda_l = sol_l(nu + 1 : nu + nEq, 1 : nl);

            % -- SECOND ORDER FEEDBACK

            % loop over each component of the state
            for j = 1 : nx

                % initialize constant terms
                a_xx = zeros(nu + nEq, nx);
                a_xw = zeros(nu + nEq, nw);
                a_xl = zeros(nu + nEq, nl);

                % assemble constant terms
                for i = 1 : nEq
                    a_xx(1 : nu, 1 : nx) = a_xx(1 : nu, 1 : nx) + 2 * Lambda_x(i, j) * ...
                        (q(i).ux + q(i).uu * U_x);
                    a_xx(nu + i, 1 : nx) = U_x(1 : nu, j)' * q(i).ux + ...
                        q(i).xu(j, 1: nu) * U_x + q(i).xx(j, 1 : nx) + ...
                        U_x(1 : nu, j)' * q(i).uu * U_x;

                    a_xw(1 : nu, 1 : nw) = a_xw(1 : nu, 1 : nw) + 2 * Lambda_x(i, j) * ...
                        (q(i).uw + q(i).uu * U_w);
                    a_xw(nu + i, 1 : nw) = U_x(1 : nu, j)' * q(i).uw + ...
                        q(i).xu(j, 1: nu) * U_w + q(i).xw(j, 1 : nw) + ...
                        U_x(1 : nu, j)' * q(i).uu * U_w;

                    a_xl(1 : nu, 1 : nl) = a_xl(1 : nu, 1 : nl) + 2 * Lambda_x(i, j) * ...
                        (q(i).uu * U_l);
                end

                % solve for U_xx
                sol_xx = - invMat * a_xx;
                U_xx(1 : nu, j, 1 : nx) = sol_xx(1 : nu, 1 : nx);
                Lambda_xx(1 : nEq, j, 1 : nx) = sol_xx(nu + 1 : nu + nEq, 1 : nx);

                % solve for U_xw
                sol_xw = - invMat * a_xw;
                U_xw(1 : nu, j, 1 : nw) = sol_xw(1 : nu, 1 : nw);
                Lambda_xw(1 : nEq, j, 1 : nw) = sol_xw(nu + 1 : nu + nEq, 1 : nw);

                % solve for U_xl
                sol_xl = - invMat * a_xl;
                U_xl(1 : nu, j, 1 : nl) = sol_xl(1 : nu, 1 : nl);
                Lambda_xl(1 : nEq, j, 1 : nl) = sol_xl(nu + 1 : nu + nEq, 1 : nl);
            end

            % loop over each component of the parameters
            for j = 1 : nw

                % initialize constant terms
                a_ww = zeros(nu + nEq, nw);
                a_wx = zeros(nu + nEq, nx);
                a_wl = zeros(nu + nEq, nl);

                % assemble constant terms
                for i = 1 : nEq
                    a_ww(1 : nu, 1 : nw) = a_ww(1 : nu, 1 : nw) + 2 * Lambda_w(i, j) * ...
                        (q(i).uw + q(i).uu * U_w);
                    a_ww(nu + i, 1 : nw) = U_w(1 : nu, j)' * q(i).uw + ...
                        q(i).wu(j, 1: nu) * U_w + q(i).ww(j, 1 : nw) + ...
                        U_w(1 : nu, j)' * q(i).uu * U_w;

                    a_wx(1 : nu, 1 : nx) = a_wx(1 : nu, 1 : nx) + 2 * Lambda_w(i, j) * ...
                        (q(i).ux + q(i).uu * U_x);
                    a_wx(nu + i, 1 : nx) = U_w(1 : nu, j)' * q(i).ux + ...
                        q(i).wu(j, 1: nu) * U_x + q(i).wx(j, 1 : nx) + ...
                        U_w(1 : nu, j)' * q(i).uu * U_x;

                    a_wl(1 : nu, 1 : nl) = a_wl(1 : nu, 1 : nl) + 2 * Lambda_w(i, j) * ...
                        (q(i).uu * U_l);
                end

                % solve for U_ww
                sol_ww = - invMat * a_ww;
                U_ww(1 : nu, j, 1 : nw) = sol_ww(1 : nu, 1 : nw);
                Lambda_ww(1 : nEq, j, 1 : nw) = sol_ww(nu + 1 : nu + nEq, 1 : nw);

                % solve for U_wx
                sol_wx = - invMat * a_wx;
                U_wx(1 : nu, j, 1 : nx) = sol_wx(1 : nu, 1 : nx);
                Lambda_wx(1 : nEq, j, 1 : nx) = sol_wx(nu + 1 : nu + nEq, 1 : nx);

                % solve for U_wl
                sol_wl = - invMat * a_wl;
                U_wl(1 : nu, j, 1 : nl) = sol_wl(1 : nu, 1 : nl);
                Lambda_wl(1 : nEq, j, 1 : nl) = sol_wl(nu + 1 : nu + nEq, 1 : nl);
            end

            % loop over each component of the multipliers
            for j = 1 : nl

                % initialize constant terms
                a_ll = zeros(nu + nEq, nl);
                a_lx = zeros(nu + nEq, nx);
                a_lw = zeros(nu + nEq, nw);

                % assemble constant terms
                for i = 1 : nEq
                    a_ll(1 : nu, 1 : nl) = a_ll(1 : nu, 1 : nl) + 2 * Lambda_l(i, j) * ...
                        (q(i).uu * U_l);

                    a_lx(1 : nu, 1 : nx) = a_lx(1 : nu, 1 : nx) + 2 * Lambda_l(i, j) * ...
                        (q(i).uu * U_x);

                    a_lw(1 : nu, 1 : nw) = a_lw(1 : nu, 1 : nw) + 2 * Lambda_l(i, j) * ...
                        (q(i).uu * U_w);
                end

                % solve for U_ll
                sol_ll = - invMat * a_ll;
                U_ll(1 : nu, j, 1 : nl) = sol_ll(1 : nu, 1 : nl);
                Lambda_ll(1 : nEq, j, 1 : nl) = sol_ll(nu + 1 : nu + nEq, 1 : nl);

                % solve for U_lx
                sol_lx = - invMat * a_lx;
                U_lx(1 : nu, j, 1 : nx) = sol_lx(1 : nu, 1 : nx);
                Lambda_lx(1 : nEq, j, 1 : nx) = sol_lx(nu + 1 : nu + nEq, 1 : nx);

                % solve for U_lw
                sol_lw = - invMat * a_lw;
                U_lw(1 : nu, j, 1 : nw) = sol_lw(1 : nu, 1 : nw);
                Lambda_lw(1 : nEq, j, 1 : nw) = sol_lw(nu + 1 : nu + nEq, 1 : nw);
            end
        end

        % % DEBUGGING CONDITION (might be incorrect)
        % if 0 ~= nnz(U_lw - permute(U_wl, [1, 3, 2])) || ...
        %         0 ~= nnz(U_xw - permute(U_wx, [1, 3, 2])) || ... 0 ~=
        %         nnz(U_lx - permute(U_xl, [1, 3, 2]))
        %     error("In the quadratic constrained trust region solver, the " +  ...
        %         "computed second order update laws do not respect the symmetric " + ...
        %         "derivative assumption (i.e. U_ab ~= U_ba').");
        % end

        % NOTE: there is an alternative way to perform the trust region
        % procedure, where the reduced Hessian is computed and used to
        % solve an "unconstrained" trust region step (only on the free
        % control components) while the constrained components of the
        % controls are kept fixed on the bound using a feedback law. In the
        % HDDP paper (2), this method is suggested and explained (also
        % mentioning that it only works for control bounds, hence linear)

        % assemble the quadratic constrained update law
        updateLaw = QuadraticUpdateLaw(du_0, U_x, U_w, U_l, U_xx, U_xw, U_xl, ...
            U_ww, U_wl, U_ll, problem.problemToSolve);
    else
        updateLaw = obj.buildUpdateLaw(problem, da, J_a, J_aa, J_aa_inv);
    end
end
end


function err = feed_forward(ff_in, extraParams)
% error equation for the definition of the feed forward terms

% initialize terms
b_loc = zeros(extraParams.nu + extraParams.nEq, 1);
M_loc = zeros(extraParams.nu + extraParams.nEq, extraParams.nu + extraParams.nEq);
H_loc = zeros(extraParams.nu + extraParams.nEq, extraParams.nu + extraParams.nEq);

% retrieve inputs
du_loc = ff_in(1 : extraParams.nu, 1);
L_loc = ff_in(extraParams.nu + 1 : extraParams.nu + extraParams.nEq, 1);

% assemble terms
b_loc(1 : extraParams.nu) = extraParams.J_u';
M_loc(1 : extraParams.nu, 1 : extraParams.nu) = extraParams.J_uu;
for i_loc = 1 : extraParams.nEq
    b_loc(extraParams.nu + i_loc, 1) = extraParams.q(i_loc).y;
    M_loc(extraParams.nu + i_loc, 1 : extraParams.nu) = extraParams.q(i_loc).u;
    M_loc(1 : extraParams.nu, extraParams.nu + i_loc) = extraParams.q(i_loc).u';
    H_loc(1 : extraParams.nu, 1 : extraParams.nu) = H_loc(1 : extraParams.nu, 1 : extraParams.nu) + L_loc(i_loc, 1) * extraParams.q(i_loc).uu;
    H_loc(extraParams.nu + i_loc, 1 : extraParams.nu) = du_loc' * extraParams.q(i_loc).uu;
    H_loc(1 : extraParams.nu, extraParams.nu + i_loc) = extraParams.q(i_loc).uu * du_loc;
end
% assemble the full equation
err = b_loc + (M_loc + 0.5 * H_loc) * ff_in(1 : extraParams.nu + extraParams.nEq, 1);

% append trust region constraint
err = [err; norm(du_loc) - extraParams.Delta];
end

% To estimate the active set of constraints, use the Conn trust region
% solver and retrieve its A (= du_0). Use this d_u to compute the active
% constraints.
%
% Solve the quadratic constrained problem using the equations derived on
% paper and a slack variable method for the inequality constraints.
%
% In particular, the first non-linear coupled system of equations (for the
% solution of du_0, and if required also s, and Lambda) should be solved
% using MATLAB's fsolve

% NOTE: append the trust region radius constraint to the inequality
% constraints (estimate if it is active by computing the unrestricted du_0
% and comparing it to the obj.Delta). ALTERNATIVE: use the already shifted
% J_uu coming from an unconstrained trqp solver as the problem Hessian,
% instead of appending the trust region constraint

% NOTE: the path constraints need to be explicitly dependent on the
% controls for this approach to work. If there is no explicit dependance,
% the controls can always be integrated into the path constraints
% formulation by using the dynamics transition function x_{next} = F(t, x,
% u, w) to explicitly relate the control with the state

% NOTE: When solving the slack-variables system (if inequality constraints
% are present), the slack variable is added to the cost function using a
% logarithmic barrier function, and is then treated like any
% (unconstrained) control component (therefore it is appended to the du_0,
% which becomes [du_0; s]). The slack variables do not enter the other
% linear systems defined to compute the U_x, U_xx, U_w, U_l, etc etc. For
% more information check the book on Numerical Optimization, page 444 (424)
% The slack variables, if any, need to be added to the corresponding
% inequality constraint values in the first column vector that appears in
% the KKT system as [J_u; q^1; ...; q^m]. ALTERNATIVE: assuming that every
% point is always feasible (interior point assumption), the slack variables
% can be directly introduced into the non-linear system of equations and
% solved for together with the du_0 and Lambda terms (the positivity
% condition is enforced by adding the squared slack variables to each
% inequality constraint, while the uniqueness of the optimal slack
% variables doesn't need to be enforced since MATLAB fsolve is a local
% solver)

