function Psi = terminal_constraint_2(xm, wm, xp, wp)
% function that implements the terminal constraints for the current phase

target = [9; -9; 3];
Psi = xm(1:3) - target;

end

