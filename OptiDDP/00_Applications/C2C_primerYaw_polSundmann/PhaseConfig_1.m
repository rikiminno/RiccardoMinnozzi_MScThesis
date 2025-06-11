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

            t = linspace(obj.data.theta0bar, ...
                obj.data.thetafbar, ...
                obj.data.nStages);
        end

        function [u, nu] = setControlInitialGuess(obj)
            % method to output the control initial guess

            nu = 1;
            global auxdata

            % locally optimal law initial guess
            function uLoc = locallyOptimalLaw(t, x, w)
                ubar = x(3);
                vbar = x(4);
                velNorm = sqrt(ubar^2 + vbar^2);
                uLoc = atan2(ubar/velNorm, vbar/velNorm);
            end

            function uEcc = guessEccZ(t, x, w)
                currentRev = t * auxdata.thetaf / (2 * pi);
                if currentRev < 37
                    uEcc = get_controls_at_times(auxdata.tGuess, auxdata.contGuess, t*2);
                else
                    uEcc = locallyOptimalLaw(t, x, w);
                end
            end

            if ~isempty(obj.data.uGuess)
                u = obj.data.uGuess;
                if strcmp(obj.data.uGuess, "eccZGuess")
                    u = @guessEccZ;
                end
            else
                u = @locallyOptimalLaw;
            end
        end

        function w = setParametersInitialGuess(obj)
            % method to output the parameters initial guess

            nw = 1;
            w = zeros(nw, 1);
        end

        function l = setMultipliersInitialGuess(obj)
            % method to output the multipliers initial guess

            nl = 2;
            l = zeros(nl, 1);
        end

    end
end

function u = get_controls_at_times(t_opt, u_opt, t)
% function to perform the zero order hold interpolation of the controls as
% specified by the DDP constant controls assumptions

tol = 1e-12;
u = [];
for i = 1 : length(t)

    % get current time
    current_t = t(i);

    % find the current time stamp (if present)
    t_idx = find(abs(t_opt - current_t) < tol, 1);
    if isempty(t_idx), t_idx = find(t_opt <= current_t, 1, 'last'); end

    % get the corresponding control
    current_u = u_opt(t_idx, :);

    % stack the controls
    u = cat(1, u, current_u);
end
end