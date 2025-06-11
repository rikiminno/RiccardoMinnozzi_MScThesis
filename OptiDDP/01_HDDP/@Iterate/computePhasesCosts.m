function obj = computePhasesCosts(obj, phaseArray)
% function that computes the cost metrics for each phase of the iterate
% object

% - COMPUTE THE METRICS FOR THE CURRENT ITERATE
% initialize cost metrics
M = length(phaseArray);
obj.Lsum = zeros(M, 1);
obj.phi = zeros(M, 1);
obj.Psi = cell(M, 1);
obj.Psi_squared = zeros(M, 1);
obj.phit = zeros(M, 1);
obj.maxPathConstraintViolation = 0;

for i = 1:M
    % loop over all phases

    % current phase quantities
    currentPhase = phaseArray(i);
    phaseManager = currentPhase.phaseManager;
    plant = currentPhase.plant;
    sigma = currentPhase.sigma;

    % current cost computation functions
    currentRunningCost = str2func(phaseManager.L_file);
    currentTerminalCost = str2func(phaseManager.terminalCostFile);
    currentTerminalConstraint = str2func(phaseManager.terminalConstraintFile);
    currentAugmentedLagrangian = str2func(phaseManager.phit_file);
    currentPathEqConstraint = str2func(phaseManager.cEq_file);

    % TODO: investigate if the Lsum computation can be vectorized

    % loop over all stages to sum the running costs
    nStages = plant.nStages;
    for k = 1:nStages
        % get the current point
        [t, x, u, w, l] = plant.getPointAtIndex(k);

        % sum over every stage except the last one
        if k < nStages
            % sum the current running cost
            X = [x; u; w];
            obj.Lsum(i, 1) = obj.Lsum(i, 1) + feval(currentRunningCost, t, X);

            % check the maximum path constraints violation
            obj.maxPathConstraintViolation = max(obj.maxPathConstraintViolation, ...
                max(abs(feval(currentPathEqConstraint, t, X))));
        end
    end

    % get the upstream phase quantities
    if i ~= M
        % generic phase
        upstreamPlant = phaseArray(i+1).plant;
        [~, xp, ~, wp, ~] = upstreamPlant.getPointAtIndex(1);
    else
        % for the final phase, use dummy values for the upstream state and
        % parameters
        xp = 0;
        wp = 0;
    end

    % compute the phase costs
    obj.phi(i, 1) = feval(currentTerminalCost, x, w, xp, wp);
    obj.Psi{i, 1} = feval(currentTerminalConstraint, x, w, xp, wp);
    obj.Psi_squared(i, 1) = obj.Psi{i, 1}' * obj.Psi{i, 1};
    obj.phit(i, 1) = feval(currentAugmentedLagrangian, [x; w; xp; ...
        wp; l], sigma);

end

end

