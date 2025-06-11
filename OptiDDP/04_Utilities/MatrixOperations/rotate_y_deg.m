function R = rotate_y_deg(beta)
% function to output the rotation matrix for a rotation around the y axis
% by angle beta [deg]

R = zeros(3, 3);
R(1, 1) = cosd(beta);
R(1, 3) = sind(beta);
R(2, 2) = 1;
R(3, 1) = -sind(beta);
R(3, 3) = cosd(beta);

end

