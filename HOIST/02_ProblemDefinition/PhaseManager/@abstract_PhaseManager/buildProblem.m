function obj = buildProblem(obj)
% function that creates the build files directory and the
% wrapper functions for the problem definition functions

% store the starting directory
startDir = pwd;

% create the build directory
if ~exist(obj.buildFolder, "dir")
    mkdir(obj.buildFolder);
else
    error("An attempt was made at creating a new 'build' folder " + ...
        ", but the folder already exists. Remove the folder or " + ...
        "hot-start the application to avoid generating new " + ...
        "wrapper problem definition files.");
end
addpath(obj.buildFolder);
cd(obj.buildFolder);

obj = obj.createRunningCostBuildFile();
obj = obj.createInitialConditionBuildFile();
obj = obj.createAugmentedStateDerivativeBuildFile();
obj = obj.createAugmentedLagrangianBuildFile();
obj = obj.createPathConstraintsBuildFiles();
obj = obj.createConstraintsBuildFile();
obj = obj.createStageCollocationBuildFile();

% go back to starting directory
cd(startDir);
end