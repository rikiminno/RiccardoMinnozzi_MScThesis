classdef PhaseManager < abstract_PhaseManager
    % class that implements the differentiation and evaluation of the
    % current phase partials in the case of automatic differentiation being
    % required to generate the variational equations and optimization
    % partials
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (SetAccess = protected, GetAccess = public)
        % all these file names are not set in the constructor because there
        % is a method to generate them

        % variational equations file
        varEq_file       {mustBeText(varEq_file)} = "undefined"

        % augmented state derivative
        ft_X_file        {mustBeText} = "undefined"
        ft_XX_file       {mustBeText} = "undefined"
        ft_t_file        {mustBeText} = "undefined"

        % augmented Lagrangian
        phit_I_file     {mustBeText} = "undefined"
        phit_II_file    {mustBeText} = "undefined"

        % initial conditions
        Gamma_w_file        {mustBeText} = "undefined"
        Gamma_ww_file       {mustBeText} = "undefined"

        % running cost
        L_X_file        {mustBeText} = "undefined"
        L_XX_file       {mustBeText} = "undefined"

        % path constraints
        cEq_X_file      {mustBeText} = "undefined"
        cEq_XX_file     {mustBeText} = "undefined"

        % terminal constraints
        Psi_I_file  {mustBeText} = "undefined"
        Psi_II_file {mustBeText} = "undefined"

        % step size control
        tPoint_X_file   {mustBeText} = "undefined"
        tPoint_XX_file  {mustBeText} = "undefined"
    end

    methods
        function obj = PhaseManager(phaseConfig, nxp, nwp, phaseFolder, ID)
            % PHASEMANAGER constructor;

            % call to superclass constructor
            if nargin == 0
                super_args = {};
            else
                super_args{1} = phaseConfig;
                super_args{2} = nxp;
                super_args{3} = nwp;
                super_args{4} = phaseFolder;
                super_args{5} = ID;
            end
            obj@abstract_PhaseManager(super_args{:});

        end

        function obj = createAllPartials(obj)
            % function that generates the function files for the partials
            % of the current phase using adigator

            % go to the phase folder
            startDir = pwd;
            cd(obj.buildFolder);

            % check if the wrapper files exist
            if ~exist(strcat(obj.phit_file, ".m"), "file") || ~exist(strcat(obj.ft_file, ".m"), "file") ...
                    || ~exist(strcat(obj.Gamma_file, ".m"), "file") ...
                    || ~exist(strcat(obj.L_file, ".m"), "file")
                error(strcat("The problem definition wrapper function files for phase ",...
                    string(obj.ID(2)), " do not exists: create them or hot-start the application ", ...
                    "to avoid generating new function files."));
            end

            % generate the partials
            obj = createAugmentedLagrangianPartials(obj);
            obj = createRunningCostPartials(obj);
            obj = createDynamicsPartials(obj);
            obj = createInitialConditionsPartials(obj);
            obj = createPathConstraintsPartials(obj);
            obj = createConstraintsPartials(obj);
            obj = createVariationalEquations(obj);
            obj = createStageCollocationPartials(obj);

            % go back to starting directory
            cd(startDir);
        end

        function obj = setAllPartials(obj)
            % function that sets all the partial file names from the
            % current phase folder, instead of having to generate them

            % check that the wrappers folder exists before setting the
            % partials
            if ~exist(obj.buildFolder, "dir")
                error(strcat("The PhaseManager object for phase ", string(obj.ID(2)), ...
                    " is being set while the corresponding 'build' folder", ...
                    " does not exist: check for the correct setting of the ", ...
                    "MATLAB path, and if needed cold-start the application to ",...
                    "generate new wrapper files."));
            end

            % add the wrappers folder to path
            addpath(obj.buildFolder);

            % set the automatically generated wrapper functions
            i = string(obj.ID(2));
            obj.phit_file = strcat("phit_", i);
            obj.Gamma_file = strcat("Gamma_", i);
            obj.L_file = strcat("L_", i);
            obj.ft_file = strcat("ft_", i);
            obj.varEq_file = strcat("varEq_", i);
            obj.cEq_file = strcat("cEq_", i);
            obj.Psi_file = strcat("Psi_", i);
            obj.tPoint_file = strcat("tPoint_", i);

            % manually set the partial files names
            currentPartial = strcat(obj.ft_file, "_");
            % dynamics
            obj.ft_X_file        = strcat(currentPartial, "X");
            obj.ft_XX_file       = strcat(currentPartial, "XX");
            obj.ft_t_file        = strcat(currentPartial, "t");

            % augmented Lagrangian
            currentPartial = strcat(obj.phit_file, "_");
            obj.phit_I_file     = strcat(currentPartial, "I");
            obj.phit_II_file    = strcat(currentPartial, "II");

            % initial conditions
            currentPartial = strcat(obj.Gamma_file, "_");
            obj.Gamma_w_file    = strcat(currentPartial, "w");
            obj.Gamma_ww_file   = strcat(currentPartial, "ww");

            % running cost
            currentPartial = strcat(obj.L_file, "_");
            obj.L_X_file    = strcat(currentPartial, "X");
            obj.L_XX_file   = strcat(currentPartial, "XX");

            % path constraints
            currentPartial  = strcat(obj.cEq_file, "_");
            obj.cEq_X_file  = strcat(currentPartial, "X");
            obj.cEq_XX_file = strcat(currentPartial, "XX");

            % terminal constraints
            current_partial = strcat(obj.Psi_file, "_");
            obj.Psi_I_file = strcat(current_partial, "I");
            obj.Psi_II_file = strcat(current_partial, "II");

            % step size control
            current_partial = strcat(obj.tPoint_file, "_");
            obj.tPoint_X_file = strcat(current_partial, "X");
            obj.tPoint_XX_file = strcat(current_partial, "XX");
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% METHODS DEFINED IN EXTERNAL FILES %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % computation of the specific partials
        LPartials = computeLPartials(obj, t, x, u, w)
        phitPartials = computePhitPartials(obj, xm, wm, xp, wp, lm, sigma)
        GammaPartials = computeGammaPartials(obj, w)
        init_Jopt = computeInitializationPartials(obj, x, w, l, sigma)
        PsiPartials = computePsiPartials(obj, xm, wm, xp, wp, lm)
        cEq_partials = computePathConstraintsPartials(obj, t, x, u, w)

        % methods defined in external files, only used to shorten the
        % definition of the createAllPartials method
        obj = createAugmentedLagrangianPartials(obj)
        obj = createRunningCostPartials(obj)
        obj = createDynamicsPartials(obj)
        obj = createInitialConditionsPartials(obj)
        obj = createPathConstraintsPartials(obj)
        obj = createVariationalEquations(obj)
        obj = createConstraintsPartials(obj)
        obj = createStageCollocationPartials(obj)
    end

end

