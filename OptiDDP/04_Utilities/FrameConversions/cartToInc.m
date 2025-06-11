function inc = cartToInc(x, y, z, vx, vy, vz, mu)
% function that computes the inclination from the cartesian state of a
% spacecraft
%
% authored by Riccardo Minnozzi, 11/2024

% set auxiliary quantities
rvec = [x; y; z];
vvec = [vx; vy; vz];
hvec = crossProduct(rvec, vvec);
h = sqrt(hvec(1)^2 + hvec(2)^2 + hvec(3)^2);

% assign output
inc = acos(hvec(3) / h);
end

