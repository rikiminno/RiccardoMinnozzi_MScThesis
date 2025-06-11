function run_main(name)

% assign input
if nargin > 0
    appInputs{1} = name;
else
    appInputs = {};
end

% guess for z direction ecccentricity
tmp = RunData("GEO_2DT_PY-P_aa0_60st_90revs_fin", "dummy", 1, @rescalingFunction, @depVarsFunction, false, "pol");
% clear global

% clear up workspace to avoid conflicts
% clear global
close all
clc

% guessFolder = 'GEO_2DT_PY-P_aa0_30st_180revs_fin';
% runDataGuessObj = RunData(guessFolder, "dummy", 1, @rescalingFunction, @depVarsFunction, false, "pol");
% guessControlFunction = get_control_guess(runDataGuessObj, 1);

% define global application auxiliary data
global auxdata

% environment parameters
auxdata.Re  = 6378;
auxdata.mu  = 3.986004418e5;
auxdata.a0 = 0.010 * 5.93 * 1e-6;
auxdata.Omg = 90;
auxdata.inc = 90;

% initial conditions
auxdata.r0 = 42164;
auxdata.theta0 = 0;
auxdata.t0      = 0;
auxdata.u0      = 0;
auxdata.v0 = sqrt(auxdata.mu/auxdata.r0);

auxdata.contGuess = tmp.raw.opt.u;
auxdata.tGuess = tmp.raw.opt.t;
auxdata.uGuess = "eccZGuess";

% true longitude discretization
auxdata.n_rev = 180;
auxdata.thetaf      = 2 * pi * auxdata.n_rev;
auxdata.stages_rev = 30;
auxdata.nStages     = auxdata.stages_rev * auxdata.n_rev + 1;

% scaling
auxdata.T0          = 2 * pi * sqrt(auxdata.r0^3 / auxdata.mu) * auxdata.n_rev;
auxdata.t0bar       = auxdata.t0 / auxdata.T0;
auxdata.r0bar       = auxdata.r0 / auxdata.r0;
auxdata.theta0bar   = auxdata.theta0 / auxdata.thetaf;
auxdata.thetafbar   = auxdata.thetaf / auxdata.thetaf;
auxdata.u0bar       = auxdata.u0 / auxdata.v0;
auxdata.v0bar       = auxdata.v0 / auxdata.v0;
auxdata.a0bar       = auxdata.a0 / (auxdata.v0 / auxdata.T0);
auxdata.eta         = auxdata.v0 * auxdata.T0 / auxdata.r0;

% define the application
app = Application(appInputs{:});

% build the application files
app = app.build("startFlag","hotStart");

% run the optimization
app = app.run();

% plot and save summary figures
% plot_solution(app.rte.outputDirectory);

% cleanup adigator generated files


%% Eccentricity in the Z direction
    function u = GuessEccZ(t, x, w)
        currentTheta = t * 2 * pi * 180;
        currentRev = currentTheta / (2*pi);
        % below 37 revolutions use the 90 revs guess
        if currentRev < 37
            u = get_controls_at_times(auxdata.tGuess, auxdata.contGuess, t*2);
        else
            ubar = x(3);
            vbar = x(4);
            velNorm = sqrt(ubar^2 + vbar^2);
            u = atan2(ubar/velNorm, vbar/velNorm);
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
end