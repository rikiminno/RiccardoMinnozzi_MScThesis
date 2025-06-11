function Psi = terminal_constraint_1(xm, wm, xp, wp)
% function that implements the terminal constraints for the current phase

Psi = zeros(6, 1);
Psi = xp - xm;

end

