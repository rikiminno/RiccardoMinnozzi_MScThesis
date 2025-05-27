classdef abstract_ConvergenceTest < Identifier
    % class implementing the basic methods and properties to perform the
    % convergence test
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (Access = protected)
        settings {mustBeA(settings, 'abstract_AlgorithmConfig')} = AlgorithmConfig()
    end

    properties (SetAccess = protected, GetAccess = public)
        eps_opt
        eps_feas
    end

    methods
        function obj = abstract_ConvergenceTest(settings, eps_opt, eps_feas, ID)
            % ABSTRACTCONVERGENCETEST constructor

            % call to identifier constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = ID;
            end
            obj@Identifier(super_args{:});

            if nargin > 0
                obj.settings = settings;

                % initialize the convergence test with more relaxed
                % tolerances
                obj.eps_opt = eps_opt;
                obj.eps_feas = eps_feas;
            end

        end

    end

    methods(Abstract)

        % method to run the convergence test, outputs a boolean flag if it
        % reached convergence or not
        converged = perform(obj)

        % method to be called inside the constrained system solver to
        % certify whether the solution to the current problem is to be
        % accepted or not
        accepted = checkSolution(obj, problem)

    end
end

