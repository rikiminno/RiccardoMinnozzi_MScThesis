function ecc = cartToEcc(x, y, z, vx, vy, vz, mu)
% function that computes the eccentricity from the cartesian state of a
% spacecraft
%
% authored by Riccardo Minnozzi, 11/2024

% set auxiliary quantities
a = cartToSma(x, y, z, vx, vy, vz, mu);
rvec = [x; y; z];
vvec = [vx; vy; vz];
hvec = crossProduct(rvec, vvec);
h = sqrt(hvec(1)^2 + hvec(2)^2 + hvec(3)^2);

% assign output
ecc = sqrt(1  - h^2 / (a * mu));
end

