function S = ode_8(obj, t)
% ode 8 wrapper function for the Matlab fixed step ode8 solver

% retrieve object properties
x0 = obj.InitialValue;
t0 = obj.InitialTime;
dt = obj.StepSize;

% initialize the tSpan vector
tSpan = reshape(t0 : dt : t, 1, []);

% run the matlab ode8 routine
Y = ode8(obj.ODEFcn, tSpan, x0);

% assign solution structure
S.Solution = Y';
S.Time = tSpan;
S.fevals = 8 * length(tSpan);
end