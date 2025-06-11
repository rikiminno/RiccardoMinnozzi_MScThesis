function obj = createStageCollocationPartials(obj)
% function that automatically creates the partials of the stage collocation
% control function using adigator

% store the dimensions of the point object
[nx, nu, nw, nl, nxp, nwp] = obj.getInputSizes();

% generate stage size control partials
function_type = 'stage_collocation';
obj.tPoint_X_file = generate_function_partials(obj.tPoint_file , ...
    'X', function_type, nx, nu, nw, nl, nxp, nwp);
obj.tPoint_XX_file = generate_function_partials(obj.tPoint_X_file, ...
    'X', function_type, nx, nu, nw, nl, nxp, nwp);
end

