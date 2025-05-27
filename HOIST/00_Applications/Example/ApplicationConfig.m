classdef ApplicationConfig < AlgorithmConfig
    % class that defines the application settings to be used when
    % instantiating the various objects that make up the full HDDP
    % algorithm

    methods
        function obj = ApplicationConfig()
            % OPTIMIZATIONCONFIG contructor

            obj.Delta_0 = inf;
            obj.Delta_max = inf;
            obj.Delta_min = 0.1;
            obj.kd = 0.01;
            obj.eps_1 = 0.1;

            obj.HesShift = 0;

            obj.eps_feas = 1e-5;
            obj.eps_opt = 1e-6;

            obj.ks = 1.1;
            obj.sigma_0 = 10;
            obj.Delta_s = 10;

            obj.kEps_1 = 1.5;
            obj.eps_1_max = obj.eps_1;

            % odeObject = ode();
            % odeObject.Solver = "ode45";
            % odeObject.AbsoluteTolerance = 1e-5;
            % odeObject.RelativeTolerance = 1e-5;
            % odeObject.SolverOptions.OutputFcn = [];

            odeObject = CustomOde();
            odeObject.Solver = "ode1";
            odeObject.StepSize = 1;

            obj.odeObject = odeObject;

            obj.useParPool = false;
            obj.maxRunTime = 20;

            obj.version = obj.defaultVersion();

        end

    end
end

