function obj = createConstraintsPartials(obj)
% function that creates the constraints partial functions

% get inputs
[nx, nu, nw, nl, nxp, nwp] = obj.getInputSizes();
nI = nx + nw + nl + nxp + nwp;

% set the size of the current constraint function
nPsi = obj.nPsi;

function_type = 'constraints';
obj.Psi_I_file = generate_function_partials(obj.Psi_file, ...
    'I', function_type, nx, nu, nw, nl, nxp, nwp);
obj.Psi_II_file = generate_function_partials(obj.Psi_I_file, ...
    'I', function_type, nx, nu, nw, nl, nxp, nwp);
% add the reshape to tensor line to the file
filename = strcat(obj.Psi_II_file, ".m");
lines = readlines(filename);
id = fopen(filename, "w");
lines(end) = strcat("Psi_II = reshapeToTensor(Psi_II, ", ...
    string(nPsi), ", ", string(nI), ", ", string(nI), "); end");
writelines(lines, filename);
fclose(id);
end

