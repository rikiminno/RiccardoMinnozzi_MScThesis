function obj = createRunningCostPartials(obj)
% function that generates the running cost partial files

% get inputs
[nx, nu, nw, nl, nxp, nwp] = obj.getInputSizes();

function_type = 'running_cost';
obj.L_X_file = generate_function_partials(obj.L_file, ...
    'X', function_type, nx, nu, nw, nl, nxp, nwp);
obj.L_XX_file = generate_function_partials(obj.L_X_file, ...
    'X', function_type, nx, nu, nw, nl, nxp, nwp);
end