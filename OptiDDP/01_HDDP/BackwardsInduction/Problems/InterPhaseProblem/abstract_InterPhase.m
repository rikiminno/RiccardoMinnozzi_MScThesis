classdef abstract_InterPhase < abstract_Problem
    % interface class for the InterPhase implementation, defines the
    % required methods and properties for correct implementation within the
    % HDDP framework
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (SetAccess = protected, GetAccess = public)
        wUpdateLaw  {mustBeA(wUpdateLaw, 'abstract_UpdateLaw')} = UpdateLaw()
        lUpdateLaw  {mustBeA(lUpdateLaw, 'abstract_UpdateLaw')} = UpdateLaw()
    end

    properties (Access = protected)
        xm
        wm
        lm
        sigmam
    end

    methods
        function obj = abstract_InterPhase(t, x, u, w, l, xm, wm, lm, sigmam, ID)
            % ABSTRACTINTERPHASE constructor

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
                obj.xm = xm;
                obj.wm = wm;
                obj.lm = lm;
                obj.sigmam = sigmam;
            end

            % define the default interphase quadratic expansion
            obj.J = InterPhaseQuadraticExpansion();

            % set the problem to solve to the multipliers one (which is to
            % be solved before the parameters one)
            obj.problemToSolve = ProblemVariant.multipliers;
        end

    end

    methods(Abstract)

        % method that solves the quadratic sub-problem resulting from the
        % inter-phase multipliers optimization, yields the updated
        % quadratic expansion and the multipliers update law
        solveMultipliersSubProblem(obj, trqpSolver, constrainedSystemSolver);

        % method that solves the quadratic sub-problem resulting from the
        % inter-phase static parameters optimization, yielding the
        % parameters update law
        solveParametersSubProblem(obj, trqpSolver, constrainedSystemSolver);

    end

end