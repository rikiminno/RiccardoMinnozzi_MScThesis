classdef PhaseConfig_2 < PhaseConfig
    % phase 2 configuration class for the linear quadratic problem

    methods
        function obj = PhaseConfig_2()
            % PHASECONFIG_1 constructor

            obj@PhaseConfig();
        end

    end

    methods (Access = protected)

        function t = setTimeInitialGuess(obj)
            % method to output the time history initial guess

            t = 6:11;
        end

        function [u, nu] = setControlInitialGuess(obj)
            % method to output the control initial guess

            nu = 1;
            u = @(t, x, w) zeros(nu, 1);
        end

        function w = setParametersInitialGuess(obj)
            % method to output the parameters initial guess

            nw = 2;
            w = zeros(nw, 1);
        end

        function l = setMultipliersInitialGuess(obj)
            % method to output the multipliers initial guess

            nl = 2;
            l = zeros(nl, 1);
        end

    end
end

