function obj = updatePenaltyParameter(obj, phaseArray, sigma)
% function that updates the iterate costs after the penalty
% update has been performed

% store the old penalty parameter
oldSigma = obj.sigma;

% assign new penalty parameter
obj.sigma = sigma;

% loop over all phases
M = length(phaseArray);
for i = 1:M
    % update the augmented Lagrangian cost function
    obj.phit(i, 1) = obj.phit(i, 1) - oldSigma * obj.Psi_squared(i, 1) ...
        + sigma * obj.Psi_squared(i, 1);
end

% update the full phases cost functional
obj.J = sum(obj.Lsum) + sum(obj.phit);
end