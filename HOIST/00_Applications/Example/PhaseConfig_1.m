classdef PhaseConfig_1 < PhaseConfig
    % phase 1 configuration class for the linear quadratic problem

    methods
        function obj = PhaseConfig_1()
            % PHASECONFIG_1 constructor

            obj@PhaseConfig();
        end

    end

    methods (Access = protected)

        function t = setTimeInitialGuess(obj)
            % method to output the time history initial guess

            t = 1:6;
        end

        function [u, nu] = setControlInitialGuess(obj)
            % method to output the control initial guess

            nu = 3;
            u = @(t, x, w) zeros(nu, 1);
        end

        function w = setParametersInitialGuess(obj)
            % method to output the parameters initial guess

            nw = 1;
            w = zeros(nw, 1);
        end

        function l = setMultipliersInitialGuess(obj)
            % method to output the multipliers initial guess

            nl = 6;
            l = zeros(nl, 1);
        end

    end
end

