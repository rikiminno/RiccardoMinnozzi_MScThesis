classdef TrqpSolver_ConnSafeguarded < TrqpSolver_Conn
    % class defining the TRQP solver defined in Conn (algorithm 7.3.4) with
    % extra safeguards
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (Access = protected)

        stateVariations
    end

    methods
        function obj = TrqpSolver_ConnSafeguarded(settings, eps_1, Delta)
            % TRQPSOLVER_CONN constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = settings;
                super_args{2} = eps_1;
                super_args{3} = Delta;
            end
            obj@TrqpSolver_Conn(super_args{:});

        end

        function [updateLaw, q] = solve(obj, problem, phaseManager)
            % full solution method

            % set the empty constraints information
            q = [];

            % solve the trust region subproblem
            [da, J_a, J_aa, J_aa_inv] = obj.solveTrustRegion(problem);

            % build the update law output object with additional safeguard
            J       = problem.J(1);

            % check which problem to solve and assign the correct update
            % matrices
            if problem.problemToSolve == ProblemVariant.controls
                % retrieve solution
                J_uu_inv= J_aa_inv;
                du      = da;
                % nu      = length(du);
                % [STM, STT] = problem.getStateTransitionMaps();
                % nX      = size(STM, 1);
                % dX      = STM * (STM * [zeros(nX - nu, 1); du]);

                % compute the update laws
                A = du;
                B = - J_uu_inv * J.xu';
                C = - J_uu_inv * J.uw;
                D = - J_uu_inv * J.ul;

                % apply safeguard
                if norm(A) ~= 0
                    B = (obj.settings.eta1 * norm(A)) / ...
                        max(obj.settings.eta1 * norm(A), norm(B)) .* B;
                end

            elseif problem.problemToSolve == ProblemVariant.multipliers
                % retrieve solution
                J_lplp_inv  = J_aa_inv;
                dl          = da;

                % compute the update laws
                A = dl;
                B = [];
                C = J_lplp_inv * J.t_lpwp;
                D = [];

            elseif problem.problemToSolve == ProblemVariant.parameters
                % retrieve solution
                J_wpwp_inv  = J_aa_inv;
                dw          = da;
                dw = 0;
                J_wpwp_inv = 0;

                % compute the update laws
                A = dw;
                B = - J_wpwp_inv * J.hat_wpxm;
                C = - J_wpwp_inv * J.hat_wpwm;
                D = - J_wpwp_inv * J.hat_wplm;

            else
                error(strcat("The TRQP solver has been required to solve a", ...
                    " problem of type: ", string(problem.problemToSolve), ...
                    ", which is not supported."));
            end

            % assemble update law
            updateLaw = UpdateLaw(A, B, C, D, problem.problemToSolve);

        end

    end
end
