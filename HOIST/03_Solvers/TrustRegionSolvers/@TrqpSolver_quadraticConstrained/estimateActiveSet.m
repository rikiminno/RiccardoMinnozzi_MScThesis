function [q, nEq] = estimateActiveSet(obj, problem, phaseManager, du)
% method that estimates the active set of constraints and returns the
% values and partials of the active constraints around the current point

% use the unrestricted update to check the constraints violations
[t, x, u, w, ~] = problem.getPoint();
X = [x; u + du; w];

% equality constraints
c_Eq = feval(phaseManager.cEq_file, t, X);
activeSetMaskEq = abs(c_Eq) > obj.settings.eps_path_feas;

% compute the constraints and related partials on the current point
cEq_partials = phaseManager.computePathConstraintsPartials(t, x, u, w);

% compute the number of active constraints
nEq = nnz(activeSetMaskEq);

% assemble the constraints array (if any are active)
if nEq > 0
    q(nEq) = StagePartials();
    q(1 : nEq) = cEq_partials(activeSetMaskEq);
else
    q = [];
end

end

