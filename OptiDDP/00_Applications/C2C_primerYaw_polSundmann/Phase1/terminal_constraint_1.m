function Psi = terminal_constraint_1(xm, wm, xp, wp)
% function that implements the terminal constraints for the current phase

global auxdata

Psi = zeros(2, 1);
Psi(1, 1) = xm(3);
Psi(2, 1) = xm(4) - 1/sqrt(xm(1));

end

