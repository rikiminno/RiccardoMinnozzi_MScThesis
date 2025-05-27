function R_CRK_to_IJK = getCrankedToInertialRotation(Omg, inc)
% function that outputs the rotation matrix from cranked orbital frame to
% Earth centered inertial frame using the input RAAN and inclination (both
% defined in degrees)
%
% authored by Riccardo Minnozzi, 10/2024

R_CRK_to_IJK = rotate_z_deg(180 - Omg) * rotate_x_deg(inc);
end

