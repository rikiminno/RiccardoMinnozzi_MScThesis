function projVec = projectVectorOntoPlane(vec, n)
% function that computes the projection of vector vec onto the plane which
% normal vector is n
%
% authored by Riccardo Minnozzi, 10/2024

% make sure that the inputs are column vectors
vec = reshape(vec, [], 1);
n = reshape(n, [], 1);

% Ensure that n is a unit vector (optional but recommended)
n = n ./ norm(n);

% Compute the projection
projVec = vec - dot(vec, n) * n;

end

