function C = tensorMatrixMultiply(T, A)
% function to perform tensor by matrix multiplication using Einsteins
% notation: T is the input tensor, A is the input matrix
% NOTE: the summation is always performed over the first dimension of T and
% first dimension of A

% initialize output
na = size(T, 2);
nb = size(T, 3);
ni = size(A, 2);
C = zeros(ni, na, nb);

% get the size of the summation dimension
ngamma = size(T, 1);
nCheckGamma = size(A, 1);
if ngamma ~= nCheckGamma
    error(strcat("The tensor-matrix multiplication sizes don't match: ", ...
        "the input tensor has dimension 1 of size: ", string(ngamma),...
        ", while the input matrix has dimension 1 of size: ", string(nCheckGamma), "."));
end

for i = 1:ni
    % loop over first index
    for a = 1:na
        % loop over second index
        for b = 1:nb
            % loop over third index

            for gamma = 1 : ngamma
                % perform the summation
                C(i, a, b) = C(i, a, b) + T(gamma, a, b) * A(gamma, i);

            end
        end
    end
end
C = squeeze(C);

% TODO: translate this in a more efficient version, using permute and sum
% functions

end

