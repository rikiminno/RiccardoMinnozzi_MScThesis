function R = rotate_z_deg(gamma)
% function to output the rotation matrix for a rotation around the z axis
% by angle gamma [deg]

R = zeros(3, 3);
R(1, 1) = cosd(gamma);
R(1, 2) = -sind(gamma);
R(2, 1) = sind(gamma);
R(2, 2) = cosd(gamma);
R(3, 3) = 1;

end

