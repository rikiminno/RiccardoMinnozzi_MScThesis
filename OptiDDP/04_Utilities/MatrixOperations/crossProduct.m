function c = crossProduct(vec1, vec2)
% function that computes the cross product between two 3D vectors
%
% authored by Riccardo Minnozzi, 11/2024

c = [
    vec1(2) * vec2(3) - vec1(3) * vec2(2); ...
    vec1(3) * vec2(1) - vec1(1) * vec2(3); ...
    vec1(1) * vec2(2) - vec1(2) * vec2(1)
    ];
end

