classdef abstract_PhaseManager < Identifier
    % base class defining the interface for phase manager specialized
    % implementations with external files and problem definition
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (SetAccess = protected, GetAccess = public)
        % user provided files for problem definition
        stateDerivativeFile             {mustBeText(stateDerivativeFile)} = "undefined"
        terminalCostFile                {mustBeText(terminalCostFile)} = "undefined"
        terminalConstraintFile          {mustBeText(terminalConstraintFile)} = "undefined"
        runningCostFile                 {mustBeText(runningCostFile)} = "undefined"
        initialConditionFile            {mustBeText(initialConditionFile)} = "undefined"
        pathConstraintsEq_file          {mustBeText(pathConstraintsEq_file)} = "undefined"

        % user provided files for discretization definition
        stageCollocationFile            {mustBeText(stageCollocationFile)} = "undefined"
        stageNumberControlFile          {mustBeText(stageNumberControlFile)} = "undefined"

        % automatically generated wrapper files
        phit_file                       {mustBeText(phit_file)} = "undefined"
        L_file                          {mustBeText(L_file)} = "undefined"
        Gamma_file                      {mustBeText(Gamma_file)} = "undefined"
        ft_file                         {mustBeText(ft_file)} = "undefined"
        cEq_file                        {mustBeText(cEq_file)} = "undefined"
        Psi_file                        {mustBeText(Psi_file)} = "undefined"
        tPoint_file                     {mustBeText(tPoint_file)} = "undefined"

        % useful directories
        buildFolder                   {mustBeText(buildFolder)} = "undefined"

        % dimensions
        nx
        nu
        nw
        nl
        nxp
        nwp
        mEq
        nPsi
    end

    methods
        function obj = abstract_PhaseManager(phaseConfig, nxp, nwp, phaseFolder, ID)
            % ABSTRACTPHASEMANAGER constructor

            % call to identifier constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = ID;
            end
            obj@Identifier(super_args{:});

            if nargin > 0
                obj.buildFolder     = fullfile(phaseFolder, 'build');

                % set the problem definition files
                i = obj.ID(2);
                obj.terminalConstraintFile  = strcat("terminal_constraint_", string(i));
                obj.terminalCostFile        = strcat("terminal_cost_", string(i));
                obj.runningCostFile         = strcat("running_cost_", string(i));
                obj.stateDerivativeFile     = strcat("state_derivative_", string(i));
                obj.initialConditionFile    = strcat("initial_condition_", string(i));
                obj.pathConstraintsEq_file  = strcat("path_eq_constraints_", string(i));
                obj.stageCollocationFile    = strcat("stage_collocation_", string(i));
                obj.stageNumberControlFile  = strcat("stage_number_control_", string(i));

                % retrieve dimensions
                obj.nxp = nxp;
                obj.nwp = nwp;
                obj.nu = phaseConfig.nu;
                obj.nw = phaseConfig.nw;
                obj.nl = phaseConfig.nl;

                % evaluate the initial condition to retrieve the state size
                x0 = feval(obj.initialConditionFile, phaseConfig.w);
                obj.nx = size(x0, 1);

                % evaluate the path constraints to retrieve their size
                cEq = obj.performTrialEvaluation("pathConstraintsEq_file", ...
                    [1; obj.nx; obj.nu; obj.nw]);
                obj.mEq = size(cEq, 1);

                % evaluate the terminal constraints to retrieve their size
                Psi = obj.performTrialEvaluation("terminalConstraintFile", ...
                    [obj.nx; obj.nw; obj.nxp; obj.nwp]);
                obj.nPsi = size(Psi, 1);
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% METHODS DEFINED IN EXTERNAL FILES %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % method to build the problem
        obj = buildProblem(obj)

        % method to retrieve the problem dimensions
        [nx, nu, nw, nl, nxp, nwp] = getInputSizes(obj)

        % method to evaluate a definition file to check its output
        out = performTrialEvaluation(obj, fileToEvaluate, inputSizes)

    end

    methods (Access = private)
        % methods for the creation of build files
        obj = createAugmentedLagrangianBuildFile(obj)
        obj = createAugmentedStateDerivativeBuildFile(obj)
        obj = createInitialConditionBuildFile(obj)
        obj = createRunningCostBuildFile(obj)
        obj = createPathConstraintsBuildFiles(obj)
        obj = createConstraintsBuildFile(obj)
        obj = createStageCollocationBuildFile(obj)

        % methods for validation
        validatePhaseManager(obj)
        checkIsDefined(obj)
    end

    methods(Abstract)

        % method to compute the values of the augmented Lagrangian partials
        % on the specified point object
        phitPartials = computePhitPartials(obj, xm, wm, xp, wp, lm, sigma);

        % method to compute the values of the running cost partials on the
        % specified point object
        LPartials = computeLPartials(obj, t, x, u, w);

        % method to compute the values of the initial condition partials on
        % the specified point object
        GammaPartials = computeGammaPartials(obj, w);

        % method to compute the final phase augmented Lagrangian partials
        % on the specified point, outputting a OptimizedCostToGo object
        init_Jopt = computeInitializationPartials(obj, x, w, l, sigma);

        % method to compute the partials of both the equality and
        % inequality path constraints
        cEq_partials = computePathConstraintsPartials(obj, t, x, u, w);

    end

end

