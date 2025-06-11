function phaseArray = buildInitialGuess(obj, phaseArray)
% method to fully define the initial plant structure of a phase
% object from the provided initial guesses

% validate input
mustBeA(phaseArray, 'abstract_Phase');

for i = 1:length(phaseArray)
    % loop over all phases

    % get the current phase quantities
    currentPhase = phaseArray(i);
    currentPhaseManager = currentPhase.phaseManager;

    % set the current state derivative to the ode object
    currentOde = obj.settings.odeObject;
    augmentedStateDerivativeFunction = currentPhaseManager.ft_file;
    currentOde.ODEFcn = str2func(augmentedStateDerivativeFunction);

    % initialize the plant structure using the pre-defined plant
    % already available from the Phase object
    plant = currentPhase.plant;
    nStages = plant.nStages;
    [nx, nu, nw, ~, ~, ~] = currentPhaseManager.getInputSizes();
    nX = nx + nu + nw;
    Y = zeros(nX, nStages);

    % store the user provided initial guess quantities
    tGuess = plant.t;
    uGuess = plant.u;
    wGuess = plant.w;
    lGuess = plant.l;

    % set the initial augmented state condition and store it in the
    % plant
    x = feval(currentPhaseManager.Gamma_file, wGuess);
    w = wGuess;

    % integrate each stage by using the updated controls
    for k = 1 : nStages - 1

        % get the updated controls and time interval
        t = tGuess(k);
        u = uGuess(t, x, w);

        % assemble the augmented state vector and save it to plant
        X = [x; u; w];
        Y(:, k) = X;

        % solve the stage integration problem
        currentOde.InitialValue = X;
        currentOde.InitialTime = t;
        S = currentOde.solve(tGuess(k+1));

        % update the initial state for the next stage
        x = S.Solution(1:nx, end);
    end
    % set the final stage (no integration required)
    u = uGuess(tGuess(nStages), x, w);
    Y(:, nStages) = [x; u; w];

    % assign the new plant object to the current phase
    newPlant = Plant(tGuess, Y(1: nx, :), Y(nx+1: nx + nu, :), ...
        wGuess, lGuess);
    phaseArray(i) = phaseArray(i).setPlant(newPlant);
end
end