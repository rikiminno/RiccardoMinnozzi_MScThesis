function [updateLaw, q] = solve(obj, problem, phaseManager)
% method to solve the TRQP problem defined by the gradient and
% hessian computed from the quadratic expansion

% set the empty constraints information
q = [];

% solve the trust region subproblem
[da, J_a, J_aa, J_aa_inv] = obj.solveTrustRegion(problem);

% build the update law output object
updateLaw = obj.buildUpdateLaw(problem, da, J_a, J_aa, J_aa_inv);

end