function xdot = state_derivative_1(t, x, u, w)
% function that computes the state derivative

global auxdata

% assemble state
rbar = x(1);
tbar = x(2);
ubar = x(3);
vbar = x(4);
theta = t * auxdata.thetaf;

% define rotation matrices
trueRAAN = 180 - auxdata.Omg;
R_Omg = rotate_z_deg(trueRAAN);
R_inc = rotate_x_deg(auxdata.inc);
R_CRK_to_RSW = rotate_z(theta);
R_CRK_to_IJK = R_Omg * R_inc;
R_RSW_to_IJK = R_CRK_to_IJK * R_CRK_to_RSW';
tDays = tbar * auxdata.T0 / 86400;
R_SLF_to_IJK = rotate_z_deg(tDays);

% define unit vectors
i = [1; 0; 0];
j = [0; 1; 0];
k = [0; 0; 1];
r_SS = R_SLF_to_IJK * i;

% define primer yaw vector
yaw = u;

% assemble primer vector in local frame
p_RSW = [sin(yaw); cos(yaw); 0];

% rotate primer vector to inertial
p_IJK = R_RSW_to_IJK * p_RSW;

% compute angle between primer vector and sun line
psi = angleBetweenVectors(p_IJK, r_SS);

% compute optimal alpha angle from psi
alpha = 1/2*(psi - asin(sin(psi)/3));

% compute the clock angle as the angle between the primer vector and the
% chosen reference direction z (valid since it is perpendicular to the
% Sun-line)
delta = atan2(p_IJK(2), p_IJK(3));

% compute the solar sail acceleration in SunLight-frame
aMod = auxdata.a0bar * cos(alpha)^2;
a_SLF = aMod * cos(alpha) .* i ...
    + aMod * sin(alpha) * sin(delta) * j ...
    + aMod * sin(alpha) * cos(delta) * k;

% rotate the sail acceleration to local frame
a_IJK = R_SLF_to_IJK * a_SLF;
a_RSW = R_RSW_to_IJK' * a_IJK;

% assemble EOMs
eta = auxdata.eta;
sigma = (vbar / rbar) * eta / auxdata.thetaf;

drbar = ubar * eta / sigma;
dtime = 1 / sigma;
dubar = ((vbar^2/rbar - 1/rbar^2) * eta + a_RSW(1)) / sigma;
dvbar = (- ubar * vbar / rbar * eta + a_RSW(2)) / sigma;

xdot = [drbar; dtime; dubar; dvbar];

end

function angle = angleBetweenVectors(vec1, vec2)

c = myCross(vec1, vec2);
n = myNorm(c);
d = vec1' * vec2;

angle_tmp = atan2(n, d);

angSign = mySign(angle_tmp);

angle = angSign * angle_tmp;

end

function n = myNorm(vec)

n = sqrt(vec(1)^2 + vec(2)^2 + vec(3)^2);

end

function result = myCross(vec1, vec2)

result = zeros(3, 1);
result(1, 1) = vec1(2) * vec2(3) - vec1(3) * vec2(2);
result(2, 1) = vec1(3) * vec2(1) - vec1(1) * vec2(3);
result(3, 1) = vec1(1) * vec2(2) - vec1(2) * vec2(1);

end

function s = mySign(num)

if num >= 0
    s = 1;
else
    s = -1;
end
end


function R = local_z_rotation_deg(gamma)

R = zeros(3, 3);
R(1, 1) = cosd(gamma);
R(1, 2) = -sind(gamma);
R(2, 1) = sind(gamma);
R(2, 2) = cosd(gamma);
R(3, 3) = 1;
end
