classdef ProblemVariant
    % class defining the different problems to be tackled by the solvers
    % throughout the algorithm

    properties
        problem
    end

    methods
        function obj = ProblemVariant(problem)
            % PROBLEMVARIANT constructor

            % assign the problem
            obj.problem = problem;
        end

    end

    enumeration

        undefined   ("ND")

        controls    ("u")
        parameters  ("w")
        multipliers ("l")

    end


end

