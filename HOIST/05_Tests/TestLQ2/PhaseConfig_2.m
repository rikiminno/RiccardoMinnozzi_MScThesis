classdef PhaseConfig_2 < PhaseConfig
    % phase 2 configuration class for the linear quadratic problem

    methods
        function obj = PhaseConfig_2()
            % PHASECONFIG_1 constructor

            obj@PhaseConfig();
        end

    end

    methods (Static, Access = protected)

        function t = setTimeInitialGuess()
            % method to output the time history initial guess

            t = 6:11;
        end

        function [u, nu] = setControlInitialGuess()
            % method to output the control initial guess

            nu = 3;
            u = @(t, x, w) zeros(nu, 1);
        end

        function w = setParametersInitialGuess()
            % method to output the parameters initial guess

            nw = 6;
            w = zeros(nw, 1);
        end

        function l = setMultipliersInitialGuess()
            % method to output the multipliers initial guess

            nl = 3;
            l = zeros(nl, 1);
        end

    end
end

