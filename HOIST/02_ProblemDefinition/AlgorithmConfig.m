classdef AlgorithmConfig < abstract_AlgorithmConfig
    % class defining the common optimization settings
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (SetAccess = protected, GetAccess = public)

        eps_path_feas = 1e-4

        Delta_0
        Delta_min
        Delta_max
        kd
        eps_1
        hardCaseEps = 0
        eta1 = 10;

        kEps_1
        eps_1_max

        D
        HesShift = 0

        kEasy
        kHard
        theta
        maxIter = 5

        nIters = 10

        ks
        Delta_s

        odeObject

    end

    methods
        function obj = AlgorithmConfig()
            % PROBLEMSETTINGS constructor

        end

    end
end

