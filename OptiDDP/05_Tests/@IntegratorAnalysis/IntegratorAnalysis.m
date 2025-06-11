classdef IntegratorAnalysis < matlab.unittest.TestCase
    % class implementing the analysis of the integrator order, step sizes
    % and/or tolerances on a specified application
    %
    % authored by Riccardo Minnozzi, 07/2024


    properties (SetAccess = protected, GetAccess = public)
        % specific app
        appFolder
        analysisResultsFolder

        % tolerances
        absTols
        relTols
    end

    properties (Access = protected)
        % folder structure
        resultsFolder
        originalUp
        startDir
    end

    methods
        function obj = IntegratorAnalysis(application, absTols, relTols)
            % INTEGRATORANALYSIS constructor

            % TODO: add a check to confirm that absTols and relTols are the
            % same length

            % assign inputs
            obj.appFolder = fullfile(pwd, application);
            obj.absTols = absTols;
            obj.relTols = relTols;

            % store folder structure
            obj.startDir = pwd;
            obj.resultsFolder = fullfile(pwd, "LastTestResults");
            obj.analysisResultsFolder = fullfile(obj.resultsFolder, application);
            obj.originalUp = userpath;

        end

        [timeVec, absErr, relErr] = compute_error_metrics(obj, solA, solB)

        plotToleranceAnalysis(obj, solArray)

        sol = assembleSolution(obj)

        saveCurrentFigure(obj, filename)

    end

    methods(Test)
        % Test methods

        function stepSizeAnalysis_FS(obj)
            % function to perform the step size analysis (only on fixed
            % step integrators)

            % NOTE: matlab does not allow fixed step integrators, therefore
            % this analysis should be only implemented for the customOde
            % objects
        end

        function tolAnalysis(obj)
            % function to perform the tolerance analysis (only on variable
            % step integrators)

            % move to the application folder
            cd(obj.appFolder);

            % store the default tolerances (from the application config
            % class)
            [absTol_init, relTol_init, ~] = getOdeObjectProperties();

            % set the current tolerances (modifying the application config
            % file)
            absTol_array = obj.absTols;
            relTol_array = obj.relTols;

            % change the run main to only create a new initial guess
            set_parameter("app.run();", "comment", "run_main.m");

            for i = 1:length(absTol_array)
                % loop over all tolerances (abs and rel together)

                % set the current tolerances
                absTol = absTol_array(i);
                relTol = relTol_array(i);
                set_parameter("odeObject.AbsoluteTolerance", string(absTol), ...
                    "ApplicationConfig.m");
                set_parameter("odeObject.RelativeTolerance", string(relTol), ...
                    "ApplicationConfig.m");

                % hot start the application and generate its initial guess
                run_main("hotStart");

                % store the time and state initial guess for each phase
                sol(i) = obj.assembleSolution();
            end

            % reset the application config and run main
            set_parameter("odeObject.AbsoluteTolerance", string(absTol_init), ...
                "ApplicationConfig.m");
            set_parameter("odeObject.RelativeTolerance", string(relTol_init), ...
                "ApplicationConfig.m");
            set_parameter("app.run();", "uncomment", "run_main.m");

            % once all the solutions have been generated, post process them
            obj.plotToleranceAnalysis(sol);

        end
    end

end

function [absTol, relTol, solver] = getOdeObjectProperties()
% function that retrieves the tolerances from the application config class,
% assuming the current directory is an application directory

config = ApplicationConfig();

absTol = config.odeObject.AbsoluteTolerance;
relTol = config.odeObject.RelativeTolerance;
solver = config.odeObject.Solver;

end