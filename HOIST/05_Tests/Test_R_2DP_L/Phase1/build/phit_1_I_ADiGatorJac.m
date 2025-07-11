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

function phit = phit_1_I_ADiGatorJac(I,sigma)
global ADiGator_phit_1_I_ADiGatorJac
if isempty(ADiGator_phit_1_I_ADiGatorJac); ADiGator_LoadData(); end
Gator1Data = ADiGator_phit_1_I_ADiGatorJac.phit_1_I_ADiGatorJac.Gator1Data;
% ADiGator Start Derivative Computations
%User Line: % Augmented Lagrangian wrapper function for phase 1,
%User Line: % automatically generated by the PhaseManager class on 17-Jul-2024 15:45:44
xm.dI = I.dI(Gator1Data.Index2);
xm.f = I.f(Gator1Data.Index1,1);
%User Line: xm = I(1: 4, 1);
wm.dI = I.dI(5);
wm.f = I.f(5,1);
%User Line: wm = I(5: 5, 1);
xp.dI = I.dI(6);
xp.f = I.f(6,1);
%User Line: xp = I(6: 6, 1);
wp.dI = I.dI(7);
wp.f = I.f(7,1);
%User Line: wp = I(7: 7, 1);
lm.dI = I.dI(8);
lm.f = I.f(8,1);
%User Line: lm = I(8: 8, 1);
cadainput3_1.dI = xm.dI; cadainput3_1.f = xm.f;
%User Line: cadainput3_1 = xm;
cadainput3_2.dI = wm.dI; cadainput3_2.f = wm.f;
%User Line: cadainput3_2 = wm;
cadainput3_3.dI = xp.dI; cadainput3_3.f = xp.f;
%User Line: cadainput3_3 = xp;
cadainput3_4.dI = wp.dI; cadainput3_4.f = wp.f;
%User Line: cadainput3_4 = wp;
cadaoutput3_1 = ADiGator_terminal_cost_11(cadainput3_1,cadainput3_2,cadainput3_3,cadainput3_4);
% Call to function: terminal_cost_1
phi.dI = cadaoutput3_1.dI; phi.f = cadaoutput3_1.f;
%User Line: phi = cadaoutput3_1;
cadainput2_1.dI = xm.dI; cadainput2_1.f = xm.f;
%User Line: cadainput2_1 = xm;
cadainput2_2.dI = wm.dI; cadainput2_2.f = wm.f;
%User Line: cadainput2_2 = wm;
cadainput2_3.dI = xp.dI; cadainput2_3.f = xp.f;
%User Line: cadainput2_3 = xp;
cadainput2_4.dI = wp.dI; cadainput2_4.f = wp.f;
%User Line: cadainput2_4 = wp;
cadaoutput2_1 = ADiGator_terminal_constraint_11(cadainput2_1,cadainput2_2,cadainput2_3,cadainput2_4);
% Call to function: terminal_constraint_1
Psi.f = cadaoutput2_1.f;
%User Line: Psi = cadaoutput2_1;
cada1f1dI = lm.dI;
cada1f1 = lm.f.';
cada1f2 = cada1f1*Psi.f;
cada1f3dI = phi.dI;
cada1f3 = phi.f + cada1f2;
cada1f4 = Psi.f.';
cada1f5 = cada1f4*Psi.f;
cada1f6 = sigma*cada1f5;
phit.dI = cada1f3dI;
phit.f = cada1f3 + cada1f6;
%User Line: phit = phi + lm' * Psi + sigma * (Psi' * Psi);
phit.dI_size = 8;
phit.dI_location = Gator1Data.Index3;
end
function Psi = ADiGator_terminal_constraint_11(xm,wm,xp,wp)
global ADiGator_phit_1_I_ADiGatorJac
Gator1Data = ADiGator_phit_1_I_ADiGatorJac.ADiGator_terminal_constraint_11.Gator1Data;
% ADiGator Start Derivative Computations
%User Line: % function that implements the terminal constraints for the current phase
Psi.f =  0;
%User Line: Psi = 0;
end
function phi = ADiGator_terminal_cost_11(xm,wm,xp,wp)
global ADiGator_phit_1_I_ADiGatorJac
Gator1Data = ADiGator_phit_1_I_ADiGatorJac.ADiGator_terminal_cost_11.Gator1Data;
% ADiGator Start Derivative Computations
%User Line: % terminal cost for the linear quadratic test problem
rfbar.dI = xm.dI(1);
rfbar.f = xm.f(1);
%User Line: rfbar = xm(1);
ufbar.dI = xm.dI(3);
ufbar.f = xm.f(3);
%User Line: ufbar = xm(3);
vfbar.dI = xm.dI(4);
vfbar.f = xm.f(4);
%User Line: vfbar = xm(4);
cada1f1dI = 2.*ufbar.f.^(2-1).*ufbar.dI;
cada1f1 = ufbar.f^2;
cada1f2dI = 2.*vfbar.f.^(2-1).*vfbar.dI;
cada1f2 = vfbar.f^2;
cada1td1 = zeros(2,1);
cada1td1(1) = cada1f1dI;
cada1td1(2) = cada1td1(2) + cada1f2dI;
cada1f3dI = cada1td1;
cada1f3 = cada1f1 + cada1f2;
cada1f4dI = cada1f3dI./2;
cada1f4 = cada1f3/2;
cada1f5dI = -1./rfbar.f.^2.*rfbar.dI;
cada1f5 = 1/rfbar.f;
cada1td1 = zeros(3,1);
cada1td1(Gator1Data.Index1) = cada1f4dI;
cada1td1(1) = cada1td1(1) + -cada1f5dI;
orbitalEnergy.dI = cada1td1;
orbitalEnergy.f = cada1f4 - cada1f5;
%User Line: orbitalEnergy = (ufbar^2 + vfbar^2)/2 - 1/rfbar;
phi.dI = -orbitalEnergy.dI;
phi.f = uminus(orbitalEnergy.f);
%User Line: phi = - orbitalEnergy;
end


function ADiGator_LoadData()
global ADiGator_phit_1_I_ADiGatorJac
ADiGator_phit_1_I_ADiGatorJac = load('phit_1_I_ADiGatorJac.mat');
return
end