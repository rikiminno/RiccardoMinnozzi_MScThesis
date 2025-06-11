classdef Phase < abstract_Phase
    % class implementing the specialized phase object for the definition
    % and solution of the backwards induction
    %
    % authored by Riccardo Minnozzi, 06/2024

    methods
        function obj = Phase(ID, phaseManager, settings)
            % PHASE constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = ID;
                super_args{2} = phaseManager;
                super_args{3} = settings;
            end
            obj@abstract_Phase(super_args{:});

        end

        function obj = solve(obj, upstreamJopt, trqpSolver, convergenceTest, previousPhaseManager, xm, wm, lm, sigmam)
            % function that performs the full backwards sweep on the
            % current phase

            % get the number of stages for this phase
            nStages = obj.plant.nStages;

            % initialize convergence acceptance flag and update law objects
            obj.acceptedHessians = true;
            obj.stageUpdates = cell(nStages - 1, 1);

            % perform the backwards induction on all stages
            for k = nStages - 1 : -1 : 1

                % get the point quantities required to instantiate the
                % Stage object
                [t, x, u, w, l] = obj.plant.getPointAtIndex(k);
                [STM, STT] = obj.Phi.getStmsAtIndex(k);

                % set the upstream optimal cost to go
                if k < nStages - 1
                    currentUpstreamJopt = obj.stage.Jopt;
                else
                    currentUpstreamJopt = upstreamJopt;
                end

                % set and solve the stage problem
                obj.stage = feval(obj.settings.version.stage, t, x, u, w, l, STM, STT, [k; obj.ID(2:3)]);
                obj.stage = obj.stage.solve(currentUpstreamJopt, obj.phaseManager, ...
                    trqpSolver);

                % store the stage control update law
                obj.stageUpdates{k} = obj.stage.uUpdateLaw;

                % perform the convergence test
                obj.acceptedHessians = convergenceTest.checkSolution(obj.stage) && ...
                    obj.acceptedHessians;
            end

            % set the interphase problem object
            [t, x, u, w, l] = obj.plant.getPointAtIndex(1);
            obj.interPhase = feval(obj.settings.version.interPhase, t, x, u, w, l, xm, wm, lm, sigmam, ...
                [0; obj.ID(2:3)]);

            % solve the interphase problem
            obj.interPhase = obj.interPhase.solve(obj.phaseManager, ...
                previousPhaseManager, trqpSolver, obj.stage.Jopt);

            % store the resulting control laws
            obj.multiplierUpdate    = obj.interPhase.lUpdateLaw;
            obj.parameterUpdate     = obj.interPhase.wUpdateLaw;

            % perform the convergence test
            obj.acceptedHessians = convergenceTest.checkSolution(obj.interPhase) && ...
                obj.acceptedHessians;
        end

    end
end

