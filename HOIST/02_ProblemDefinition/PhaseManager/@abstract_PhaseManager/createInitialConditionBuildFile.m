function obj = createInitialConditionBuildFile(obj)
% function that creates the initial condition wrapper function file

% get the phase number and the inputs dimensions
i = obj.ID(2);

% create the initial condition wrapper file
obj.Gamma_file = strcat("Gamma_", string(i));
id = fopen(strcat(obj.Gamma_file, ".m"), "w+");
fprintf(id, strcat("function x0 = ", obj.Gamma_file, ...
    "(w) \n"));
commentStr = strcat("%% Initial condition wrapper function for phase ", ...
    string(i), ",\n%% automatically generated by the PhaseManager class on ", ...
    datestr(datetime("now")), "\n");
fprintf(id, commentStr);
% set the output
fprintf(id, strcat("x0 = ", obj.initialConditionFile, "(w); \n"));
fprintf(id, "end");
fclose(id);

end

