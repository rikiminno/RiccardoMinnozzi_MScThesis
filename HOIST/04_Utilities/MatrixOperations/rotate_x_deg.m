function R = rotate_x_deg(alpha)
% function to output the rotation matrix for a rotation around the x axis
% by angle alpha [deg]

R = zeros(3, 3);
R(1, 1) = 1;
R(2, 2) = cosd(alpha);
R(2, 3) = -sind(alpha);
R(3, 2) = sind(alpha);
R(3, 3) = cosd(alpha);

end

