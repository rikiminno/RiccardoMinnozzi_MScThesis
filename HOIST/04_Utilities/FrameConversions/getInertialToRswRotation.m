function R = getInertialToRswRotation(state)
% function to compute the rotation matrix from inertial frame (in which the
% state is expressed) to RSW
%
% authored by Riccardo Minnozzi, 06/2024

r = state(1:3);
v = state(4:6);

unitR = r./norm(r);
if 0 == norm(cross(r, v)), error("Radius and velocity have the same direction in RSW frame."); end

unitW = cross(r, v);
unitW = unitW./norm(unitW);

unitS = cross(unitW, unitR);

R = [unitR(1) unitR(2) unitR(3); ...
    unitS(1) unitS(2) unitS(3); ...
    unitW(1) unitW(2) unitW(3)];
end

