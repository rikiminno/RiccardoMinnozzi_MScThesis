function S = ode_5(obj, t)
% ode 5 wrapper function for the Matlab fixed step ode4 solver

% retrieve object properties
x0 = obj.InitialValue;
t0 = obj.InitialTime;
dt = obj.StepSize;

% initialize the tSpan vector
tSpan = reshape(t0 : dt : t, 1, []);

% run the matlab ode5 routine
Y = ode5(obj.ODEFcn, tSpan, x0);

% assign solution structure
S.Solution = Y';
S.Time = tSpan;
S.fevals = 5 * length(tSpan);
end

