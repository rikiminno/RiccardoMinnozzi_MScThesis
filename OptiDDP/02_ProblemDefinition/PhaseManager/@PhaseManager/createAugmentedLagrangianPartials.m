function obj = createAugmentedLagrangianPartials(obj)
% function that generates the augmented lagrangian partial
% files

% get inputs
[nx, nu, nw, nl, nxp, nwp] = obj.getInputSizes();

function_type = 'augmented_lagrangian';
obj.phit_I_file = generate_function_partials(obj.phit_file, ...
    'I', function_type, nx, nu, nw, nl, nxp, nwp);
obj.phit_II_file = generate_function_partials(obj.phit_I_file, ...
    'I', function_type, nx, nu, nw, nl, nxp, nwp);
end

