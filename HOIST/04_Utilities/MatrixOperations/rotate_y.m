function R = rotate_y(beta)
% function to output the rotation matrix for a rotation around the y axis
% by angle beta [rad]

R = zeros(3, 3);
R(1, 1) = cos(beta);
R(1, 3) = sin(beta);
R(2, 2) = 1;
R(3, 1) = -sin(beta);
R(3, 3) = cos(beta);

end

