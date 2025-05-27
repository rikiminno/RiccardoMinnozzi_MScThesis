function a = cartToSma(x, y, z, vx, vy, vz, mu)
% function that computes the semi major axis from the cartesian state of a
% spacecraft
%
% authored by Riccardo Minnozzi, 11/2024

% set auxiliary quantities
r = sqrt(x^2 + y^2 + z^2);
v = sqrt(vx^2 + vy^2 + vz^2);
E = 0.5 * v^2 - mu/r;

% assign output
a = - 0.5 * mu / E;
end

