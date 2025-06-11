function s = computeStep(H, g, lambda)
% function that computes the trust region step according to the defined
% Hessian shift

H_l = H + lambda * eye(size(H, 1));
s = H_l \ (-g);
end