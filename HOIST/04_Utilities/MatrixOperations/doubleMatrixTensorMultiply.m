function T = doubleMatrixTensorMultiply(A1, T, A2)
% function that performs the multiplication of tensor T by matrix A on both
% sides, solving the A' * T * A
%
% authored by Riccardo Minnozzi, 10/2024

T = tensorMatrixMultiply(permute(T, [2 1 3]), A1);
T = tensorMatrixMultiply(permute(T, [3 2 1]), A2);
end

