function R = getRswToInertialRotation(state)
% function to compute the rotation matrix from RSW to inertial frame

R = getInertialToRswRotation(state);
R = R';

end

