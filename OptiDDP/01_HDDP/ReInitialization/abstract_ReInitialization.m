classdef abstract_ReInitialization < handle
    % base class defining the re-initialization procedure for the HDDP
    % algorithm
    %
    % authored by Riccardo Minnozzi, 10/2024

    properties(Access = protected)
        settings
        iterCount   {mustBeReal(iterCount)} = 0
    end

    properties(SetAccess = protected, GetAccess = public)
        % tolerances
        eps_1
        eps_opt
        eps_feas
        Delta

        % stopping condition
        stoppingCondition {mustBeA(stoppingCondition, "StoppingCondition")} = StoppingCondition.none
    end

    methods
        function obj = abstract_ReInitialization(settings)
            %ABSTRACT_REINITIALIZATION Constructor

            if nargin > 0
                obj.settings = settings;
                obj.eps_1 = settings.eps_1;
                obj.eps_opt = settings.eps_opt;
                obj.eps_feas = settings.eps_feas;
                obj.Delta = settings.Delta_0;
            end
        end
    end

    methods(Abstract, Access = public)
        stopNow = checkEarlyTermination(obj, iterate)
        obj = perform(obj, refIterate, converged)
    end

    methods(Abstract, Access = protected)
        eps_1 = reInitEps1(obj, refIterate)
        eps_opt = reInitEpsOpt(obj, refIterate)
        eps_feas = reInitEpsFeas(obj, refIterate)
        Delta = reInitDelta(obj, Delta)
    end
end

