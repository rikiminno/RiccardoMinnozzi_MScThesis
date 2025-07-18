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

function phit_I = phit_1_II_ADiGatorJac(I,sigma)
global ADiGator_phit_1_II_ADiGatorJac
if isempty(ADiGator_phit_1_II_ADiGatorJac); ADiGator_LoadData(); end
Gator1Data = ADiGator_phit_1_II_ADiGatorJac.phit_1_II_ADiGatorJac.Gator1Data;
% ADiGator Start Derivative Computations
gator_I.f.dI = I.dI; gator_I.f.f = I.f;
%User Line: gator_I.f = I;
gator_I.dI.f = Gator1Data.Data1;
%User Line: gator_I.dI = ones(17,1);
cadainput2_1 = gator_I;
cadainput2_1.dI = gator_I.dI.f;
cadainput2_1.f = gator_I.f.f;
%User Line: cadainput2_1 = gator_I;
cadainput2_2 = sigma;
%User Line: cadainput2_2 = sigma;
cadaoutput2_1 = phit_1_I_ADiGatorJac(cadainput2_1,cadainput2_2);
% Call to function: phit_1_I_ADiGatorJac
phit = cadaoutput2_1;
%User Line: phit = cadaoutput2_1;
phit_I.f =  zeros(1,17);
%User Line: phit_I = zeros(1,17);
phit_I.dI = phit.dIdI;
phit_I.f(phit.dI_location) = phit.dI;
%User Line: phit_I(phit.dI_location) = phit.dI;
phit_I.dI_size = [17,17];
phit_I.dI_location = Gator1Data.Index1;
end
function phit = phit_1_I_ADiGatorJac(I,sigma)
global ADiGator_phit_1_II_ADiGatorJac
Gator1Data = ADiGator_phit_1_II_ADiGatorJac.phit_1_I_ADiGatorJac.Gator1Data;
Gator2Data = ADiGator_phit_1_II_ADiGatorJac.phit_1_I_ADiGatorJac.Gator2Data;
% ADiGator Start Derivative Computations
%User Line: % Augmented Lagrangian wrapper function for phase 1,
%User Line: % automatically generated by the PhaseManager class on 12-Jul-2024 15:11:37
xm.dI = I.dI(Gator1Data.Index2);
% Deriv 1 Line: xm.dI = I.dI(Gator1Data.Index2);
xm.f = I.f(Gator1Data.Index1,1);
% Deriv 1 Line: xm.f = I.f(Gator1Data.Index1,1);
%User Line: xm = I(1: 6, 1);
wm.dI = I.dI(7);
% Deriv 1 Line: wm.dI = I.dI(7);
wm.f = I.f(7,1);
% Deriv 1 Line: wm.f = I.f(7,1);
%User Line: wm = I(7: 7, 1);
xp.dI = I.dI(Gator1Data.Index4);
% Deriv 1 Line: xp.dI = I.dI(Gator1Data.Index4);
xp.f = I.f(Gator1Data.Index3,1);
% Deriv 1 Line: xp.f = I.f(Gator1Data.Index3,1);
%User Line: xp = I(8: 9, 1);
wp.dI = I.dI(Gator1Data.Index6);
% Deriv 1 Line: wp.dI = I.dI(Gator1Data.Index6);
wp.f = I.f(Gator1Data.Index5,1);
% Deriv 1 Line: wp.f = I.f(Gator1Data.Index5,1);
%User Line: wp = I(10: 11, 1);
lm.dI = I.dI(Gator1Data.Index8);
% Deriv 1 Line: lm.dI = I.dI(Gator1Data.Index8);
lm.f = I.f(Gator1Data.Index7,1);
% Deriv 1 Line: lm.f = I.f(Gator1Data.Index7,1);
%User Line: lm = I(12: 17, 1);
cadainput3_1.dI = xm.dI;
% Deriv 1 Line: cadainput3_1.dI = xm.dI;
cadainput3_1.f = xm.f;
% Deriv 1 Line: cadainput3_1.f = xm.f;
%User Line: cadainput3_1 = xm;
cadainput3_2.dI = wm.dI;
% Deriv 1 Line: cadainput3_2.dI = wm.dI;
cadainput3_2.f = wm.f;
% Deriv 1 Line: cadainput3_2.f = wm.f;
%User Line: cadainput3_2 = wm;
cadainput3_3.dI = xp.dI;
% Deriv 1 Line: cadainput3_3.dI = xp.dI;
cadainput3_3.f = xp.f;
% Deriv 1 Line: cadainput3_3.f = xp.f;
%User Line: cadainput3_3 = xp;
cadainput3_4.dI = wp.dI;
% Deriv 1 Line: cadainput3_4.dI = wp.dI;
cadainput3_4.f = wp.f;
% Deriv 1 Line: cadainput3_4.f = wp.f;
%User Line: cadainput3_4 = wp;
cadainput4_1 = cadainput3_1;
% Deriv 1 Line: cadainput4_1 = cadainput3_1;
cadainput4_2 = cadainput3_2;
% Deriv 1 Line: cadainput4_2 = cadainput3_2;
cadainput4_3 = cadainput3_3;
% Deriv 1 Line: cadainput4_3 = cadainput3_3;
cadainput4_4 = cadainput3_4;
% Deriv 1 Line: cadainput4_4 = cadainput3_4;
cadaoutput4_1 = ADiGator_terminal_cost_11(cadainput4_1,cadainput4_2,cadainput4_3,cadainput4_4);
% Call to function: ADiGator_terminal_cost_11
cadaoutput3_1 = cadaoutput4_1;
% Deriv 1 Line: cadaoutput3_1 = cadaoutput4_1;
% Call to function: terminal_cost_1
phi.f = cadaoutput3_1.f;
% Deriv 1 Line: phi.f = cadaoutput3_1.f;
%User Line: phi = cadaoutput3_1;
cadainput2_1.dI = xm.dI;
% Deriv 1 Line: cadainput2_1.dI = xm.dI;
cadainput2_1.f = xm.f;
% Deriv 1 Line: cadainput2_1.f = xm.f;
%User Line: cadainput2_1 = xm;
cadainput2_2.dI = wm.dI;
% Deriv 1 Line: cadainput2_2.dI = wm.dI;
cadainput2_2.f = wm.f;
% Deriv 1 Line: cadainput2_2.f = wm.f;
%User Line: cadainput2_2 = wm;
cadainput2_3.dI = xp.dI;
% Deriv 1 Line: cadainput2_3.dI = xp.dI;
cadainput2_3.f = xp.f;
% Deriv 1 Line: cadainput2_3.f = xp.f;
%User Line: cadainput2_3 = xp;
cadainput2_4.dI = wp.dI;
% Deriv 1 Line: cadainput2_4.dI = wp.dI;
cadainput2_4.f = wp.f;
% Deriv 1 Line: cadainput2_4.f = wp.f;
%User Line: cadainput2_4 = wp;
cadainput3_1 = cadainput2_1;
% Deriv 1 Line: cadainput3_1 = cadainput2_1;
cadainput3_2 = cadainput2_2;
% Deriv 1 Line: cadainput3_2 = cadainput2_2;
cadainput3_3 = cadainput2_3;
% Deriv 1 Line: cadainput3_3 = cadainput2_3;
cadainput3_4 = cadainput2_4;
% Deriv 1 Line: cadainput3_4 = cadainput2_4;
cadaoutput3_1 = ADiGator_terminal_constraint_11(cadainput3_1,cadainput3_2,cadainput3_3,cadainput3_4);
% Call to function: ADiGator_terminal_constraint_11
cadaoutput2_1 = cadaoutput3_1;
% Deriv 1 Line: cadaoutput2_1 = cadaoutput3_1;
% Call to function: terminal_constraint_1
Psi.dI = cadaoutput2_1.dI;
% Deriv 1 Line: Psi.dI = cadaoutput2_1.dI;
Psi.f = cadaoutput2_1.f;
% Deriv 1 Line: Psi.f = cadaoutput2_1.f;
%User Line: Psi = cadaoutput2_1;
cada1f1dI = lm.dI;
% Deriv 1 Line: cada1f1dI = lm.dI;
cada1f1 = lm.f.';
% Deriv 1 Line: cada1f1 = lm.f.';
cada1td2 =  zeros(6,6);
% Deriv 1 Line: cada1td2 = zeros(6,6);
cada1td2(Gator1Data.Index9) = cada1f1dI;
% Deriv 1 Line: cada1td2(Gator1Data.Index9) = cada1f1dI;
cada2f1dI = Psi.dI;
cada2f1 = Psi.f.';
cada2td1 = zeros(6,8);
cada2td1(Gator2Data.Index1) = cada2f1dI;
cada2td1 = cada1td2.'*cada2td1;
cada2td1 = cada2td1(:);
cada1td2dI = cada2td1(Gator2Data.Index2);
cada1td2 = cada2f1*cada1td2;
% Deriv 1 Line: cada1td2 = Psi.f.'*cada1td2;
cada1td1 =  zeros(14,1);
% Deriv 1 Line: cada1td1 = zeros(14,1);
cada2f1dI = cada1td2dI(Gator2Data.Index3);
cada2f1 = cada1td2(Gator1Data.Index10);
cada1td1dI = cada2f1dI;
cada1td1(Gator1Data.Index11) = cada2f1;
% Deriv 1 Line: cada1td1(Gator1Data.Index11) = cada1td2(Gator1Data.Index10);
cada1td2 =  zeros(6,8);
% Deriv 1 Line: cada1td2 = zeros(6,8);
cada1td2(Gator1Data.Index12) = Psi.dI;
% Deriv 1 Line: cada1td2(Gator1Data.Index12) = Psi.dI;
cada2td1 = zeros(6,6);
cada2td1(Gator2Data.Index4) = cada1f1dI;
cada2td1 = cada1td2.'*cada2td1;
cada2td1 = cada2td1(:);
cada1td2dI = cada2td1(Gator2Data.Index5);
cada1td2 = cada1f1*cada1td2;
% Deriv 1 Line: cada1td2 = cada1f1*cada1td2;
cada1td2 = cada1td2(:);
% Deriv 1 Line: cada1td2 = cada1td2(:);
cada2f1 = cada1td1(Gator1Data.Index14);
cada2f2dI = cada1td2dI(Gator2Data.Index6);
cada2f2 = cada1td2(Gator1Data.Index13);
cada2f3dI = cada2f2dI;
cada2f3 = cada2f1 + cada2f2;
cada2td1 = zeros(16,1);
cada2td1(Gator2Data.Index7) = cada2f3dI;
cada2td1(Gator2Data.Index8) = cada1td1dI(Gator2Data.Index9);
cada1td1dI = cada2td1;
cada1td1(Gator1Data.Index14) = cada2f3;
% Deriv 1 Line: cada1td1(Gator1Data.Index14) = cada1td1(Gator1Data.Index14) + cada1td2(Gator1Data.Index13);
cada1f2dIdI = cada1td1dI; cada1f2dI = cada1td1;
% Deriv 1 Line: cada1f2dI = cada1td1;
cada1f2 = cada1f1*Psi.f;
% Deriv 1 Line: cada1f2 = cada1f1*Psi.f;
cada1f3dIdI = cada1f2dIdI; cada1f3dI = cada1f2dI;
% Deriv 1 Line: cada1f3dI = cada1f2dI;
cada1f3 = phi.f + cada1f2;
% Deriv 1 Line: cada1f3 = phi.f + cada1f2;
cada1f4dI = Psi.dI;
% Deriv 1 Line: cada1f4dI = Psi.dI;
cada1f4 = Psi.f.';
% Deriv 1 Line: cada1f4 = Psi.f.';
cada1td2 =  zeros(6,8);
% Deriv 1 Line: cada1td2 = zeros(6,8);
cada1td2(Gator1Data.Index15) = cada1f4dI;
% Deriv 1 Line: cada1td2(Gator1Data.Index15) = cada1f4dI;
cada2f1dI = Psi.dI;
cada2f1 = Psi.f.';
cada2td1 = zeros(6,8);
cada2td1(Gator2Data.Index10) = cada2f1dI;
cada2td1 = cada1td2.'*cada2td1;
cada2td1 = cada2td1(:);
cada1td2dI = cada2td1(Gator2Data.Index11);
cada1td2 = cada2f1*cada1td2;
% Deriv 1 Line: cada1td2 = Psi.f.'*cada1td2;
cada1td1dI = cada1td2dI(Gator2Data.Index12);
cada1td1 = cada1td2(Gator1Data.Index16);
% Deriv 1 Line: cada1td1 = cada1td2(Gator1Data.Index16);
cada1td1 = cada1td1(:);
% Deriv 1 Line: cada1td1 = cada1td1(:);
cada1td2 =  zeros(6,8);
% Deriv 1 Line: cada1td2 = zeros(6,8);
cada1td2(Gator1Data.Index17) = Psi.dI;
% Deriv 1 Line: cada1td2(Gator1Data.Index17) = Psi.dI;
cada2td1 = zeros(6,8);
cada2td1(Gator2Data.Index13) = cada1f4dI;
cada2td1 = cada1td2.'*cada2td1;
cada2td1 = cada2td1(:);
cada1td2dI = cada2td1(Gator2Data.Index14);
cada1td2 = cada1f4*cada1td2;
% Deriv 1 Line: cada1td2 = cada1f4*cada1td2;
cada1td2 = cada1td2(:);
% Deriv 1 Line: cada1td2 = cada1td2(:);
cada2f1dI = cada1td2dI(Gator2Data.Index15);
cada2f1 = cada1td2(Gator1Data.Index18);
cada2td1 = cada1td1dI;
cada2td1 = cada2td1 + cada2f1dI;
cada1td1dI = cada2td1;
cada1td1 = cada1td1 + cada2f1;
% Deriv 1 Line: cada1td1 = cada1td1 + cada1td2(Gator1Data.Index18);
cada1f5dIdI = cada1td1dI; cada1f5dI = cada1td1;
% Deriv 1 Line: cada1f5dI = cada1td1;
cada1f5 = cada1f4*Psi.f;
% Deriv 1 Line: cada1f5 = cada1f4*Psi.f;
cada1f6dIdI = sigma.*cada1f5dIdI;
cada1f6dI = sigma*cada1f5dI;
% Deriv 1 Line: cada1f6dI = sigma.*cada1f5dI;
cada1f6 = sigma*cada1f5;
% Deriv 1 Line: cada1f6 = sigma*cada1f5;
cada1td1dI = cada1f3dIdI; cada1td1 = cada1f3dI;
% Deriv 1 Line: cada1td1 = cada1f3dI;
cada2f1dI = cada1td1dI(Gator2Data.Index16);
cada2f1 = cada1td1(Gator1Data.Index19);
cada2td1 = zeros(20,1);
cada2td1(Gator2Data.Index17) = cada2f1dI;
cada2td1(Gator2Data.Index18) = cada2td1(Gator2Data.Index18) + cada1f6dIdI;
cada2f2dI = cada2td1;
cada2f2 = cada2f1 + cada1f6dI;
cada2td1 = zeros(28,1);
cada2td1(Gator2Data.Index19) = cada2f2dI;
cada2td1(Gator2Data.Index20) = cada1td1dI(Gator2Data.Index21);
cada1td1dI = cada2td1;
cada1td1(Gator1Data.Index19) = cada2f2;
% Deriv 1 Line: cada1td1(Gator1Data.Index19) = cada1td1(Gator1Data.Index19) + cada1f6dI;
phit.dIdI = cada1td1dI; phit.dI = cada1td1;
% Deriv 1 Line: phit.dI = cada1td1;
phit.f = cada1f3 + cada1f6;
% Deriv 1 Line: phit.f = cada1f3 + cada1f6;
%User Line: phit = phi + lm' * Psi + sigma * (Psi' * Psi);
phit.dI_size = 17;
% Deriv 1 Line: phit.dI_size = 17;
phit.dI_location = Gator1Data.Index20;
% Deriv 1 Line: phit.dI_location = Gator1Data.Index20;
end
function Psi = ADiGator_terminal_constraint_11(xm,wm,xp,wp)
global ADiGator_phit_1_II_ADiGatorJac
Gator1Data = ADiGator_phit_1_II_ADiGatorJac.ADiGator_terminal_constraint_11.Gator1Data;
Gator2Data = ADiGator_phit_1_II_ADiGatorJac.ADiGator_terminal_constraint_11.Gator2Data;
% ADiGator Start Derivative Computations
%User Line: % function that implements the terminal constraints for the current phase
Psi.f = [0;0;0;0;0;0];
% Deriv 1 Line: Psi.f =  zeros(6, 1);
%User Line: Psi = zeros(6, 1);
cada1f1dI = xp.dI(1);
% Deriv 1 Line: cada1f1dI = xp.dI(1);
cada1f1 = xp.f(1);
% Deriv 1 Line: cada1f1 = xp.f(1);
cada1f2dI = xm.dI(1);
% Deriv 1 Line: cada1f2dI = xm.dI(1);
cada1f2 = xm.f(1);
% Deriv 1 Line: cada1f2 = xm.f(1);
cada1td1 =  zeros(2,1);
% Deriv 1 Line: cada1td1 = zeros(2,1);
cada1td1(2) = cada1f1dI;
% Deriv 1 Line: cada1td1(2) = cada1f1dI;
cada2f1 = cada1td1(1);
cada2f2 = uminus(cada1f2dI);
cada2f3 = cada2f1 + cada2f2;
cada1td1(1) = cada2f3;
% Deriv 1 Line: cada1td1(1) = cada1td1(1) + -cada1f2dI;
cada1f3dI = cada1td1;
% Deriv 1 Line: cada1f3dI = cada1td1;
cada1f3 = cada1f1 - cada1f2;
% Deriv 1 Line: cada1f3 = cada1f1 - cada1f2;
Psi.dI = cada1f3dI;
% Deriv 1 Line: Psi.dI = cada1f3dI;
Psi.f(1) = cada1f3;
% Deriv 1 Line: Psi.f(1) = cada1f3;
%User Line: Psi(1) = xp(1) - xm(1);
cada1f1dI = xp.dI(2);
% Deriv 1 Line: cada1f1dI = xp.dI(2);
cada1f1 = xp.f(2);
% Deriv 1 Line: cada1f1 = xp.f(2);
cada1f2dI = xm.dI(4);
% Deriv 1 Line: cada1f2dI = xm.dI(4);
cada1f2 = xm.f(4);
% Deriv 1 Line: cada1f2 = xm.f(4);
cada1td1 =  zeros(2,1);
% Deriv 1 Line: cada1td1 = zeros(2,1);
cada1td1(2) = cada1f1dI;
% Deriv 1 Line: cada1td1(2) = cada1f1dI;
cada2f1 = cada1td1(1);
cada2f2 = uminus(cada1f2dI);
cada2f3 = cada2f1 + cada2f2;
cada1td1(1) = cada2f3;
% Deriv 1 Line: cada1td1(1) = cada1td1(1) + -cada1f2dI;
cada1f3dI = cada1td1;
% Deriv 1 Line: cada1f3dI = cada1td1;
cada1f3 = cada1f1 - cada1f2;
% Deriv 1 Line: cada1f3 = cada1f1 - cada1f2;
cada1td1 =  zeros(4,1);
% Deriv 1 Line: cada1td1 = zeros(4,1);
cada1td1(Gator1Data.Index1) = cada1f3dI;
% Deriv 1 Line: cada1td1(Gator1Data.Index1) = cada1f3dI;
cada2f1 = Psi.dI(Gator1Data.Index3);
cada1td1(Gator1Data.Index2) = cada2f1;
% Deriv 1 Line: cada1td1(Gator1Data.Index2) = Psi.dI(Gator1Data.Index3);
Psi.dI = cada1td1;
% Deriv 1 Line: Psi.dI = cada1td1;
Psi.f(4) = cada1f3;
% Deriv 1 Line: Psi.f(4) = cada1f3;
%User Line: Psi(4) = xp(2) - xm(4);
cada1f1dI = xm.dI(Gator1Data.Index5);
% Deriv 1 Line: cada1f1dI = xm.dI(Gator1Data.Index5);
cada1f1 = xm.f(Gator1Data.Index4);
% Deriv 1 Line: cada1f1 = xm.f(Gator1Data.Index4);
cada1f2dI = cada1f1dI;
% Deriv 1 Line: cada1f2dI = cada1f1dI;
cada1f2 = cada1f1 - Gator1Data.Data1;
% Deriv 1 Line: cada1f2 = cada1f1 - Gator1Data.Data1;
cada1td1 =  zeros(6,1);
% Deriv 1 Line: cada1td1 = zeros(6,1);
cada1td1(Gator1Data.Index7) = cada1f2dI;
% Deriv 1 Line: cada1td1(Gator1Data.Index7) = cada1f2dI;
cada2f1 = Psi.dI(Gator1Data.Index9);
cada1td1(Gator1Data.Index8) = cada2f1;
% Deriv 1 Line: cada1td1(Gator1Data.Index8) = Psi.dI(Gator1Data.Index9);
Psi.dI = cada1td1;
% Deriv 1 Line: Psi.dI = cada1td1;
Psi.f(Gator1Data.Index6) = cada1f2;
% Deriv 1 Line: Psi.f(Gator1Data.Index6) = cada1f2;
%User Line: Psi(2:3) = xm(2:3) - [1; 0];
cada1f1dI = xm.dI(Gator1Data.Index11);
% Deriv 1 Line: cada1f1dI = xm.dI(Gator1Data.Index11);
cada1f1 = xm.f(Gator1Data.Index10);
% Deriv 1 Line: cada1f1 = xm.f(Gator1Data.Index10);
cada1f2dI = cada1f1dI;
% Deriv 1 Line: cada1f2dI = cada1f1dI;
cada1f2 = cada1f1 - Gator1Data.Data2;
% Deriv 1 Line: cada1f2 = cada1f1 - Gator1Data.Data2;
cada1td1 =  zeros(8,1);
% Deriv 1 Line: cada1td1 = zeros(8,1);
cada1td1(Gator1Data.Index13) = cada1f2dI;
% Deriv 1 Line: cada1td1(Gator1Data.Index13) = cada1f2dI;
cada2f1 = Psi.dI(Gator1Data.Index15);
cada1td1(Gator1Data.Index14) = cada2f1;
% Deriv 1 Line: cada1td1(Gator1Data.Index14) = Psi.dI(Gator1Data.Index15);
Psi.dI = cada1td1;
% Deriv 1 Line: Psi.dI = cada1td1;
Psi.f(Gator1Data.Index12) = cada1f2;
% Deriv 1 Line: Psi.f(Gator1Data.Index12) = cada1f2;
%User Line: Psi(5:6) = xm(5:6) - [0; 0];
end
function phi = ADiGator_terminal_cost_11(xm,wm,xp,wp)
global ADiGator_phit_1_II_ADiGatorJac
Gator1Data = ADiGator_phit_1_II_ADiGatorJac.ADiGator_terminal_cost_11.Gator1Data;
Gator2Data = ADiGator_phit_1_II_ADiGatorJac.ADiGator_terminal_cost_11.Gator2Data;
% ADiGator Start Derivative Computations
%User Line: % terminal cost for the linear quadratic test problem
phi.f = 0;
% Deriv 1 Line: phi.f =  0;
%User Line: phi = 0;
end


function ADiGator_LoadData()
global ADiGator_phit_1_II_ADiGatorJac
ADiGator_phit_1_II_ADiGatorJac = load('phit_1_II_ADiGatorJac.mat');
return
end