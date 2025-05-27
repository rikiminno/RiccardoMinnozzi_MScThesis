function run_main(startFlag)

% define global application auxiliary data
global auxdata

% environment parameters
auxdata.Re  = 6378;
auxdata.mu  = 3.986004418e5;
auxdata.a0  = 1.0e-6;
auxdata.Omg = 90;

% time discretization
auxdata.t_flight    = 10;
auxdata.t0          = 0;
auxdata.tf          = auxdata.t0 + 24*3600*auxdata.t_flight;
auxdata.nStages     = 1001;

% initial conditions
auxdata.r0      = 42164;
auxdata.theta0  = 0;
auxdata.u0      = 0;
auxdata.v0      = sqrt(auxdata.mu/auxdata.r0);

% scaling
auxdata.r0bar       = auxdata.r0/auxdata.r0;
auxdata.theta0bar   = auxdata.theta0;
auxdata.u0bar       = auxdata.u0/auxdata.v0;
auxdata.v0bar       = auxdata.v0/auxdata.v0;
auxdata.tau0        = auxdata.t0/auxdata.tf;
auxdata.tauf        = auxdata.tf/auxdata.tf;
auxdata.a0bar       = auxdata.a0/(auxdata.v0/auxdata.tf);
auxdata.T0          = 2*pi*sqrt(auxdata.r0^3/auxdata.mu);
auxdata.eta         = auxdata.v0*auxdata.tf/auxdata.r0;

% define the application
app = Application();

if strcmp(startFlag, "coldStart")
    % cleanup adigator generated files
    app.rte.removeWrapperFolder();

    % build the application files
    app = app.build("startFlag","coldStart");
else

    % use previously built application files
    app = app.build("startFlag","hotStart");
end

% run the optimization
app = app.run();