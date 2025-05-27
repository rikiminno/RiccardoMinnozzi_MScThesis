classdef PhaseConfig_1 < PhaseConfig
    % phase 1 configuration class

    methods
        function obj = PhaseConfig_1()
            % PHASECONFIG_1 constructor

            global auxdata

            obj@PhaseConfig(auxdata);
        end

    end

    methods (Access = protected)

        function t = setTimeInitialGuess(obj)
            % method to output the time history initial guess

            t = linspace(obj.data.tau0, ...
                obj.data.tauf, ...
                obj.data.nStages);
        end

        function [u, nu] = setControlInitialGuess(obj)
            % method to output the control initial guess

            nu = 1;

            % % zero initial guess
            % u = @(t, x, w) 0;

            % locally optimal law initial guess
            function uLoc = locallyOptimalLaw(t, x, w)
                ubar = x(3);
                vbar = x(4);
                velNorm = sqrt(ubar^2 + vbar^2);
                uLoc = atan2(ubar/velNorm, vbar/velNorm);
            end
            u = @locallyOptimalLaw;
        end

        function w = setParametersInitialGuess(obj)
            % method to output the parameters initial guess

            nw = 1;
            w = zeros(nw, 1);
        end

        function l = setMultipliersInitialGuess(obj)
            % method to output the multipliers initial guess

            nl = 1;
            l = zeros(nl, 1);
        end

    end
end

