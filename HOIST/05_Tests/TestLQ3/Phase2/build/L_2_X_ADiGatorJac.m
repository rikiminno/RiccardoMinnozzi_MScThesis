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

function L = L_2_X_ADiGatorJac(t,X)
global ADiGator_L_2_X_ADiGatorJac
if isempty(ADiGator_L_2_X_ADiGatorJac); ADiGator_LoadData(); end
Gator1Data = ADiGator_L_2_X_ADiGatorJac.L_2_X_ADiGatorJac.Gator1Data;
% ADiGator Start Derivative Computations
%User Line: % Running cost wrapper function for phase 2,
%User Line: % automatically generated by the PhaseManager class on 12-Jul-2024 15:11:47
x.dX = X.dX(Gator1Data.Index2);
x.f = X.f(Gator1Data.Index1,1);
%User Line: x = X(1: 2, 1);
u.dX = X.dX(3);
u.f = X.f(3,1);
%User Line: u = X(3: 3, 1);
w.dX = X.dX(Gator1Data.Index4);
w.f = X.f(Gator1Data.Index3,1);
%User Line: w = X(4: 5, 1);
cadainput2_1 = t;
%User Line: cadainput2_1 = t;
cadainput2_2.dX = x.dX; cadainput2_2.f = x.f;
%User Line: cadainput2_2 = x;
cadainput2_3.dX = u.dX; cadainput2_3.f = u.f;
%User Line: cadainput2_3 = u;
cadainput2_4.dX = w.dX; cadainput2_4.f = w.f;
%User Line: cadainput2_4 = w;
cadaoutput2_1 = ADiGator_running_cost_21(cadainput2_1,cadainput2_2,cadainput2_3,cadainput2_4);
% Call to function: running_cost_2
L.dX = cadaoutput2_1.dX; L.f = cadaoutput2_1.f;
%User Line: L = cadaoutput2_1;
L.dX_size = 5;
L.dX_location = Gator1Data.Index5;
end
function L = ADiGator_running_cost_21(t,x,u,w)
global ADiGator_L_2_X_ADiGatorJac
Gator1Data = ADiGator_L_2_X_ADiGatorJac.ADiGator_running_cost_21.Gator1Data;
% ADiGator Start Derivative Computations
%User Line: % function that computes the running cost for the linear quadratic test
%User Line: % problem
cadainput3_1.dX = u.dX; cadainput3_1.f = u.f;
%User Line: cadainput3_1 = u;
cadaoutput3_1 = ADiGator_myNormSquared1(cadainput3_1);
% Call to function: myNormSquared
L.dX = cadaoutput3_1.dX; L.f = cadaoutput3_1.f;
%User Line: L = cadaoutput3_1;
end
function n = ADiGator_myNormSquared1(vec)
global ADiGator_L_2_X_ADiGatorJac
Gator1Data = ADiGator_L_2_X_ADiGatorJac.ADiGator_myNormSquared1.Gator1Data;
% ADiGator Start Derivative Computations
%User Line: % custom norm function for 3D vector
cada1f1dX = vec.dX(1);
cada1f1 = vec.f(1);
n.dX = 2.*cada1f1.^(2-1).*cada1f1dX;
n.f = cada1f1^2;
%User Line: n = vec(1)^2;
end


function ADiGator_LoadData()
global ADiGator_L_2_X_ADiGatorJac
ADiGator_L_2_X_ADiGatorJac = load('L_2_X_ADiGatorJac.mat');
return
end