classdef CustomOde
    % custom ode object class, allows to use a user-implemented fixed step
    % solver to propagate the HDDP dynamics and tensors
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties
        % problem definition
        InitialTime
        InitialValue
        StepSize
        ODEFcn
        
        % options
        Solver              {mustBeMember(Solver, ["ode1", "ode45", "ode4", ...
            "ode78", "ode89", "ode23", "ode5", "ode8"])} = "ode45"
        AbsoluteTolerance
        RelativeTolerance
    end

    methods
        function obj = CustomOde()
            % ABSTRACT_CUSTOMODE constructor

        end

        function S = solve(obj, t)
            % function that implements the solution of the ode system at
            % time t, using the object-characteristic initial time, value
            % and solver

            % check that the provided time point is correct
            if ~isempty(obj.StepSize)
                if  mod(t-obj.InitialTime, obj.StepSize) ~= 0
                    % extra check for when the step size and the solution
                    % interval are equal
                    if abs(t-obj.InitialTime - obj.StepSize) > eps
                        error(strcat("The ode1 solver has been set with step size dt = '", ...
                            string(obj.StepSize), "', but the time span to be solved is '", string(t-obj.InitialTime), ...
                            "', which is not a multiple of dt."));
                    end
                end
            end
            % check that the provided initial value is correct
            if size(obj.InitialValue, 2) ~= 1
                error("The initial value provided to the ode solver shall be a column vector.");
            end

            % TODO: add checks for the ODEFcn and its outputs

            switch obj.Solver
                case "ode1"
                    S = obj.ode_1(t);
                case "ode45"
                    S = obj.ode_45(t);
                case "ode4"
                    S = obj.ode_4(t);
                case "ode23"
                    S = obj.ode_23(t);
                case "ode78"
                    S = obj.ode_78(t);
                case "ode89"
                    S = obj.ode_89(t);
                case "ode5"
                    S = obj.ode_5(t);
                case "ode8"
                    S = obj.ode_8(t);
            end

        end

    end

    methods(Access = private)
        S = ode1(obj, t)
    end
end

