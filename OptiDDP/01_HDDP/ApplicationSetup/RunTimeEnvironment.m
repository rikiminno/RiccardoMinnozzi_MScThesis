classdef RunTimeEnvironment
    % class defining the folder structure required to define the
    % application run time environment
    %
    % authored by Riccardo Minnozzi, 06/2024

    properties
        appFolder
        toolDirectory
        outputName
        outputDirectory
        problemDefinitionDirs
    end

    methods
        function obj = RunTimeEnvironment()
            % RUNTIMEENVIRONMENT constructor
        end

        function cleanupMatlabPath(obj)
            % function that removes from matlab path the directories added by the
            % application object during instantiation

            % turn off rmpath warning
            warning('off', 'MATLAB:rmpath:DirNotFound');

            % remove the problem definition folders
            for i = 1:length(obj.problemDefinitionDirs)
                rmpath(genpath(obj.problemDefinitionDirs(i)));
            end

            % remove the output directory
            rmpath(genpath(obj.outputDirectory));

            % add the DummyPhase_0 folder back to path for future
            % application builds
            addpath(fullfile(obj.toolDirectory, "02_ProblemDefinition", "DummyPhaseDefinition", ...
                "DummyPhase_0"));

            % turn on rmpath warning
            warning('on', 'MATLAB:rmpath:DirNotFound');
        end

        function removeWrapperFolder(obj)
            % function that looks for the phase folders in the current application
            % folder and removes all 'build' folders

            fclose all;

            % move to each Phase folder
            applicationFolder = obj.appFolder;
            dirList = dir(fullfile(applicationFolder, 'Phase*'));
            for i = 1:length(dirList)
                if dirList(i).isdir
                    currentPhaseFolder = dirList(i).name;
                    cd(currentPhaseFolder);

                    % remove the build folders
                    try
                        warning('off', 'MATLAB:RMDIR:RemovedFromPath');
                        rmdir('build', 's');
                        warning('on', 'MATLAB:RMDIR:RemovedFromPath');
                    catch
                        cprintf('SystemCommand', strcat("The 'build'", ...
                            " folder was not removed from the ", currentPhaseFolder, ...
                            " directory.\n"));
                    end
                    % move back to application folder
                    cd(applicationFolder);
                end
            end

            % move back to application folder
            cd(applicationFolder);
        end

    end
end

