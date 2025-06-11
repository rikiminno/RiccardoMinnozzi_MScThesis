function S = ode_45(obj, t)
% function used as a wrapper for MATLAB's ode45 integrator (used for
% backwards compatibility with versions older than 2023b)

% retrieve object properties
x0 = obj.InitialValue;
t0 = obj.InitialTime;

% set the integration options
nvArgs = {};
if ~isempty(obj.AbsoluteTolerance)
    nvArgs = [nvArgs, {'AbsTol', obj.AbsoluteTolerance}];
end
if ~isempty(obj.RelativeTolerance)
    nvArgs = [nvArgs, {'RelTol', obj.RelativeTolerance}];
end
opts = odeset(nvArgs{:});

% run the matlab ode45 routine
Sol = ode45(obj.ODEFcn, [t0 t], x0, opts);

% assemble solution structure
S.Solution = Sol.y;
S.Time = Sol.x;
S.fevals = Sol.stats.nfevals;
end

