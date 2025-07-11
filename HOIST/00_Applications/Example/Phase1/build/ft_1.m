function Xdot = ft_1(t, X) 
% Augmented state derivative wrapper function for phase 1,
% automatically generated by the PhaseManager class on 03-Oct-2024 12:46:13
x = X(1: 6, 1); 
u = X(7: 9, 1); 
w = X(10: 10, 1); 

xdot = state_derivative_1(t, x, u, w); 
udot = zeros(3, 1); 
wdot = zeros(1, 1); 
Xdot = [xdot; udot; wdot]; 
end