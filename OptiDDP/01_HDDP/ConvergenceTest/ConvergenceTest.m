classdef ConvergenceTest < abstract_ConvergenceTest
    % specialized class implementing a convergence test
    %
    % authored by Riccardo Minnozzi, 06/2024

    methods
        function obj = ConvergenceTest(settings, eps_opt, eps_feas, ID)
            % CONVERGENCETEST constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = settings;
                super_args{2} = eps_opt;
                super_args{3} = eps_feas;
                super_args{4} = ID;
            end
            obj@abstract_ConvergenceTest(super_args{:});

        end

        function converged = perform(obj, trialIterate)
            % method implementing the actual convergence check (or the
            % premature interruption due to runtime constraints)

            % solution convergence
            converged = (- trialIterate.ER < obj.eps_opt && trialIterate.ER < 0) && ...
                trialIterate.f < obj.eps_feas && ...
                trialIterate.maxPathConstraintViolation < obj.settings.eps_path_feas && ...
                trialIterate.acceptedHessians;

        end

        function accepted = checkSolution(obj, problem)
            % function called during the backwards induction to
            % sequentially verify the second order necessary condition for
            % optimality

            J = problem.J(1);
            if isprop(J, "uu")

                % check if there are active constraints
                H = J.uu;
                if ~isempty(problem.q)
                    % assemble the constraints Jacobian
                    m = length(problem.q);
                    n = size(H, 2);
                    Jac = zeros(m, n);
                    for i = 1 : m, Jac(i, :) = problem.q(i).u; end

                    % compute the null space of the constraints
                    Z = null(Jac);

                    % compute the reduced hessian
                    H = Z' * H * Z;
                end
                accepted = checkSingleHessian(H);

            elseif isprop(J, "wpwp")

                % check if there are active constraints
                H = J.wpwp;
                if ~isempty(problem.q)
                    % assemble the constraints Jacobian
                    m = length(problem.q);
                    n = size(H, 2);
                    Jac = zeros(m, n);
                    for i = 1 : m, Jac(i, :) = problem.q(i).w; end

                    % compute the null space of the constraints
                    Z = null(Jac);

                    % compute the reduced hessian
                    H = Z' * H * Z;
                end
                accepted = checkSingleHessian(H);

                % also check the multipliers hessian
                accepted = accepted && checkSingleHessian(-J.lplp');

            end

            function acc = checkSingleHessian(H)
                % function that checks the positive-definiteness of a
                % single hessian matrix

                % check that the matrix is non identically zero
                if ~(0 == nnz(H))
                    % % check positive-definite by attempting a cholesky
                    % % factorization
                    % try chol(H);
                    %     acc = true;
                    % catch
                    %     acc = false;
                    % end
                    d = eig(H);
                    acc = all(d > 0);
                else
                    % if identically zero, accept it without checking the
                    % cholesky factorization (useful when static parameters
                    % are not part of the problem definition)
                    acc = true;
                end

                % d = eig(trqpSolution.J_aa);
                % accepted = all(d >= 0);

                % NOTE: this technique is more efficient but does not allow for
                % positive semi-definite matrices
                % try chol(trqpSolution.J_aa);
                %     accepted = true;
                % catch
                %     accepted = false;
                % end
            end

        end

    end
end
