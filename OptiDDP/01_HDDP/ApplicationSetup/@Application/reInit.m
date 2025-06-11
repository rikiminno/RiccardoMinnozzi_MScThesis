function obj = reInit(obj)
% method that re-initializes the convergence test and trust region solver
% for the current application object by tweaking the optimality,
% feasibility and quadratic model tolearnces

% re-initialize the convergence test
obj.convergenceTest = feval(obj.algorithmConfig.version.convergenceTest, ...
    obj.algorithmConfig, obj.iterate, [-1; -1; 0]);

% re-initialize the trust region solver
obj.trqpSolver = feval(obj.algorithmConfig.version.trqpSolver, ...
    obj.algorithmConfig, obj.iterate);

% assign the new eps_1 to the phase array for logging purposes
obj.phaseArray = obj.phaseArray.setQuadraticTolerance(obj.trqpSolver.eps_1);

end