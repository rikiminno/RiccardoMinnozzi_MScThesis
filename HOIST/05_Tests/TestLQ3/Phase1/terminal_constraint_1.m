function Psi = terminal_constraint_1(xm, wm, xp, wp)
% function that implements the terminal constraints for the current phase

Psi = zeros(6, 1);
Psi(1) = xp(1) - xm(1);
Psi(4) = xp(2) - xm(4);
Psi(2:3) = xm(2:3) - [1; 0];
Psi(5:6) = xm(5:6) - [0; 0];
end

