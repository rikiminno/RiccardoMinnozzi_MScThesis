function obj = updateBackwardsInduction(obj, phaseArray)
% function that updates the iterate object using the phase
% array resulting from the backwards induction process

% store the expected reduction
obj.ER = phaseArray(1).getOptimizedQuantity();
obj.ER = obj.ER(1).ER;

% update the acceptedHessians flag
obj.acceptedHessians = true;
M = length(phaseArray);
for i = 1:M
    % loop over each phase
    currentPhase = phaseArray(i);
    obj.acceptedHessians = obj.acceptedHessians && currentPhase.acceptedHessians;
end
end