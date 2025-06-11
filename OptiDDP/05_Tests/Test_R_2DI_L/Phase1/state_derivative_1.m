function xdot = state_derivative_1(t, x, u, w)
% function that computes the state derivative

global auxdata

% control the primer vector yaw angle
yaw = u;

% assemble state
rbar = x(1);
thetabar = x(2);
ubar = x(3);
vbar = x(4);

% primer vector in inertial frame
primerIx = cos(thetabar).*sin(yaw) - sin(thetabar).*cos(yaw);
primerIz = sin(thetabar).*sin(yaw) + cos(thetabar).*cos(yaw);

% Compute psi angle from inertial primer vector x-coordinate
psi = atan2(primerIz, primerIx);

% Compute optimal alpha angle from psi
alpha = 1/2*(psi - asin(sin(psi)/3));

% Solar-sail acceleration in inertial frame
a_IJK = zeros(3, 1);
a_IJK(3) = auxdata.a0bar*cos(alpha).^2.*sin(alpha);
a_IJK(1) = auxdata.a0bar*cos(alpha).^2.*cos(alpha);

% Solar-sail acceleration in local frame
a_RSW = zeros(3, 1);
a_RSW(1) = cos(thetabar).*a_IJK(1) + sin(thetabar).*a_IJK(3);
a_RSW(2) = -sin(thetabar).*a_IJK(1) + cos(thetabar).*a_IJK(3);

% assemble EOMs
drbar = ubar*auxdata.eta;
dtheta = vbar./rbar*auxdata.eta;
dubar = (vbar.^2./rbar - 1./rbar.^2)*auxdata.eta + a_RSW(1);
dvbar = -ubar*vbar./rbar*auxdata.eta             + a_RSW(2);

xdot = [drbar; dtheta; dubar; dvbar];

end

