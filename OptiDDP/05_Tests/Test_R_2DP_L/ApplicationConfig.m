classdef ApplicationConfig < AlgorithmConfig
    % class that defines the application settings to be used when
    % instantiating the various objects that make up the full HDDP
    % algorithm

    methods
        function obj = ApplicationConfig()
            % OPTIMIZATIONCONFIG contructor

            obj.Delta_0 = 1;
            obj.Delta_max = inf;
            obj.Delta_min = 1e-12;
            obj.kd = 0.01;
            obj.eps_1 = 0.4;

            obj.D = 0.01;
            obj.HesShift = 0.001;

            obj.eps_SVD = 0.001;
            obj.eps_feas = 0.001;
            obj.eps_opt = 1e-8;

            obj.ks = 1.1;
            obj.sigma_0 = 1;

            odeObject = ode();
            odeObject.Solver = "ode45";
            odeObject.AbsoluteTolerance = 1e-5;
            odeObject.RelativeTolerance = 1e-5;

            obj.odeObject = odeObject;

            obj.useParPool = true;

        end

    end
end

