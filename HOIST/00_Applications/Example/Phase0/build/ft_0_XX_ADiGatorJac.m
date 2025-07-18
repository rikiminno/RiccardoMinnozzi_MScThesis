% This code was generated using ADiGator version 1.4
% ©2010-2014 Matthew J. Weinstein and Anil V. Rao
% ADiGator may be obtained at https://sourceforge.net/projects/adigator/ 
% Contact: mweinstein@ufl.edu
% Bugs/suggestions may be reported to the sourceforge forums
%                    DISCLAIMER
% ADiGator is a general-purpose software distributed under the GNU General
% Public License version 3.0. While the software is distributed with the
% hope that it will be useful, both the software and generated code are
% provided 'AS IS' with NO WARRANTIES OF ANY KIND and no merchantability
% or fitness for any purpose or application.

function Xdot_X = ft_0_XX_ADiGatorJac(t,X)
global ADiGator_ft_0_XX_ADiGatorJac
if isempty(ADiGator_ft_0_XX_ADiGatorJac); ADiGator_LoadData(); end
Gator1Data = ADiGator_ft_0_XX_ADiGatorJac.ft_0_XX_ADiGatorJac.Gator1Data;
% ADiGator Start Derivative Computations
gator_X.f.dX = X.dX; gator_X.f.f = X.f;
%User Line: gator_X.f = X;
gator_X.dX.f = [1;1;1];
%User Line: gator_X.dX = ones(3,1);
cadainput2_1 = t;
%User Line: cadainput2_1 = t;
cadainput2_2 = gator_X;
cadainput2_2.dX = gator_X.dX.f;
cadainput2_2.f = gator_X.f.f;
%User Line: cadainput2_2 = gator_X;
cadaoutput2_1 = ft_0_X_ADiGatorJac(cadainput2_1,cadainput2_2);
% Call to function: ft_0_X_ADiGatorJac
Xdot = cadaoutput2_1;
%User Line: Xdot = cadaoutput2_1;
Xdot.dX.f = [0;0;0];
%User Line: Xdot.dX = zeros(3,1);
Xdot_X.f =  zeros(3,3);
%User Line: Xdot_X = zeros(3,3);
end
function Xdot = ft_0_X_ADiGatorJac(t,X)
global ADiGator_ft_0_XX_ADiGatorJac
Gator1Data = ADiGator_ft_0_XX_ADiGatorJac.ft_0_X_ADiGatorJac.Gator1Data;
Gator2Data = ADiGator_ft_0_XX_ADiGatorJac.ft_0_X_ADiGatorJac.Gator2Data;
% ADiGator Start Derivative Computations
%User Line: % Augmented state derivative wrapper function for phase 0,
%User Line: % automatically generated by the PhaseManager class on 03-Oct-2024 12:46:48
x.dX = X.dX(1);
% Deriv 1 Line: x.dX = X.dX(1);
x.f = X.f(1,1);
% Deriv 1 Line: x.f = X.f(1,1);
%User Line: x = X(1: 1, 1);
u.dX = X.dX(2);
% Deriv 1 Line: u.dX = X.dX(2);
u.f = X.f(2,1);
% Deriv 1 Line: u.f = X.f(2,1);
%User Line: u = X(2: 2, 1);
w.dX = X.dX(3);
% Deriv 1 Line: w.dX = X.dX(3);
w.f = X.f(3,1);
% Deriv 1 Line: w.f = X.f(3,1);
%User Line: w = X(3: 3, 1);
cadainput2_1 = t;
% Deriv 1 Line: cadainput2_1 = t;
%User Line: cadainput2_1 = t;
cadainput2_2.dX = x.dX;
% Deriv 1 Line: cadainput2_2.dX = x.dX;
cadainput2_2.f = x.f;
% Deriv 1 Line: cadainput2_2.f = x.f;
%User Line: cadainput2_2 = x;
cadainput2_3.dX = u.dX;
% Deriv 1 Line: cadainput2_3.dX = u.dX;
cadainput2_3.f = u.f;
% Deriv 1 Line: cadainput2_3.f = u.f;
%User Line: cadainput2_3 = u;
cadainput2_4.dX = w.dX;
% Deriv 1 Line: cadainput2_4.dX = w.dX;
cadainput2_4.f = w.f;
% Deriv 1 Line: cadainput2_4.f = w.f;
%User Line: cadainput2_4 = w;
cadainput3_1 = cadainput2_1;
% Deriv 1 Line: cadainput3_1 = cadainput2_1;
cadainput3_2 = cadainput2_2;
% Deriv 1 Line: cadainput3_2 = cadainput2_2;
cadainput3_3 = cadainput2_3;
% Deriv 1 Line: cadainput3_3 = cadainput2_3;
cadainput3_4 = cadainput2_4;
% Deriv 1 Line: cadainput3_4 = cadainput2_4;
cadaoutput3_1 = ADiGator_state_derivative_01(cadainput3_1,cadainput3_2,cadainput3_3,cadainput3_4);
% Call to function: ADiGator_state_derivative_01
cadaoutput2_1 = cadaoutput3_1;
% Deriv 1 Line: cadaoutput2_1 = cadaoutput3_1;
% Call to function: state_derivative_0
xdot.f = cadaoutput2_1.f;
% Deriv 1 Line: xdot.f = cadaoutput2_1.f;
%User Line: xdot = cadaoutput2_1;
udot.f = 0;
% Deriv 1 Line: udot.f =  zeros(1, 1);
%User Line: udot = zeros(1, 1);
wdot.f = 0;
% Deriv 1 Line: wdot.f =  zeros(1, 1);
%User Line: wdot = zeros(1, 1);
Xdot.f = [xdot.f;udot.f;wdot.f];
% Deriv 1 Line: Xdot.f = [xdot.f;udot.f;wdot.f];
%User Line: Xdot = [xdot; udot; wdot];
end
function xdot = ADiGator_state_derivative_01(t,x,u,w)
global ADiGator_ft_0_XX_ADiGatorJac
Gator1Data = ADiGator_ft_0_XX_ADiGatorJac.ADiGator_state_derivative_01.Gator1Data;
Gator2Data = ADiGator_ft_0_XX_ADiGatorJac.ADiGator_state_derivative_01.Gator2Data;
% ADiGator Start Derivative Computations
%User Line: % function that computes the state derivative for the dummy phase 0 (this
%User Line: % function should never be called)
xdot.f = 0;
% Deriv 1 Line: xdot.f =  0;
%User Line: xdot = 0;
end


function ADiGator_LoadData()
global ADiGator_ft_0_XX_ADiGatorJac
ADiGator_ft_0_XX_ADiGatorJac = load('ft_0_XX_ADiGatorJac.mat');
return
end