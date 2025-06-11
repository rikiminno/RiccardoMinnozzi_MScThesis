function ang = angleBetweenVectors(vec1, vec2, vecN)
% function that computes the angle between two vectors, with a positive
% right-handed rotation going from vec1 to vec2
%
% authored by Riccardo Minnozzi, 10/2024

if nargin == 2
    % compute the normal to the plane of both vectors
    vecN = cross(vec1, vec2);
end

% make sure that the vectors are both columns
vec1 = reshape(vec1, [], 1);
vec2 = reshape(vec2, [], 1);

% normalize all vectors
vec1 = vec1 ./ norm(vec1);
vec2 = vec2 ./ norm(vec2);
vecN = vecN ./ norm(vecN);

% https://stackoverflow.com/questions/5188561/signed-angle-between-two-3d-vectors-with-same-origin-within-the-same-plane
ang = atan2(dot(cross(vec1, vec2), vecN), dot(vec1, vec2));

end

% % https://www.cuemath.com/geometry/angle-between-vectors/
% ang = asin(norm(cross(vec1, vec2)) / (norm(vec1) * norm(vec2)));
