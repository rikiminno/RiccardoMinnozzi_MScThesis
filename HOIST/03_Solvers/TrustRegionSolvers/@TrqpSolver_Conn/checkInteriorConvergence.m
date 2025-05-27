function converged = checkInteriorConvergence(lambda_L, s, Delta)
% function that checks the interior convergence of the algorithm

% check if the current lambda is on the interior bound
if TrqpSolver_Conn.secularEq(s, Delta) >= 0 && lambda_L == 0
    converged = true;
else
    converged = false;
end
end