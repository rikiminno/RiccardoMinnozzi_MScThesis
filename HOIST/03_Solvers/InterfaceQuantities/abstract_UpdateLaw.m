classdef abstract_UpdateLaw
    % base class for the update law object, implementing the default
    % interfaces for the update law objects class
    %
    % authored by Riccardo Minnozzi, 09/2024

    properties (SetAccess = protected, GetAccess = public)
        problemSolved {mustBeA(problemSolved, 'ProblemVariant')} = ProblemVariant.undefined
    end

    methods
        function obj = abstract_UpdateLaw(problemSolved)
            %ABSTRACT_UPDATELAW constructor

            if nargin > 0
                obj.problemSolved = problemSolved;
            end
        end

        function Jopt = updateExpansion(obj, J)
            % method that applies the computed update law to the current
            % problem quadratic expansion (component-wise, for every
            % component)

            % set the length of the quadratic expansion
            n = length(J);

            % check which kind of update law is being applied (and apply
            % it)
            switch obj.problemSolved
                case ProblemVariant.controls
                    for i = 1:n
                        Jopt(i) = obj.updateControlExpansion(J(i));
                    end
                case ProblemVariant.multipliers
                    for i = 1:n
                        Jopt(i) = obj.updateMultiplierExpansion(J(i));
                    end
                case ProblemVariant.parameters
                    for i = 1:n
                        Jopt(i) = obj.updateParameterExpansion(J(i));
                    end
            end

        end
    end

    methods (Abstract)
        % method for the computation of an update (control, multiplier or
        % parameters)
        da = computeUpdate(obj, dx, dw, dl);

        % methods for the application of the update law to the object
        % quadratic expansion
        Jopt = updateControlExpansion(obj, J);
        Jopt = updateMultiplierExpansion(obj, J);
        Jopt = updateParameterExpansion(obj, J);

        % method to retrieve the feedforward term to perform checks on the
        % trust region constraint or other path constraints
        da = getFeedForwardTerm(obj);
    end
end

