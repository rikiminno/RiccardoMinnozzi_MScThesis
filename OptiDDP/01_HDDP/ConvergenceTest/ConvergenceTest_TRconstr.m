classdef ConvergenceTest_TRconstr < ConvergenceTest
    % specialized class implementing the default convergence test also
    % including the check for the inactive trust region constraint
    %
    % authored by Riccardo Minnozzi, 06/2024

    methods
        function obj = ConvergenceTest_TRconstr(settings, eps_opt, eps_feas, ID)
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
            obj@ConvergenceTest(super_args{:});

        end

        function accepted = checkSolution(obj, problem)
            % function called during the backwards induction to
            % sequentially verify the second order necessary condition for
            % optimality

            % call to superclass method (only includes the
            % positive-definiteness of the hessians)
            accepted = checkSolution@ConvergenceTest(obj, problem);

            % add the check on the trust region radius constraint
            J = problem.J;
            if isprop(J, "uu")

                % compute the unrestricted control update
                if 0 ~= nnz(J.uu), du_unr = J.uu \ (- J.u);
                else du_unr = zeros(size(J.uu, 1), 1); end

                % get the feedforward term and compare
                du = problem.uUpdateLaw.getFeedForwardTerm();
                accepted = accepted && isequal(du, du_unr);

            elseif isprop(J, "wpwp")

                % compute the unrestricted parameter and multiplier updates
                if 0 ~= nnz(J.hat_wpwp), dw_unr = J.hat_wpwp \ (- J.hat_wp');
                else dw_unr = zeros(size(J.hat_wpwp, 1), 1); end
                if 0 ~= nnz(J.lplp), dl_unr = - J.lplp \ J.lp';
                else dl_unr = zeros(size(J.lplp, 1), 1); end

                % get the feed forward terms and compare
                dw = problem.wUpdateLaw.getFeedForwardTerm();
                dl = problem.lUpdateLaw.getFeedForwardTerm();
                accepted = accepted && isequal(dw, dw_unr) && isequal(dl, dl_unr);
            end

        end

    end
end
