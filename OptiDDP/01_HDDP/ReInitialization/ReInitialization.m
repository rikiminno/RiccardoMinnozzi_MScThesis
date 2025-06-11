classdef ReInitialization < abstract_ReInitialization
    % default HDDP reinitialization class, implementing the required
    % methods and properties to perform the algorithm reinitialization
    % after trust region stagnation points or before defining complete
    % convergence
    %
    % authored by Riccardo Minnozzi, 10/2024

    properties (Access = protected)
        % eps_1 and Delta values registered before a softFail
        eps1_before_fail

        % eps_1 and Delta values that correspond to the closest quadratic
        % approximation to the required eps_1 value
        best_eps_1
        best_Delta
        best_rho
    end

    methods
        function obj = ReInitialization(settings)
            %REINITIALIZATION Constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = settings;
            end
            obj@abstract_ReInitialization(super_args{:});
        end

        function stopNow = checkEarlyTermination(obj, refIterate)
            % method implementing the early termination check (and setting
            % the corresponding stopping condition) to terminate the trust
            % region procedure early

            % store the best quadratic approximation
            if ~isempty(obj.best_rho)

                % if the current iterate rho is closer to 1, store the
                % current quantities instead
                if abs(1 - obj.best_rho) > abs(1 - refIterate.rho)
                    obj.best_rho = refIterate.rho;
                    obj.best_eps_1 = abs(1 - refIterate.rho);
                    obj.best_Delta = refIterate.Delta;
                end
            else
                % if no iterate has been stored, store the current one
                obj.best_rho = refIterate.rho;
                obj.best_eps_1 = refIterate.eps_1;
                obj.best_Delta = refIterate.Delta;
            end

            % check the trust region radius size and numerical stability of
            % the ER
            TRradiusLimit = refIterate.ER < 1.5 * eps && ...
                refIterate.Delta <= obj.settings.Delta_min;

            % check the run time
            runTimeLimit = toc > obj.settings.maxRunTime;

            % assign output
            stopNow = runTimeLimit || TRradiusLimit;

            % TODO: improve the stopping condition check, since right now
            % it does not carry the softFail across consecutive
            % reinitializations
            % TODO: also improve the check for convergence/need for early
            % stopping when the expected reduction goes below machine
            % precision

            % set the stopping condition
            if runTimeLimit || ...
                    (TRradiusLimit && obj.stoppingCondition == StoppingCondition.softFail)
                obj.stoppingCondition = StoppingCondition.hardFail;
            elseif TRradiusLimit && obj.stoppingCondition ~= StoppingCondition.softFail
                obj.stoppingCondition = StoppingCondition.softFail;
            else
                obj.stoppingCondition = StoppingCondition.none;
            end
        end

        function obj = perform(obj, refIterate, trqpSolver, converged)
            % method that re-initializes the tolerance values for the
            % current iterate

            % if convergence has been achieved increase the iterCount and
            % update the stopping condition
            if converged && obj.stoppingCondition ~= StoppingCondition.hardFail
                obj.iterCount = obj.iterCount + 1;
                obj.stoppingCondition = StoppingCondition.softSuccess;
            end

            % check whether this should be accepted as the final iteration
            maxIterReached = obj.iterCount >= obj.settings.maxIter;
            maxEps1Reached = obj.eps_1 >= obj.settings.eps_1_max;
            if obj.stoppingCondition ~= StoppingCondition.hardFail && ...
                    (maxIterReached || (maxEps1Reached && converged))
                obj.stoppingCondition = StoppingCondition.hardSuccess;
            elseif obj.stoppingCondition == StoppingCondition.softFail && ...
                    (maxIterReached || maxEps1Reached)
                obj.stoppingCondition = StoppingCondition.hardFail;
            end

            % compute the new tolerance values based on the object stopping
            % condition
            obj.Delta = obj.reInitDelta(trqpSolver);
            obj.eps_1 = obj.reInitEps1(refIterate);
            obj.eps_opt = obj.reInitEpsOpt(refIterate);
            obj.eps_feas = obj.reInitEpsFeas(refIterate);

            % reset the best quadratic approximation values for the next
            % iterations
            obj.best_Delta = [];
            obj.best_eps_1 = [];
            obj.best_rho = [];
        end

    end

    methods(Access = protected)

        function eps_1 = reInitEps1(obj, refIterate)
            % method that determines the new value for the eps_1 tolerance

            % if the backwards induction hasn't started, keep the default
            % value
            if isempty(refIterate.ER)
                eps_1 = obj.settings.eps_1;
            else
                % during the backwards induction, update the eps_1 based on
                % the stopping condition
                switch obj.stoppingCondition
                    case StoppingCondition.softFail
                        % use the best_eps_1 stored during the
                        % earlyTermination check (and add a safety factor)
                        eps_1 = min(obj.best_eps_1 * (1 + obj.settings.kd), ...
                            obj.settings.eps_1_max);

                        % empty the values to enable the next iteration
                        obj.best_eps_1 = [];
                        obj.best_rho = [];

                        % store the current eps_1 to be restored at the
                        % next iteration
                        obj.eps1_before_fail = obj.eps_1;

                    case StoppingCondition.softSuccess
                        % increase the eps_1 to allow better exploration of
                        % the current minimum
                        eps_1 = min(obj.eps_1 * obj.settings.kEps_1, ...
                            obj.settings.eps_1_max);

                    case StoppingCondition.none
                        % if no reinitialization is required, keep the
                        % eps_1 the same unless the previous iteration was
                        % a soft fail

                        % reset the eps_1 if needed and empty the
                        % before_fail value
                        if ~isempty(obj.eps1_before_fail)
                            eps_1 = obj.eps1_before_fail;
                            obj.eps1_before_fail = [];
                        else
                            eps_1 = obj.eps_1;
                        end

                        % set the previous value of eps_1 in any other case
                    case StoppingCondition.hardSuccess
                        eps_1 = obj.eps_1;
                    case StoppingCondition.hardFail
                        eps_1 = obj.eps_1;
                end
            end

            % clamp the eps_1 again to be sure
            eps_1 = min(eps_1, obj.settings.eps_1_max);
        end

        function eps_feas = reInitEpsFeas(obj, refIterate)
            % method that determines the new value for eps_feas tolerance

            % keep the constraint tolerance constant
            eps_feas = obj.settings.eps_feas;
        end

        function eps_opt = reInitEpsOpt(obj, refIterate)
            % method that determines the new value for eps_opt tolerance

            eps_opt = obj.settings.eps_opt;
        end

        function Delta = reInitDelta(obj, trqpSolver)
            % method that determines the new value for the trust region
            % radius

            % assign the trust region radius for the start of the algorithm
            if isempty(trqpSolver.Delta)
                Delta = obj.settings.Delta_0;

            else
                % check the different stopping conditions
                switch obj.stoppingCondition
                    case StoppingCondition.none
                        % no stopping criterion has been encountered, so
                        % use the regular radius defined for the solver
                        Delta = trqpSolver.Delta;

                    case StoppingCondition.softFail
                        % use the best Delta registered during the
                        % earlyTermination check
                        Delta = obj.best_Delta;

                        % empty the value to be used for next iteration
                        obj.best_Delta = [];

                    case StoppingCondition.softSuccess
                        % restart the algorithm using the Delta_0
                        Delta = obj.settings.Delta_0;

                    case {StoppingCondition.hardFail, StoppingCondition.hardSuccess}
                        % in case of a hard stop, use the current Delta
                        % value
                        Delta = trqpSolver.Delta;
                end

            end
        end
    end

end

