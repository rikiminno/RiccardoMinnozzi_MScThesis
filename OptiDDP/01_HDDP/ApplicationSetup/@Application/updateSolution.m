function obj = updateSolution(obj, newPhaseArray, trialIterate)
% function that updates the current HDDP solution with the accepted phase
% array, consequently updating the reference iterate object

% % check the forward pass for too long or short stages
% for i = 1 : length(newPhaseArray)
% 
%     % get the current quantities
%     currentPhase = newPhaseArray(i);
%     plant = currentPhase.plant;
%     tVec = plant.t;
% 
%     % compute the stage durations
%     dts = diff(tVec);
% 
%     if max(dts) > obj.algorithmConfig.maxStageDuration
% 
%     elseif min(dts) < obj.algorithmConfig.minStageDuration
% 
%     end
% end

% assign the forward pass solution as the new reference
obj.phaseArray = newPhaseArray;

% perform the penalty update
sigma = obj.penaltyUpdate.perform(obj.iterate, trialIterate, obj.phaseArray);
obj.phaseArray = obj.phaseArray.setPenaltyParameter(sigma);

% update the reference iterate (with the new penalty parameter)
obj.iterate = trialIterate.updatePenaltyParameter(obj.phaseArray, sigma);

end

