function xdot = state_derivative_1(t, x, u, w)
% function that computes the state derivative

global auxdata

% assemble state
rbar = x(1);
thetabar = x(2);
ubar = x(3);
vbar = x(4);

% the primer vector is always aligned with the velocity
yaw = u;
alpha = atan(1/sqrt(2)); % 35.2644 deg;

% Solar-sail acceleration in local frame
a_RSW = zeros(3, 1);
a_RSW(1) = auxdata.a0bar*cos(alpha).^2.*sin(alpha).*sin(yaw);
a_RSW(2) = auxdata.a0bar*cos(alpha).^2.*sin(alpha).*cos(yaw);

% assemble EOMs
drbar = ubar*auxdata.eta;
dtheta = vbar./rbar*auxdata.eta;
dubar = (vbar.^2./rbar - 1./rbar.^2)*auxdata.eta + a_RSW(1);
dvbar = -ubar*vbar./rbar*auxdata.eta             + a_RSW(2);

xdot = [drbar; dtheta; dubar; dvbar];

end

