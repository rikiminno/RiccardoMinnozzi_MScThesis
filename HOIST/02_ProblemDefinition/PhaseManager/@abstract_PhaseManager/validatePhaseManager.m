function validatePhaseManager(obj)
% function that triggers specific errors when the definition of the phase
% manager is inconsistent (for instance, sizes don't match between the time
% and controls guesses)

phaseConfig = obj.phaseConfig;

% check that the lagrange multiplier vector has the same length as the
% terminal constraint vector

% check that the path constraints are a column vector

% check that the initial conditions are a column vector
end

