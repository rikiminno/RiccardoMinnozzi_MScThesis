classdef RunTimeEnvironment
    % class defining the folder structure required to define the
    % application run time environment
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties (GetAccess = public, SetAccess = protected)
        appPath
        solverPath
        outputName
        outputPath
        phasePaths
    end

    methods
        function rte = RunTimeEnvironment(outputName)
            % RUNTIMEENVIRONMENT constructor

            % only construct if outputFolder is defined
            if nargin == 1

                % store folder structure
                rte.appPath     = pwd;
                rte.solverPath  = findSolverPath(); cd(rte.appPath);

                % get the paths to the problem phase folders
                dirList = dir('Phase*');
                counter = 1;
                for i = 1:length(dirList)
                    if dirList(i).isdir
                        % add phase folders to path and to list of problem
                        % definition folders
                        phasePaths(counter) = fullfile(rte.appPath, dirList(i).name);
                        addpath(phasePaths(counter));
                        counter = counter + 1;
                    end
                end

                % trigger an error when there are no phases
                if counter == 1
                    fclose all;
                    diary off
                    error("The current application does not contain problem definition folders.");
                end
                rte.phasePaths = phasePaths;

                % create the output folder and add it to path
                cd(userpath); rte.outputPath = fullfile(userpath, outputName);
                if ~exist(outputName, "dir")
                    mkdir(outputName);
                    addpath(outputName);
                    fprintf(strcat("Application outputs are saved to the directory:\n", ...
                        strrep(fullfile(userpath, outputName), filesep, "\\"), ".\n"));
                else
                    error(strcat("Tried to set the application output directory to:\n", ...
                        outputName, "\nbut the directory already exists."));
                end

            end
        end

        function cleanupMatlabPath(rte)
            % function that removes from the MATLAB path all folders added
            % when instantiating an application

            % turn off rmpath warning
            warning('off', 'MATLAB:rmpath:DirNotFound');

            % remove the phase definition folders
            for i = 1:length(rte.phasePaths)
                rmpath(genpath(rte.phasePaths(i)));
            end

            % remove the output directory
            rmpath(genpath(rte.outputPath));

            % add the DummyPhase_0 folder back to path to allow re-building
            % future applications
            addpath(fullfile(rte.solverPath, "02_ProblemDefinition", "DummyPhaseDefinition", ...
                "DummyPhase_0"));

            % turn on rmpath warning
            warning('on', 'MATLAB:rmpath:DirNotFound');
        end

        function removeWrapperFolder(rte)
            % function that removes all build folders from the current
            % application phase folders

            % close all open files
            fclose all;

            % move to each Phase folder
            dirList = dir(fullfile(rte.appPath, 'Phase*'));
            for i = 1:length(dirList)
                if dirList(i).isdir
                    currentPhase = dirList(i).name;
                    cd(currentPhase);

                    % remove the build folders
                    try
                        warning('off', 'MATLAB:RMDIR:RemovedFromPath');
                        rmdir('build', 's');
                        warning('on', 'MATLAB:RMDIR:RemovedFromPath');
                        fprintf(strcat("✅ ", currentPhase, ": 'build' folder removed.\n"));
                    catch
                        fprintf(strcat("❌ The 'build' folder was not removed from:\n ", currentPhase, ...
                            ".\n"));
                    end
                    % move back to application folder
                    cd(rte.appPath);
                end
            end

            % move back to application folder
            cd(rte.appPath);
        end

    end
end

%% utilities

function solverPath = findSolverPath()
% function that goes up until the name of the current folder is that of the
% solver

% get the name of the current folder
[~, folderName] = fileparts(pwd);

while ~strcmp(folderName, "00_Applications")
    cd("..");
    [~, folderName] = fileparts(pwd);
end
cd("..");
solverPath = pwd;
end

