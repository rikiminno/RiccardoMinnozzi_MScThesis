function obj = createPathConstraintsPartials(obj)
% function that creates the partial files for the equality path constraints
% for the current phase using adigator

% store the dimensions of the point object
[nx, nu, nw, nl, nxp, nwp] = obj.getInputSizes();
nX = nx + nu + nw;
mEq = obj.mEq;

% generate equality constraint partials
function_type = 'path_constraint';
obj.cEq_X_file = generate_function_partials(obj.cEq_file, ...
    'X', function_type, nx, nu, nw, nl, nxp, nwp);
obj.cEq_XX_file = generate_function_partials(obj.cEq_X_file, ...
    'X', function_type, nx, nu, nw, nl, nxp, nwp);
% add the reshape to tensor line to the cEq_XX file
filename = strcat(obj.cEq_XX_file, ".m");
lines = readlines(filename);
id = fopen(filename, "w");
lines(end) = strcat("cEq_XX = reshapeToTensor(cEq_XX, ", ...
    string(mEq), ", ", string(nX), ", ", string(nX), "); end");
writelines(lines, filename);
fclose(id);
end