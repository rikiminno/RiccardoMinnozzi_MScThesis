function dev = computeStateDeviationFromSTTs(STM, STT, dev)
% function that contains the full procedure to compute the state deviation
% caused by the input dev by using the state transition maps defined in STM
% and STT
%
% authored by Riccardo Minnozzi, 11/2024

% reshape the deviation to column vector
dev = reshape(dev, [], 1);

% compute the upstream state deviation
dev = STM * dev + ...
    0.5 * (tensorMatrixMultiply(permute(STT, [2 1 3]), dev)) * dev;
end

