function PhiDot = varEq_0(t, Phi) 
% Variational equations wrapper function for phase 0,
% automatically generated by the PhaseManager class on 17-Jul-2024 15:46:16
X = Phi(1: 3); 
STM = Phi(4: 12); 
STT = Phi(13: end); 
STM = reshape(STM, 3, 3); 
STT = reshape(STT, 3, 3, 3); 
Xdot = ft_0(t, X); 
ft_X = ft_0_X(t, X); 
ft_XX = ft_0_XX(t, X); 
STMdot = ft_X * STM; 
STTdot = tensorMatrixMultiply(permute(ft_XX, [2 1 3]), STM);
STTdot = tensorMatrixMultiply(permute(STTdot, [3 2 1]), STM);
STTdot = STTdot + tensorMatrixMultiply(STT, ft_X');
STMdot = reshape(STMdot, 9, 1); 
STTdot = reshape(STTdot, 27, 1); 
PhiDot = [Xdot; STMdot; STTdot]; 
end