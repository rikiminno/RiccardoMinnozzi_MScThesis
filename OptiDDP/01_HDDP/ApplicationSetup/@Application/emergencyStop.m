function obj = emergencyStop(obj, iterate)
% method that determines whether to stop the algorithm run early due to
% hitting limitations (such as the minimum trust region radius or the
% runTime limit)

% check the trust region radius size and numerical stability of the ER
TRradiusLimit = iterate.ER < 1.5 * eps && ...
    iterate.Delta == obj.algorithmConfig.Delta_min;

% check the run time
runTimeLimit = toc > obj.algorithmConfig.maxRunTime;

% assign output
obj.terminateEarly = runTimeLimit || TRradiusLimit;
end

