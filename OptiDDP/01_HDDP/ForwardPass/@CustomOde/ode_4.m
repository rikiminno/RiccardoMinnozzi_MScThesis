function S = ode_4(obj, t)
% ode 4 wrapper function for the Matlab fixed step ode4 solver

% retrieve object properties
x0 = obj.InitialValue;
t0 = obj.InitialTime;
dt = obj.StepSize;

% initialize the tSpan vector
tSpan = reshape(t0 : dt : t, 1, []);

% run the matlab ode4 routine
Y = ode4(obj.ODEFcn, tSpan, x0);

% assign solution structure
S.Solution = Y';
S.Time = tSpan;
S.fevals = 4 * length(tSpan);
end

