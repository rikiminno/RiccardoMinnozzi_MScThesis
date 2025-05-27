classdef StoppingCondition
    % class defining the different stopping conditions that can be
    % encountered by the HDDP algorithm

    properties
        condition
    end

    methods
        function obj = StoppingCondition(condition)
            % STOPPINGCONDITION constructor

            % assign the stopping condition
            obj.condition = condition;
        end

    end

    enumeration

        none     ("n")

        softFail    ("Sf")
        hardFail    ("Hf")
        softSuccess ("Ss")
        hardSuccess ("Hs")

    end

end

