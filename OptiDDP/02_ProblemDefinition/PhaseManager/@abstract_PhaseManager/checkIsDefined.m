function checkIsDefined(obj)
% function that triggers an error if the PhaseManager object is
% not correctly defined

mustBeFile(obj.terminalCostFile);
mustBeFile(obj.terminalConstraintFile);
mustBeFile(obj.stateDerivativeFile);
mustBeFile(obj.runningCostFile);
mustBeFile(obj.initialConditionFile);
mustBeFile(obj.pathConstraintsEq_file);
mustBeFile(obj.pathConstraintsInEq_file);
end