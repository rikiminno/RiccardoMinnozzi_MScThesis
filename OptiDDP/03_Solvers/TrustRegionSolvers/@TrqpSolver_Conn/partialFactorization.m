function [delta, v] = partialFactorization(H_l)
% function that performs the partial factorization of the current Hessian
% matrix in order to obtain the delta and v quantities that improve the
% lower bound on the lambda uncertainty interval

% start the cholesky decomposition, until a nonpositive pivot is found
n = size(H_l, 1);
L = zeros(n, n);
for k = 1:n
    % set the current row pivot
    if k == 1
        pivot = H_l(k, k);
    else
        pivot = H_l(k, k) - sum(L(k, 1:k-1).^2);
    end

    % check for positive pivot
    if pivot <= 0
        break;
    else
        % perform the lower cholesky decomposition diagonal element
        L(k, k) = sqrt(pivot);

        % non diagonal elements
        if k ~= n
            for j = k+1 : n
                L(j, k) = (H_l(j, k) - sum(L(k, 1:k-1) .* L(j, 1:k-1))) / L(k, k);
            end
        end
    end
end

% when the non-positive pivot is encountered, the previous for-loop is
% escaped, then we compute the delta shift
delta = sum(L(k, 1:k-1).^2) - H_l(k, k);

% back-solve the v vector
v = zeros(n, 1);
v(k) = 1;
for j = k-1 : -1 : 1
    v(j) = - sum(L(j+1:k, j) .* v(j+1:k))/L(j, j);
end

% this is a check to verify that the implementation of delta and v is
% correct
% check = (H_l + delta * eye(n)) * v;
end