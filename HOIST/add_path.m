function add_path(desired_user_path)
% Function to add the required folders to path
%
% authored by: Riccardo Minnozzi, 05/2024

toolDirectory = pwd;

%% Restore default paths

% removes adigator and HOIST from MATLAB path
warning('off', 'MATLAB:rmpath:DirNotFound');

rmpath(genpath(toolDirectory));
rmpath(genpath(fullfile(toolDirectory, '..', 'adigator')));
if nargin == 0
    userpath("reset");
else
    userpath(desired_user_path);
end
fprintf('Removed HOIST and adigator directories from path, adding only required modules.\n');
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

% separately add the tests folder to path (no subfolders)
addpath(fullfile(toolDirectory, "05_Tests"));

cprintf('SystemCommands','Added all optimization tool directories to path.\n');

%% Set default options for plotting

% Set default figure properties
% set(0, 'DefaultFigureColor', 'w');
set(0, 'DefaultFigurePosition', [100, 100, 800, 600]);
% set(0, 'DefaultFigureColormap',cbrewer2('seq','YlOrRd',64));

% Set default axes properties
% set(0, 'DefaultAxesColorOrder',cbrewer2('qual','Set1',9));
set(0, 'DefaultAxesXGrid', 'on');
set(0, 'DefaultAxesYGrid', 'on');
set(0, 'DefaultAxesZGrid', 'on');
% set(0, 'DefaultAxesFontSize', 14);
% set(0, 'DefaultAxesFontWeight', 'bold');
% set(0, 'DefaultAxesLineWidth', 1.2);
% set(0, 'DefaultAxesBox', 'on');
% set(0, 'DefaultAxesGridLineStyle', '--');
% set(0, 'DefaultAxesTickDir', 'out');

% Set default line properties
set(0, 'DefaultLineLineWidth', 2);
set(0, 'DefaultLineMarkerSize', 8);

% This script changes all interpreters from tex to latex. 
list_factory = fieldnames(get(groot,'factory'));
index_interpreter = find(contains(list_factory,'Interpreter'));
for i = 1:length(index_interpreter)
    default_name = strrep(list_factory{index_interpreter(i)},'factory','default');
    set(groot, default_name,'latex');
end

% 
% % Set default legend properties
% % set(0, 'DefaultLegendFontSize', 12);
% set(0, 'DefaultLegendLocation', 'best');

% Set default text properties
set(0, 'DefaultTextFontSize', 9);
set(0, 'DefaultTextFontWeight', 'normal');

% Set font sizes at the root level for MATLAB graphics
set(groot, 'DefaultAxesFontSize', 9);        % Axis tick labels
set(groot, 'DefaultAxesTitleFontSizeMultiplier', 1.2); % Axis title size relative to tick labels
set(groot, 'DefaultLegendFontSize', 9);       % Legend font size
set(groot, 'DefaultColorbarFontSize', 9);     % Colorbar font size
set(groot, 'DefaultTextFontSize', 9);         % General text font size (e.g., sgtitle, labels)
set(0,'defaultfigurecolor', [1 1 1]);          % default figure background to white

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