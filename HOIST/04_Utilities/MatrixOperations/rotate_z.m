function R = rotate_z(gamma)
% function to output the rotation matrix for a rotation around the z axis
% by angle gamma [rad]

R = zeros(3, 3);
R(1, 1) = cos(gamma);
R(1, 2) = -sin(gamma);
R(2, 1) = sin(gamma);
R(2, 2) = cos(gamma);
R(3, 3) = 1;

end

