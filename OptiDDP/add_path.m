function add_path(desired_user_path)
% Function to add the required folders to path
%
% authored by: Riccardo Minnozzi, 05/2024

toolDirectory = pwd;
toolName = 'OptiDDP';

%% Update the repository

% flags to allow the git logic to auto update and autoswitch branch
autoUpdate = true;
autoSwitch = true;

if autoUpdate
    % start prints
    fprintf('\nPulling latest changes from GitHub ...\n');

    [statusRemote, ~] = system('git ls-remote --exit-code origin');
    if statusRemote, fprintf('❌ Could not establish a remote connection to git origin.\n'); else
        % Check current branch
        [~, currentBranch] = system('git rev-parse --abbrev-ref HEAD');
        currentBranch = strtrim(currentBranch);

        % move to main branch
        if ~strcmp(currentBranch, "main")
            if autoSwitch
                % Check if working directory is clean
                [~, statusOutput] = system('git status --porcelain');
                if ~isempty(strtrim(statusOutput)), error('Uncommitted changes detected.\n Cannot auto-switch to main branch safely.\n Commit your changes or set the autoSwitch flag to flase.\n'); end
                fprintf('⚠️ Not on main branch (current branch: %s).\n Switching to main ...\n', currentBranch);
                [st, out] = system('git checkout main');
                if st, error('Failed to switch to main branch, git message:\n%s', out); end
            else
                fprintf('⚠️ You are on branch: "%s".\n Consider switching to "main" or set the autoSwitch flag to true.\n', currentBranch);
            end
        end

        % Pull latest changes from main branch
        fprintf('🔄 Pulling latest changes from main...\n');
        [status, output] = system('git pull origin main');
        if ~status, fprintf('✅ Git pull successful.\n');
        else, error('❌ Git pull failed, git message:\n%s', output); end
    end
end

%% Restore default paths

% removes adigator and solver from MATLAB path
warning('off', 'MATLAB:rmpath:DirNotFound');
rmpath(genpath(toolDirectory));
rmpath(genpath(fullfile(toolDirectory, '..', 'adigator')));

% set the user path variable
if nargin == 0, userpath("reset");
else, userpath(desired_user_path);
end

% start prints
fprintf(['Removed ', toolName,' and adigator directories from path, adding only required modules.\n']);
warning('on', 'MATLAB:rmpath:DirNotFound');

%% Add the required optimization tool modules

% define the required directory module
reqDir(1)   = string(fullfile(toolDirectory, '01_HDDP'));
reqDir(2)   = string(fullfile(toolDirectory, '02_ProblemDefinition'));
reqDir(3)   = string(fullfile(toolDirectory, '03_Solvers'));
reqDir(4)   = string(fullfile(toolDirectory, '04_Utilities'));

% add them and their sub-directories to path
for i = 1:length(reqDir)
    addpath(genpath(reqDir(i)));
end

% TODO: adjust this to comply with the new test environment
% separately add the tests folder to path (no subfolders)
addpath(fullfile(toolDirectory, "05_Tests"));

fprintf(['✅ Added all ', toolName,' directories to path.\n']);

%% Add and initialize adigator

addpath(fullfile(toolDirectory, '..', 'adigator'));
cd(fullfile(toolDirectory, '..', 'adigator'));
startupadigator
cd(toolDirectory);

%% Create/overwrite up structure

% check if the userpath directory is set to the default one
homedir     = char(java.lang.System.getProperty('user.home'));
defaultDir  = fullfile(homedir, 'Documents', 'MATLAB');

if strcmp(userpath, defaultDir)
    % change the default path to a new directory inside the tool's folder

    outputDirectoryName = '99_Outputs';

    if ~exist(outputDirectoryName, 'dir')
        mkdir(toolDirectory, outputDirectoryName);
        cprintf('SystemCommands', strcat("Created output directory at ", ...
            outputDirectoryName,'.\n'));
    end
    userpath(fullfile(toolDirectory, outputDirectoryName));
    cprintf('SystemCommands', strcat("Set ", outputDirectoryName, ...
        ' as the default userpath directory: all optimization outputs are saved here. \n'));

end