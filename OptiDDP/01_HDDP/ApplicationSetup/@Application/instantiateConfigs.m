function obj = instantiateConfigs(obj)
% function that instantiates the phase and optimization config
% objects

% retrieve the instantiated phase configuration files list
appFolder = obj.rte.appFolder;
phaseConfigFiles = obj.getPhaseConfigFiles(appFolder);

% evaluate the optimization and phase config files
optimizationConfig = ApplicationConfig();
M = length(phaseConfigFiles);
for i = 1:M
    % add phase folder to path
    phaseFolder = fullfile(appFolder, strcat("Phase", string(i)));
    addpath(phaseFolder);

    % instantiate config
    phaseConfig{i} = feval(phaseConfigFiles(i));

end

% save the auxiliary data to the output folder
startDir = pwd;
cd(obj.rte.outputDirectory);
data = phaseConfig{M}.data;
save("auxiliaryData", "data");
cd(startDir);

% create the parallel pool
if optimizationConfig.useParPool && isempty(gcp("nocreate"))
    pool = parpool(optimizationConfig.nWorkers, "IdleTimeout", 240);
end

% assign output properties
obj.phaseConfig = phaseConfig;
obj.algorithmConfig = optimizationConfig;

end

