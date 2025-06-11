classdef TrqpSolver_quadraticConstrained < abstract_TrqpSolver
    % class defining the TRQP solver for a constrained problem defining a
    % quadratic update law
    %
    % authored by Riccardo Minnozzi, 10/2024

    methods
        function obj = TrqpSolver_quadraticConstrained(settings, eps_1, Delta)
            % TRQPSOLVER_QUADRATICCONSTRAINED constructor

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

        % method to evaluate the active set of constraints
        [q, nEq] = estimateActiveSet(obj, problem, phaseManager, du)

    end
end

