function [X, Y, Z, Vx, Vy, Vz] = keplerToCartesian(a, ecc, inc, argp, nu, RAAN, mu)
% function that converts the kepler state to cartesian coordinates
%
%

p = a*(1-ecc ^2);
r_0 = p / (1 + ecc * cos(nu));
%
%%--------------- Coordinates in the perifocal reference system Oxyz -----------------%
%
% position vector coordinates
x = r_0 * cos(nu);
y = r_0 * sin(nu);
%
%
% velocity vector coordinates
Vx_ = -(mu/p)^(1/2) * sin(nu);
Vy_ = (mu/p)^(1/2) * (ecc + cos(nu));
%
%
%%-------------- the geocentric-equatorial reference system OXYZ ---------------------%
%
% position vector components X, Y, and Z
X = (cos(RAAN) * cos(argp) - sin(RAAN) * sin(argp) * cos(inc)) * x + (-cos(RAAN) * sin(argp) - sin(RAAN) * cos(argp) * cos(inc)) * y;
Y = (sin(RAAN) * cos(argp) + cos(RAAN) * sin(argp) * cos(inc)) * x + (-sin(RAAN) * sin(argp) + cos(RAAN) * cos(argp) * cos(inc)) * y;
Z = (sin(argp) * sin(inc)) * x + (cos(argp) * sin(inc)) * y;
% velocity vector components X', Y', and Z'
Vx = (cos(RAAN) * cos(argp) - sin(RAAN) * sin(argp) * cos(inc)) * Vx_ + (-cos(RAAN) * sin(argp) - sin(RAAN) * cos(argp) * cos(inc)) * Vy_;
Vy = (sin(RAAN) * cos(argp) + cos(RAAN) * sin(argp) * cos(inc)) * Vx_ + (-sin(RAAN) * sin(argp) + cos(RAAN) * cos(argp) * cos(inc)) * Vy_;
Vz = (sin(argp) * sin(inc)) * Vx_ + (cos(argp) * sin(inc)) * Vy_;
end

