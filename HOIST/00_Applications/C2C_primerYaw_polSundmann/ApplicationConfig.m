classdef ApplicationConfig < AlgorithmConfig
    % class that defines the application settings to be used when
    % instantiating the various objects that make up the full HDDP
    % algorithm

    methods
        function obj = ApplicationConfig()
            % OPTIMIZATIONCONFIG contructor

            obj.nIters = 1;

obj.Delta_0 = 0.01;
obj.Delta_max = inf;
obj.Delta_min = 1e-8;
obj.kd = 0.05;
obj.eps_1 = 0.1;

obj.HesShift = 0;
obj.kEasy = 0.0001;
obj.kHard = 0.0002;
obj.theta = 0.01;

obj.eps_feas = 1e-5;
obj.eps_opt = 1e-6;

obj.kEps_1 = 2.2;
obj.eps_1_max = 0.2;

obj.ks = 1.05;
obj.sigma_0 = 1e6;
obj.Delta_s = 50;
obj.maxIter = 21;

            odeObject = CustomOde();
            odeObject.Solver = "ode45";
            odeObject.AbsoluteTolerance = 1e-8;
            odeObject.RelativeTolerance = 1e-8;

            obj.odeObject = odeObject;

            obj.useParPool = true;
obj.maxRunTime = 4 * 3600;

obj.version = obj.defaultVersion();
obj.version.trqpSolver = 'TrqpSolver_Conn';
obj.version.penaltyUpdate = 'PenaltyUpdate';

        end

    end
end