classdef Stage_Psi < Stage
    % stage base class, containing the default quantities that identify an
    % optimization stage that also includes the propagation of the
    % constraint violation
    %
    % authored by Riccardo Minnozzi, 06/2024

    methods
        function obj = Stage_Psi(t, x, u, w, l, STM, STT, ID)
            % STAGEPSI constructor

            % abstract interphase superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = t;
                super_args{2} = x;
                super_args{3} = u;
                super_args{4} = w;
                super_args{5} = l;
                super_args{6} = STM;
                super_args{7} = STT;
                super_args{8} = ID;
            end
            obj@Stage(super_args{:});

        end

        function obj = performExpansion(obj, upstreamJopt, phaseManager)
            % function to perform the quadratic expansion of the current
            % stage

            % call to regular stage quadratic expansion
            obj = performExpansion@Stage(obj, upstreamJopt(1), phaseManager);

            % get state transition maps
            nPsi = phaseManager.nPsi;
            STM = obj.STM;
            STT = obj.STT;

            % set the (dummy) upstream stage expansion
            dummyStagePartial = phaseManager.computeLPartials(obj.t, obj.x, obj.u, obj.w);
            dummyStagePartial = resetPropertiesToZero(dummyStagePartial);

            % expand each component of the constraint violation
            for q = 1 : nPsi
                obj.J(q + 1) = obj.expand(upstreamJopt(q + 1), dummyStagePartial, STM, STT);
            end

        end

        function obj = solve(obj, upstreamJopt, phaseManager, trqpSolver)
            % function that fully solves the stage problem, defining all
            % its required properties for the backwards sweep

            obj = obj.performExpansion(upstreamJopt, phaseManager);
            obj = obj.solveStageSubProblem(trqpSolver, phaseManager);
        end

    end
end

