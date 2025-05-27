function obj = createInitialConditionsPartials(obj)
% function to generate the initial condition partial files

% store the dimensions of the point object
[nx, nu, nw, nl, nxp, nwp] = obj.getInputSizes();

function_type = 'initial_condition';
obj.Gamma_w_file = generate_function_partials(obj.Gamma_file, ...
    'w', function_type, nx, nu, nw, nl, nxp, nwp);
obj.Gamma_ww_file = generate_function_partials(obj.Gamma_w_file, ...
    'w', function_type, nx, nu, nw, nl, nxp, nwp);
% add the reshape to tensor line to the file
filename = strcat(obj.Gamma_ww_file, ".m");
lines = readlines(filename);
id = fopen(filename, "w");
lines(end) = strcat("x0_ww = reshapeToTensor(x0_ww, ", ...
    string(nx), ", ", string(nw), ", ", string(nw), "); end");
writelines(lines, filename);
fclose(id);
end