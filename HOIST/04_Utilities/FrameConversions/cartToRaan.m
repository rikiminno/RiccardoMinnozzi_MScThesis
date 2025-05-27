function RAAN = cartToRaan(x, y, z, vx, vy, vz, mu)
% function that computes the right ascension of the ascending node from the
% cartesian state of a spacecraft
%
% authored by Riccardo Minnozzi, 11/2024

% set auxiliary quantities
rvec = [x; y; z];
vvec = [vx; vy; vz];
hvec = crossProduct(rvec, vvec);
k = [0; 0; 1];
n = crossProduct(k, hvec);
n_norm = sqrt(n(1)^2 + n(2)^2 + n(3)^2);

% assign output
if n(2) >= 0
    RAAN = acos(n(1) / n_norm);
else
    RAAN = 2 * pi - acos(n(1) / n_norm);
end

end