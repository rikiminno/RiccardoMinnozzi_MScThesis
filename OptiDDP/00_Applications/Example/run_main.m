clear all
close all
clc

% define the application
app = Application();

% build the application files
app = app.build("startFlag","hotStart");

% run the optimization
app = app.run();

% plot and save summary figures
% plot_solution(app.rte.outputName);

% cleanup adigator generated files
% app.rte.removeWrapperFolder();