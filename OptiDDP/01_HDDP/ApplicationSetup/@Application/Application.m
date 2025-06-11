classdef Application < handle
    % class that instantiates an application object to set up the
    % optimization process
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (Access = public)
        % properties defined at application instantiation to represent the
        % problem definition
        rte                 {mustBeA(rte, 'RunTimeEnvironment')} = RunTimeEnvironment()
        phaseManagerArray   {mustBeA(phaseManagerArray, 'abstract_PhaseManager')} = PhaseManager()
        % validation sometimes causes to errors when converting default
        % class to user-defined class (does not happen for the dummy phase
        % manager, so investigate)
        dummyPhaseManager   {mustBeA(dummyPhaseManager, 'abstract_PhaseManager')} = PhaseManager()
        algorithmConfig     {mustBeA(algorithmConfig, 'abstract_AlgorithmConfig')} = AlgorithmConfig()
        phaseConfig % no validation since the phase config class is abstract by default

        % steps of the HDDP algorithm
        stmsPropagation     {mustBeA(stmsPropagation, 'abstract_StmsPropagation')} = StmsPropagation()
        forwardPass         {mustBeA(forwardPass, 'abstract_ForwardPass')} = ForwardPass()
        backwardsInduction  {mustBeA(backwardsInduction, 'abstract_BackwardsInduction')} = BackwardsInduction()
        convergenceTest     {mustBeA(convergenceTest, 'abstract_ConvergenceTest')} = ConvergenceTest()
        penaltyUpdate       {mustBeA(penaltyUpdate, 'abstract_PenaltyUpdate')} = PenaltyUpdate()
        trqpSolver          {mustBeA(trqpSolver, 'abstract_TrqpSolver')} = TrqpSolver()
        reInitialization    {mustBeA(reInitialization, 'abstract_ReInitialization')} = ReInitialization()

        % solution properties
        phaseArray          {mustBeA(phaseArray, 'abstract_Phase')} = Application.getDefaultPhase()
        iterate             {mustBeA(iterate, 'Iterate')} = Iterate()
    end

    properties (Access = protected)
        % flags
        hasSolution         {mustBeInteger(hasSolution)} = 0
        saveFullHistory     {mustBeInteger(saveFullHistory)} = 0
        terminateEarly      {mustBeInteger(terminateEarly)} = 0
    end

    methods
        function obj = Application(outputFolderName)
            % APPLICATION constructor, only defines the phase managers and
            % rte

            % set default input
            arguments
                outputFolderName {mustBeTextScalar} = Application.getOutputFolderName()
            end

            % get the application run time environment
            obj = obj.getRunTimeEnvironment(outputFolderName);

            % create the log file and start logging
            if ~exist(fullfile(obj.rte.outputDirectory, "log.txt"), "file")
                id = fopen(fullfile(obj.rte.outputDirectory, "log.txt"), "w");
            end
            diary(fullfile(obj.rte.outputDirectory, "log.txt"));
            cprintf('SystemCommand', strcat("Created log.txt file in output directory. \n\n"));

            try
                % splash command window
                cprintf('*blue', "%%%%%%%%%%%%%%%%%%%%%%%%%%");
                cprintf('*blue', "%%%%%%%%%%%%%%%%%%%%%%%%%%");
                cprintf('*blue', "%%%%%%%%%%%%%%%%%%%%%%%%%% \n");
                cprintf('*blue', "%%%%%%%%%% HOIST application startup %%%%%%%%%% \n");
                cprintf('*blue', "%%%%%%%%%%%%%%%%%%%%%%%%%%");
                cprintf('*blue', "%%%%%%%%%%%%%%%%%%%%%%%%%%");
                cprintf('*blue', "%%%%%%%%%%%%%%%%%%%%%%%%%% \n");
                cprintf('*blue', "\n");
                cprintf('*blue', "\n");
                fprintf(strcat(outputFolderName, " session started on ", ...
                    datestr(datetime("now")), ". \n"));
                fprintf("\n");
                fprintf("\n");

                % instantiate the config objects
                obj = obj.instantiateConfigs();
                phaseConfig = obj.phaseConfig;
                M = length(phaseConfig);
                appFolder = obj.rte.appFolder;

                % loop over all phases
                for i = M : -1 : 1
                    % instantiate the phase manager objects
                    phaseFolder = fullfile(appFolder, strcat("Phase", string(i)));

                    if i == M
                        % for the last phase, set nxp and nwp to 1
                        obj.phaseManagerArray(i) = feval( ...
                            obj.algorithmConfig.version.phaseManager, ...
                            phaseConfig{i}, 1, 1, phaseFolder, [-1; i; 0]);
                    else
                        % for all other phases, use information from
                        % upstream phases
                        obj.phaseManagerArray(i) = feval( ...
                            obj.algorithmConfig.version.phaseManager, ...
                            phaseConfig{i}, obj.phaseManagerArray(i+1).nx, ...
                            phaseConfig{i+1}.nw, phaseFolder, [-1; i; 0]);
                    end
                end

                % instantiate the dummy phase 0 config
                dummyPhaseConfig = DummyPhaseConfig0();

                % set the new dummy phase folder (create it if necessary)
                dummyPhaseFolder = fullfile(obj.rte.toolDirectory, ...
                    '02_ProblemDefinition', 'DummyPhaseDefinition', ...
                    'DummyPhase_0');
                newDummyPhaseFolder = fullfile(obj.rte.appFolder, 'Phase0');
                if ~exist(newDummyPhaseFolder, "dir")
                    copyfile(dummyPhaseFolder, newDummyPhaseFolder);
                end
                % add the folder to path and problem definition directories
                addpath(newDummyPhaseFolder);
                obj.rte.problemDefinitionDirs = [obj.rte.problemDefinitionDirs, ...
                    newDummyPhaseFolder];

                % remove the DummyPhase_0 folder from path to avoid
                % clashing in adigator build files
                rmpath(dummyPhaseFolder);

                % instantiate the dummy phase manager
                obj.dummyPhaseManager = feval(obj.algorithmConfig.version.phaseManager, ...
                    dummyPhaseConfig, ...
                    obj.phaseManagerArray(1).nx, ...
                    phaseConfig{1}.nw, ...
                    newDummyPhaseFolder,[-1; 0; 0]);

                % log to screen the current application settings
                obj.logApplicationSettings();

            catch ME
                obj.rte.cleanupMatlabPath();
                diary off
                rethrow(ME);
            end

            % move back to application folder
            cd(obj.rte.appFolder);
        end

        % build method to initialize the required algorithm steps and
        % generate the wrapper function and partials files
        obj = build(obj, NameValueArgs)

        % method that performs a full HDDP run
        obj = run(obj)

        % method that performs a full HDDP run with the double trust
        % regions for the penalty parameter and control updates
        obj = runDoubleTrustRegions(obj)

        % method that performs a full HDDP run with the inner-outer trust
        % regions for the penalty parameter and control updates
        obj = runNestedTrustRegions(obj)

        function delete(obj)
            % APPLICATION class destructor

            % save the final computed solution
            obj.saveSolution(false);

            % save the full application object for further debugging
            startDir = pwd;
            cd(obj.rte.outputDirectory);
            save("application", "obj");
            cd(startDir);

            % cleanup the run time environment
            obj.rte.cleanupMatlabPath();

            % close all files
            fclose all;

            % clear global variables to avoid adigator and fevalsCount
            % issues
            clear global

            % close the parallel pool (commented for speed)
            delete(gcp('nocreate'));

            % splash screen
            cprintf('*blue', "\n");
            cprintf('*blue', "%%%%%%%%%%%%%%%%%%%%%%%%%%");
            cprintf('*blue', "%%%%%%%%%%%%%%%%%%%%%%%%%%");
            cprintf('*blue', "%%%%%%%%%%%%%%%%%%%%%%%%%% \n");
            cprintf('*blue', "%%%%%%%%%% HOIST application terminated %%%%%%%%%% \n");
            cprintf('*blue', "%%%%%%%%%%%%%%%%%%%%%%%%%%");
            cprintf('*blue', "%%%%%%%%%%%%%%%%%%%%%%%%%%");
            cprintf('*blue', "%%%%%%%%%%%%%%%%%%%%%%%%%% \n");
            cprintf('*blue', "\n");
            cprintf('*blue', "\n");
            fprintf(strcat(obj.rte.outputName, " session terminated on ", ...
                datestr(datetime("now")), ". \n"));
            diary off
        end

    end

    methods(Access = protected)

        files = getPhaseConfigFiles(~, appFolder)

        [phaseConfig, optimizationConfig] = instantiateConfigs(obj)

        obj = getRunTimeEnvironment(obj, outputFolderName)

        saveSolution(obj, isInitialGuess)

        storeIterateMetrics(obj, iterate)

        obj = updateIterationCounter(obj, p)

        obj = reInit(obj)

        logApplicationSettings(obj)

        logConvergenceMetrics(obj)

        appendHistory(obj)

        obj = updateSolution(obj, newPhaseArray, trialIterate)
    end

    methods (Static)

        function phaseDefaultObject = getDefaultPhase()
            % function that outputs the required default phase object
            % (workaround to the issues with array of user-defined classes
            % validation or conversions)

            config = ApplicationConfig();
            phaseDefaultObject = feval(config.version.phase);
        end


        function name = getOutputFolderName()
            % function that outputs the default folder name for the current
            % application

            % set the folder name as app name
            [~, name, ~] = fileparts(pwd);
            name = string(name);

            % check if the current application is a test case
            isTest = checkIfTestApplication();

            if ~isTest
                % append the date-time string
                date = datestr(datetime("now"));
                date = strrep(date, "-", "_");
                date = strrep(date, ":", "_");
                date = strrep(date, " ", "_");
                name = strcat(name, "--", date);
            end

            function isTest = checkIfTestApplication()
                % function that checks whether the current user path is a
                % child of the 05_Tests folder

                % Initialize the variable to check if '05_Tests' is found
                isTest = false;

                % Loop through parent directories to check for '05_Tests'
                currentPath = userpath;
                while true
                    % Get the parent directory
                    [parentDir, currentDirName] = fileparts(currentPath);

                    % Check if the current directory is '05_Tests'
                    if strcmp(currentDirName, '05_Tests')
                        isTest = true;
                        break;
                    end

                    % If we have reached the root directory, stop the loop
                    if isempty(parentDir) || strcmp(parentDir, currentPath)
                        break;
                    end

                    % Move up to the parent directory
                    currentPath = parentDir;
                end
            end
        end

    end

end

