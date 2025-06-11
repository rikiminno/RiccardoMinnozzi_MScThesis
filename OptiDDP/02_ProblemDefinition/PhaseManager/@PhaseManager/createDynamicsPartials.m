function obj = createDynamicsPartials(obj)
% function to generate the augmented state derivative partial
% files

% store the dimensions of the point object
[nx, nu, nw, nl, nxp, nwp] = obj.getInputSizes();
nX = nx+nu+nw;

function_type = 'augmented_state_derivative';
obj.ft_X_file = generate_function_partials(obj.ft_file, ...
    'X', function_type, nx, nu, nw, nl, nxp, nwp);
obj.ft_XX_file = generate_function_partials(obj.ft_X_file, ...
    'X', function_type, nx, nu, nw, nl, nxp, nwp);
% add the reshape to tensor line to the file
filename = strcat(obj.ft_XX_file, ".m");
lines = readlines(filename);
id = fopen(filename, "w");
lines(end) = strcat("Xdot_XX = reshapeToTensor(Xdot_XX, ", ...
    string(nX), ", ", string(nX), ", ", string(nX), "); end");
writelines(lines, filename);
fclose(id);

obj.ft_t_file = generate_function_partials(obj.ft_file, ...
    't', function_type, nx, nu, nw, nl, nxp, nwp);
end