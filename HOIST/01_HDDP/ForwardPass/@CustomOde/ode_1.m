function S = ode_1(obj, t)
% function implementing the Euler forward integration routine for the
% current solver object

% retrieve object properties
x0 = obj.InitialValue;
t0 = obj.InitialTime;
dt = obj.StepSize;

% initialize solution vectors
nSteps = round((t-t0)/dt);
Y = zeros(size(x0, 1), nSteps + 1);
tSol = zeros(1, nSteps + 1);

% start loop until full solution is achieved
Y(:, 1) = x0;
tSol(1) = t0;
for i = 1:nSteps

    % store current quantities
    currentTime = tSol(i);
    x = Y(:, i);

    % compute derivative
    dxdt = feval(obj.ODEFcn, currentTime, x);

    % store solution
    Y(:, i + 1) = x + dt * dxdt;
    tSol(i + 1) = t + dt;
end

% assemble solution structure
S.Solution = Y;
S.Time = tSol;
S.fevals = nSteps;

end

