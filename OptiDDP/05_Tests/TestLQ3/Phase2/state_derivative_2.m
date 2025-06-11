function xdot = state_derivative_2(t, x, u, w)
% function that computes the state derivative for the linear
% quadratic test problem

xdot = zeros(2, 1);

xdot(1) = x(2);
xdot(2) = u;

end


