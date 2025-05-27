function phaseArray = perform(obj, phaseArray)
% function that actually performs the numerical integration for
% the forward pass

% input validation
mustBeA(phaseArray, 'abstract_Phase');

% initialize the 'phase 0' dummy variables, noting
% that for the dummy phase, state, parameters and multipliers
% are set to be constant 0
dx = 0;
dw = 0;
dl = 0;

% loop over all phases
M = length(phaseArray);
for i = 1 : M

    % store the current phase objects
    currentPhase = phaseArray(i);
    phaseManager = currentPhase.phaseManager;
    plant = currentPhase.plant;
    stageUpdates = currentPhase.stageUpdates;
    multiplierUpdate = currentPhase.multiplierUpdate;
    parameterUpdate = currentPhase.parameterUpdate;
    [nx, nu, nw, ~, ~, ~] = phaseManager.getInputSizes();
    nX = nx + nu + nw;

    % set the current state derivative to the ode object
    currentOde = obj.settings.odeObject;
    augmentedStateDerivativeFunction = str2func(phaseManager.ft_file);
    timeCollocationFunction = str2func(phaseManager.tPoint_file);
    currentOde.ODEFcn = augmentedStateDerivativeFunction;

    % get the reference plant quantities
    tRef = plant.t;
    xRef = plant.x;
    uRef = plant.u;
    wRef = plant.w;
    lRef = plant.l;

    % - PARAMETERS UPDATE
    dw = parameterUpdate.computeUpdate(dx, dw, dl);
    w = wRef + dw;

    % - MULTIPLIERS UPDATE
    dl = multiplierUpdate.computeUpdate(dx, dw, dl);
    l = lRef + dl;

    % - CONTROL UPDATES
    nStages = plant.nStages;

    % update the initial conditions (and related deviation)
    % for the current phase
    x = feval(str2func(phaseManager.Gamma_file), w);
    dx = x - xRef(:, 1);

    % initalize the new plant solution
    Y = zeros(nX, nStages);
    tNew = zeros(1, nStages);
    X = [x; uRef(:, 1); w];
    for k = 1 : nStages-1

        % set the initial time using the non-updated augmented state
        tIn = timeCollocationFunction(k, X);

        % update the control
        du = stageUpdates{k}.computeUpdate(dx, dw, dl);
        u = uRef(:, k) + du;

        % assemble the augmented state and store it for
        % solution
        X = [x; u; w];
        Y(:, k) = X;

        % set the solution time span
        tEnd = timeCollocationFunction(k + 1, X);
        tNew(k) = tIn;

        % solve the stage integration problem
        currentOde.InitialValue = X;
        currentOde.InitialTime = tIn;
        S = currentOde.solve(tEnd);

        % update initial condition (and related deviation) for
        % the next stage update
        x = S.Solution(1:nx, end);
        dx = x - xRef(:, k + 1);

    end
    % set the last stage solution (no integration required)
    Y(:, k + 1) = [x; u; w];
    tNew(k + 1) = timeCollocationFunction(k + 1, [x; u; w]);

    % TODO: implement here the routine for the forward pass on
    % extra stages appended to the end of the trajectory

    % assign the new plant object to the current phase
    newPlant = Plant(tNew, Y(1: nx, :), Y(nx+1: nx + nu, :), ...
        w, l);
    phaseArray(i) = phaseArray(i).setPlant(newPlant);

end
end