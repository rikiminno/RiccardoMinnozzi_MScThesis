classdef abstract_Problem < Identifier
    % interface for any generic problem specialized class (stage or
    % inter-phase), defines the required properties and methods for the
    % integration within the HDDP framework
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (Access = protected)
        t
        x
        u
        w
        l
    end

    properties (SetAccess = protected, GetAccess = public)
        J           {mustBeA(J, ["StageQuadraticExpansion", "InterPhaseQuadraticExpansion"])} = StageQuadraticExpansion()
        Jopt        {mustBeA(Jopt, 'OptimizedQuantity')} = OptimizedQuantity()
        q % active constraints partials (no validation since it can also be empty)
    end

    properties (Access = public)
        problemToSolve  {mustBeA(problemToSolve, 'ProblemVariant')} = ProblemVariant.undefined
    end

    methods
        function obj = abstract_Problem(t, x, u, w, l, ID)
            % ABSTRACTPROBLEM constructor

            % call to Identifier super class constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = ID;
            end
            obj@Identifier(super_args{:});

            % extra arguments
            if nargin > 0
                obj.t  = t;
                obj.x  = x;
                obj.u  = u;
                obj.w  = w;
                obj.l  = l;
            end
        end

        function [t, x, u, w, l] = getPoint(obj)
            % function to retrieve the current problem point quantities

            t = obj.t;
            x = obj.x;
            u = obj.u;
            w = obj.w;
            l = obj.l;
        end

    end

    methods (Abstract)

        % method that computes the cost to go partials for the current
        % problem
        performExpansion(obj, partialValues);

        % method to fully retrieve the solution to the current problem
        % (regardless of it being a stage or interphase problem)
        solve(obj, phaseManager, trqpSolver, constrainedSystemSolver)

    end

end
