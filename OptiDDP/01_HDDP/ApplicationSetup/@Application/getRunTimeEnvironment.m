function obj = getRunTimeEnvironment(obj, outputName)
% function that defines the full runtime environment for the application,
% settings its output directories

% save the app and tool directories
appFolder = pwd;
moveToHoistFolder(); toolDirectory = pwd;
cd(toolDirectory);

% set the output folder name
cd(userpath);

% get the problem definition folders
dirList = dir(fullfile(appFolder, 'Phase*'));
counter = 1;
for i = 1:length(dirList)
    if dirList(i).isdir
        % add phase folders to path and to list of problem definition
        % folders
        problemDefinitionDirs(counter) = fullfile(appFolder, string(dirList(i).name));
        addpath(problemDefinitionDirs(counter));
        counter = counter + 1;
    end
end

% create the output folder and add it to path
if ~exist(outputName, "dir")
    mkdir(outputName);
    addpath(outputName);
    cprintf('SystemCommand', strcat("Application outputs are saved to the directory: ", ...
        strrep(fullfile(userpath, outputName), filesep, "\\"), ". \n"));
else
    error(strcat("Tried to set the application output directory", ...
        " to ", outputName, ", but the directory already exists."));
end

% create the phase output directories
cd(outputName);
for i = 1:counter-1

    [~, currentPhase,~] = fileparts(problemDefinitionDirs(i));
    if ~strcmp(currentPhase, "Phase0"), mkdir(currentPhase); end
end

if counter == 1
    fclose all;
    diary off
    error("The current application does not contain problem definition folders.");
end

% store all the required folders in the rte structure
obj.rte.appFolder               = appFolder;
obj.rte.toolDirectory           = toolDirectory;
obj.rte.outputName              = outputName;
obj.rte.outputDirectory         = fullfile(userpath, outputName);
obj.rte.problemDefinitionDirs   = problemDefinitionDirs;

% move back to application folder
cd(appFolder);
end

function moveToHoistFolder()
% function that goes up until the name of the current folder is that of the
% HOIST tool

% get the name of the current folder
[~, folderName] = fileparts(pwd);

while ~strcmp(folderName, "HOIST")
    cd("..");
    [~, folderName] = fileparts(pwd);
end
end

% DEPRECATED
% function toolPath = findHoistFolder(fullPath)
% % Split the input path into its components
% pathComponents = strsplit(fullPath, filesep);
%
% % Find the index of the 'HOIST' folder
% hoistIndex = find(strcmp(pathComponents, 'HOIST'), 1);
%
% % If 'HOIST' folder is found, construct the result path
% if ~isempty(hoistIndex)
%     toolPath = fullfile(pathComponents{1:hoistIndex});
% else
%     error('The folder ''HOIST'' was not found in the specified path.');
% end
% end
