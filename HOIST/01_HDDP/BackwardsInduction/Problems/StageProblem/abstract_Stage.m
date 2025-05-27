classdef abstract_Stage < abstract_Problem
    % interface class for the Stage implementation, defines the
    % required methods and properties for correct implementation within the
    % HDDP framework
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties(SetAccess = protected, GetAccess = public)
        uUpdateLaw  {mustBeA(uUpdateLaw, 'abstract_UpdateLaw')} = UpdateLaw()
    end

    properties (Access = protected)
        STM
        STT
    end

    methods
        function obj = abstract_Stage(t, x, u, w, l, STM, STT, ID)
            % ABSTRACTSTAGE constructor

            % call problem superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = t;
                super_args{2} = x;
                super_args{3} = u;
                super_args{4} = w;
                super_args{5} = l;
                super_args{6} = ID;
            end
            obj@abstract_Problem(super_args{:});

            if nargin > 0
                obj.STM = STM;
                obj.STT = STT;
            end

            % define the default interphase quadratic expansion
            obj.J = StageQuadraticExpansion();

            % define the problem to solve
            obj.problemToSolve = ProblemVariant.controls;
        end

        function obj = setUpstreamOptimizedQuantity(obj, Jopt)
            % function that sets the stage optimized cost to go, to be used
            % on the final stage of each phase to initialize the phase
            % backwards induction

            obj.Jopt = Jopt;
        end

        function [STM, STT] = getStateTransitionMaps(obj)
            % function to retrieve the current stage state transition maps

            STM = obj.STM;
            STT = obj.STT;
        end

    end

    methods(Abstract)

        % method that solves the quadratic sub-problem resulting from the
        % optimization stage
        obj = solveStageSubProblem(obj);

    end

end

