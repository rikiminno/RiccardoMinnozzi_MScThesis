function [converged, whichCase] = checkTerminationCriteria(obj, s, Delta, currentSet, lambda, H_l, u, alpha)
% function that performs the algorithm termination checks based on the
% current set in which the lambda solution lies

% initialize convergence check
converged = false;
whichCase = [];

% convergence in the "easy case" (feasible region and very close to trust
% region radius)
if (currentSet == "L" || currentSet == "G") && ...
        abs(norm(s) - Delta) <= obj.settings.kEasy * Delta
    converged = true;
    whichCase = "easy";
end

% convergence in the interior case (lambda is 0 and lies in the G set)
if currentSet == "G" && lambda == 0
    converged = true;
    whichCase = "interior";
end

% convergence in the "hard case" (the alpha and u resulting from LINPACK
% show that the lambda solution cannot be further improved significanlty)
if currentSet == "G" && ...
        alpha^2 * (u' * (H_l * u)) <= obj.settings.kHard * (s' * (H_l * s) + lambda * Delta^2)
    converged = true;
    whichCase = "hard";
end
end