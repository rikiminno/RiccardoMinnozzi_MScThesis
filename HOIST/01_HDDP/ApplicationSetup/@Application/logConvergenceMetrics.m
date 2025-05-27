function logConvergenceMetrics(obj)
% function that logs to screen the final optimization metrics after
% convergence (or early termination)

global HOIST_fevalsCount_Jaug;
global HOIST_fevalsCount_L;
global HOIST_fevalsCount_cEq;
global HOIST_fevalsCount_ft;

% get the elapsed time and number of iterations
tocTime = toc;
p = obj.iterate.getID();
p = p(3);

% Print the header
if obj.reInitialization.stoppingCondition == StoppingCondition.hardSuccess
    fprintf('\n\n\nConvergence reached in %8.1f seconds.\n', tocTime);
else
    fprintf('\n\n\nOptimization prematurely terminated after %8.1f seconds.\n', tocTime);
end
fprintf('------------------------------------------------------------------------------------------------------- \n');
fprintf('--------------------------------------- Optimization terminated --------------------------------------- \n');
fprintf('------------------------------------------------------------------------------------------------------- \n');

% Print basic optimization results
fprintf("\n");
fprintf('-----------------------------------------\n');
fprintf("\n");
fprintf(" -> Optimization results: \n");
fprintf('   Iterations                  : %d\n', p - 1);
fprintf('   Cost Function value         : %12.5e\n', obj.iterate.J);
fprintf('   Constraint violation        : %12.5e\n', obj.iterate.f);
fprintf('   Path constraints violation  : %12.5e\n', obj.iterate.maxPathConstraintViolation);
fprintf('\n');

% Print function evaluations
fprintf(' -> Function Evaluations: \n');
fprintf('   Dynamics             : %d\n', HOIST_fevalsCount_ft);
fprintf('   Path Constraints     : %d\n', HOIST_fevalsCount_cEq);
fprintf('   Running Cost         : %d\n', HOIST_fevalsCount_L);
fprintf('   Augmented Lagrangian : %d\n', HOIST_fevalsCount_Jaug);
fprintf('\n');

fprintf('-----------------------------------------\n');

end

