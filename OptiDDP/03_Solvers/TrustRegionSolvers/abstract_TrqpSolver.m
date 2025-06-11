classdef abstract_TrqpSolver < handle
    % base class for specialized TRQP further solver implementations
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (Access = protected)
        settings    {mustBeA(settings, 'abstract_AlgorithmConfig')} = AlgorithmConfig()
    end

    properties (SetAccess = protected, GetAccess = public)
        Delta
        eps_1
    end

    methods
        function obj = abstract_TrqpSolver(settings, eps_1, Delta)
            % ABSTRACTTRQPSOLVER constructor

            if nargin > 0
                obj.settings = settings;
                obj.eps_1 = eps_1;
                obj.Delta = Delta;
            end

        end

        function [accepted, rho, Delta] = updateTrustRegionRadius(obj, refIterate, trialIterate)
            % method that performs the trust region acceptance check on the
            % current iterate and returns its accuracy

            % compute iterate quality metric
            rho = (trialIterate.J - refIterate.J)/trialIterate.ER;

            % check if the iterate is acceptable and update the trust
            % region radius accordingly
            Delta = obj.Delta;
            if abs(rho - 1) < obj.eps_1 || ...
                    (rho < 1 + obj.settings.hardCaseEps && trialIterate.ER < 0 ...
                    && rho > 1)
                accepted = true;
                newDelta = min(((1 + obj.settings.kd) * Delta), obj.settings.Delta_max);
            else
                accepted = false;
                newDelta = max(((1 - obj.settings.kd) * Delta), obj.settings.Delta_min);
            end
            obj.Delta = newDelta;

        end

        function obj = setTrustRegionRadius(obj, Delta)
            % function to manually set the trust region radius (to be used
            % as a way to make a full copy of any trust region solver
            % object)

            obj.Delta = Delta;
        end

    end

    methods(Access = protected)

        function [J_a, J_aa] = getProblemModel(~, problem)
            % method that outputs the hessian and gradient for the current
            % sub-problem, depending on the kind of problem being solved

            % retrieve quadratic expansion
            J = problem.J(1);
            if problem.problemToSolve == ProblemVariant.controls
                J_aa    = J.uu;
                J_a     = J.u;
            elseif problem.problemToSolve == ProblemVariant.multipliers
                J_aa    = - J.lplp;
                J_a     = - J.lp;
            elseif problem.problemToSolve == ProblemVariant.parameters
                J_aa    = J.hat_wpwp;
                J_a     = J.hat_wp;
            else
                error(strcat("The TRQP solver has been required to solve a", ...
                    " problem of type:", string(problem.problemToSolve)));
            end

            % transpose gradient to comply with the column vector
            % convention used in the trust region solvers
            J_a = J_a';

        end

        function D = defineScaling(obj, n, currentProblem)
            % default method to retrieve the value of the trust region
            % scaling (identity matrix of size n), can be overridden in
            % specialized trqpSolver implementations

            if isempty(obj.settings.D)
                D = eye(n);
            else
                D = obj.settings.D.(string(currentProblem));
            end
        end

        function updateLaw = buildUpdateLaw(~, problem, da, J_a, J_aa, J_aa_inv)
            % method that builds the update law object from the solution of the trust
            % region subproblem

            % retrieve problem quadratic expansion
            J       = problem.J(1);

            % check which problem to solve and assign the correct update
            % matrices
            if problem.problemToSolve == ProblemVariant.controls
                % retrieve solution
                J_uu_inv= J_aa_inv;
                du      = da;

                % compute the update laws
                A = du;
                B = - J_uu_inv * J.xu';
                C = - J_uu_inv * J.uw;
                D = - J_uu_inv * J.ul;

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

    methods (Abstract)

        % trust region solution method (phase manager input is required to
        % include path constraints)
        [updateLaw, q] = solve(obj, problem, phaseManager)
    end
end

