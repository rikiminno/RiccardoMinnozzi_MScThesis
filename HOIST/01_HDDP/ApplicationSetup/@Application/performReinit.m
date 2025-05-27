function obj = performReinit(obj, converged)
% method that applies the re-initialized tolerances to the required
% properties (namely, the solvers and the phase array)

% perform the actual reinitialization
obj.reInitialization = obj.reInitialization.perform(obj.iterate, obj.trqpSolver, ...
    converged);

% get the tolerance values
eps_1 = obj.reInitialization.eps_1;
eps_opt = obj.reInitialization.eps_opt;
eps_feas = obj.reInitialization.eps_feas;
Delta = obj.reInitialization.Delta;

% get the current iteration count from the reference iterate
p = obj.iterate.getID();
p = p(3);

% re initialize the convergence test
obj.convergenceTest = feval(obj.algorithmConfig.version.convergenceTest, ...
    obj.algorithmConfig, eps_opt, eps_feas, [-1; -1; p]);

% re-initialize the trust region solver
obj.trqpSolver = feval(obj.algorithmConfig.version.trqpSolver, ...
    obj.algorithmConfig, eps_1, Delta);

% re-initialize the penalty update
obj.penaltyUpdate = feval(obj.algorithmConfig.version.penaltyUpdate, ...
    obj.algorithmConfig, eps_feas, [-1, -1, p]);

% assign the new eps_1 to the phase array for logging purposes
obj.phaseArray = obj.phaseArray.setQuadraticTolerance(obj.trqpSolver.eps_1);
end

