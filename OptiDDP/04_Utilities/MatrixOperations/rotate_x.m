function R = rotate_x(alpha)
% function to output the rotation matrix for a rotation around the x axis
% by angle alpha [rad]

R = zeros(3, 3);
R(1, 1) = 1;
R(2, 2) = cos(alpha);
R(2, 3) = -sin(alpha);
R(3, 2) = sin(alpha);
R(3, 3) = cos(alpha);

end

