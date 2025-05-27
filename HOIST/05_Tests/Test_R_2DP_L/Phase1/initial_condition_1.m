function x0 = initial_condition_1(w)
% function that copmutes the initial conditions for the current phase

global auxdata

x0 = zeros(4, 1);
x0(1) = auxdata.r0bar;
x0(2) = auxdata.theta0bar;
x0(3) = auxdata.u0bar;
x0(4) = auxdata.v0bar;

end

