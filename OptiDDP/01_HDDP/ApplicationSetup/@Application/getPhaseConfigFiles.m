function files = getPhaseConfigFiles(~, appFolder)
% function to retrieve all the phase configuration classes
% defined in the application folder

% Check if the folder exists
if ~isfolder(appFolder)
    error('The specified folder does not exist.');
end

% Get a list of all files in the folder
filePattern = fullfile(appFolder, 'PhaseConfig_*'); % Pattern to match files named "PhaseConfig_1"
fileList = dir(filePattern);

% Filter out directories
countFiles = 1;
for i = 1:length(fileList)
    if ~fileList(i).isdir
        currentFile = fileList(i).name;
        files(countFiles) = string(currentFile(1:end-2));
        countFiles = countFiles + 1;
    end
end
end

