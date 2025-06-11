classdef BackwardsInduction < abstract_BackwardsInduction
    % class implementing the specialized solution to the full backwards
    % induction procedure
    %
    % authored by Riccardo Minnozzi, 06/2024

    methods
        function obj = BackwardsInduction(phaseArray, ID, dummyPhaseManager)
            % BACKWARDSINDUCTION constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = phaseArray;
                super_args{2} = ID;
                super_args{3} = dummyPhaseManager;
            end
            obj@abstract_BackwardsInduction(super_args{:});

        end

        function obj = perform(obj, trqpSolver, convergenceTest)
            % method implementing the solution of the full backwards sweep

            % set the initial partial values
            obj = obj.initialize();

            for i = obj.M : -1 : 1
                % loop over the phase objects and backwards solve them all

                if i ~= obj.M && i ~= 1
                    % for a generic phase, solve using the optimized cost
                    % to go of the upstream phase and manager + final point
                    % of the previous phase
                    [~, xm, ~, wm, lm] = obj.phaseArray(i-1).plant.getFinalPoint();
                    sigmam = obj.phaseArray(i-1).sigma;
                    previousPhaseManager = obj.phaseArray(i-1).phaseManager;
                    upstreamJOpt = obj.phaseArray(i+1).getOptimizedQuantity();

                elseif i == obj.M && i ~= 1
                    % for the final phase, solve using the init_Jopt
                    % computed at the start of this method
                    [~, xm, ~, wm, lm] = obj.phaseArray(i-1).plant.getFinalPoint();
                    sigmam = obj.phaseArray(i-1).sigma;
                    previousPhaseManager = obj.phaseArray(i-1).phaseManager;
                    upstreamJOpt = obj.init_Jopt;
                elseif i == 1 && i ~= obj.M
                    % for the first phase, solve using the
                    % dummyPhaseManager and a full 0 point as previous
                    % quantities
                    xm = 0; wm = 0; lm = 0; sigmam = 0;
                    previousPhaseManager = obj.dummyPhaseManager;
                    upstreamJOpt = obj.phaseArray(i+1).getOptimizedQuantity();
                else
                    % for a single phase problem, solve using the init_Jopt
                    % and the dummy phase manager
                    xm = 0; wm = 0; lm = 0; sigmam = 0;
                    previousPhaseManager = obj.dummyPhaseManager;
                    upstreamJOpt = obj.init_Jopt;
                end

                % solve phase problem
                obj.phaseArray(i) = obj.phaseArray(i).solve(upstreamJOpt, ...
                    trqpSolver, convergenceTest, previousPhaseManager, ...
                    xm, wm, lm, sigmam);

            end
        end

    end
end

