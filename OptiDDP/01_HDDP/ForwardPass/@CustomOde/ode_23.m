function S = ode_23(obj, t)
% function used as a wrapper for MATLAB's ode23 integrator (used for
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

% run the matlab ode23 routine
Sol = ode23(obj.ODEFcn, [t0 t], x0, opts);

% assemble solution structure
S.Solution = Sol.y;
S.Time = Sol.x;
S.fevals = Sol.stats.nfevals;
end

