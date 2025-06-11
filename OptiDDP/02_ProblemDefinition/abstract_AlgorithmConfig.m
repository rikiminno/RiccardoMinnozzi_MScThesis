classdef (Abstract) abstract_AlgorithmConfig
    % class defining the required base methods and properties for the
    % problem settings
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (SetAccess = protected, GetAccess = public)
        eps_opt
        eps_feas

        sigma_0

        version     = abstract_AlgorithmConfig.defaultVersion()

        maxRunTime  = 8*3600
        useParPool  = false

        nWorkers = [1, 63];
    end

    methods
        function obj = abstract_AlgorithmConfig()
            % ABSTRACTPROBLEMSETTINGS constructor

        end
    end

    methods(Static)
        function version = defaultVersion()
            % method that implements the default versions of the various
            % solvers and hddp steps

            version.forwardPass = "ForwardPass";
            version.trqpSolver = "TrqpSolver";
            version.constrainedSystemSolver = "ConstrainedSystemSolver";
            version.convergenceTest = "ConvergenceTest";
            version.stmsPropagation = "StmsPropagation";
            version.iterationUpdate = "IterationUpdate";
            version.penaltyUpdate = "PenaltyUpdate";
            version.backwardsInduction = "BackwardsInduction";
            version.phase = "Phase";
            version.stage = "Stage";
            version.interPhase = "InterPhase";
            version.phaseManager = "PhaseManager";
            version.reInitialization = "ReInitialization";
        end

        function version = includeConstraintPropagation()
            % method that outputs the default algorithm version while also
            % including the _Psi classes variants

            version.forwardPass = "ForwardPass";
            version.trqpSolver = "TrqpSolver";
            version.constrainedSystemSolver = "ConstrainedSystemSolver";
            version.convergenceTest = "ConvergenceTest";
            version.stmsPropagation = "StmsPropagation";
            version.iterationUpdate = "IterationUpdate";
            version.penaltyUpdate = "PenaltyUpdate_Psi";
            version.backwardsInduction = "BackwardsInduction";
            version.phase = "Phase";
            version.stage = "Stage_Psi";
            version.interPhase = "InterPhase_Psi";
            version.phaseManager = "PhaseManager";
            version.reInitialization = "ReInitialization";
        end

    end
end

