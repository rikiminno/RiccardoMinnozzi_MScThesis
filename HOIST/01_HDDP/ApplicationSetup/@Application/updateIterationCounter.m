function obj = updateIterationCounter(obj, p)
% function that updates the iteration counter p at the start of each HDDP
% iteration

% phase array
M = length(obj.phaseArray);
for i = 1:M
    obj.phaseArray(i) = obj.phaseArray(i).setID([-1; i; p]);
end

% convergence test
obj.convergenceTest = obj.convergenceTest.setID([-1; -1; p]);

% forward pass
obj.forwardPass = obj.forwardPass.setID([-1; -1; p]);

% penalty update
obj.penaltyUpdate = obj.penaltyUpdate.setID([-1; -1; p]);
end

