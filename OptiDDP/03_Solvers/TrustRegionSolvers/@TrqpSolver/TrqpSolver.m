classdef TrqpSolver < abstract_TrqpSolver
    % class defining the TRQP solver algorithm
    %
    % authored by Riccardo Minnozzi, 06/2024

    methods
        function obj = TrqpSolver(settings, eps_1, Delta)
            % TRQPSOLVER constructor

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = settings;
                super_args{2} = eps_1;
                super_args{3} = Delta;
            end
            obj@abstract_TrqpSolver(super_args{:});

        end

        % solution method defined in external function
        [updateLaw, q] = solve(obj, problem, phaseManager)

    end
end

