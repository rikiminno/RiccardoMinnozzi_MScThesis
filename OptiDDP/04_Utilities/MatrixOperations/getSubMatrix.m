function subMatrix = getSubMatrix(A, startRow, startCol, nrows, ncols)
% function to retrieve the sub-matrix that starts at corner with indices 
% startRow and startCol, and has nrows and ncols
%
% authored by Riccardo Minnozzi, 06/2024

% TODO: add a check if the nrows or ncols required is 0
subMatrix = A(startRow: startRow + nrows - 1, startCol: startCol + ncols - 1);
end

