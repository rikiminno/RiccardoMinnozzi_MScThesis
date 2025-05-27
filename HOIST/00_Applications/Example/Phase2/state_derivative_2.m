function xdot = state_derivative_2(t, x, u, w)
% function that computes the state derivative for the linear
% quadratic test problem

xdot = zeros(6, 1);

xdot(1:3) = x(4: 6);
xdot(4:6) = u;

end


