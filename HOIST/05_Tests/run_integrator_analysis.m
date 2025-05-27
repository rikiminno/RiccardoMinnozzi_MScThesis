clear all
close all
clc

% set the tolerances to analyze
tols = [1e-12; 1e-10; 1e-8; 1e-6; 1e-4; 1e-2];
tols = [1e-15; 1];

% instance of the integrator analysis object
analysisObject = IntegratorAnalysis("Test_R_2DI_L", tols, tols);

% run the integrator analysis
analysisObject.run;