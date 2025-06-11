function PsiPartials = computePsiPartials(obj, xm, wm, xp, wp, lm)
% function that evaluates the constraints partials on
% the current inter-phase point, which is defined as [xm, wm,
% xp, wp]

% evaluate full augmented partial

I = [xm; wm; xp; wp; lm];
Psi_I = feval(obj.Psi_I_file, I);
Psi_II = feval(obj.Psi_II_file, I);

% get input sizes and assign partials
[nxm, ~, nwm, nlm, nxp, nwp] = obj.getInputSizes();
nPsi = obj.nPsi;
PsiPartials(nPsi) = InterPhasePartials();

for q = 1:nPsi

    % first order partials
    PsiPartials(q).xm = getSubMatrix(Psi_I, q, 1, 1, nxm);
    PsiPartials(q).wm = getSubMatrix(Psi_I, q, nxm+1, 1, nwm);
    PsiPartials(q).xp = getSubMatrix(Psi_I, q, nxm+nwm+1, 1, nxp);
    PsiPartials(q).wp = getSubMatrix(Psi_I, q, nxm+nwm+nxp+1, 1, nwp);
    PsiPartials(q).lm = getSubMatrix(Psi_I, q, nxm+nwm+nxp+nwp +1, 1, nlm);

    % second order partials
    PsiPartials(q).xpxp = getSubMatrix(squeeze(Psi_II(q, :, :)), nxm+nwm+1, nxm+nwm+1, nxp, nxp);
    PsiPartials(q).xpwp = getSubMatrix(squeeze(Psi_II(q, :, :)), nxm+nwm+1, nxm+nwm+nxp+1, nxp, nwp);
    PsiPartials(q).xpxm = getSubMatrix(squeeze(Psi_II(q, :, :)), nxm+nwm+1, 1, nxp, nxm);
    PsiPartials(q).xpwm = getSubMatrix(squeeze(Psi_II(q, :, :)), nxm+nwm+1, nxm+1, nxp, nwm);
    PsiPartials(q).xplm = getSubMatrix(squeeze(Psi_II(q, :, :)), nxm+nwm+1, nxm+nwm+nxp+nwp+1, nxp, nlm);
    PsiPartials(q).wpwp = getSubMatrix(squeeze(Psi_II(q, :, :)), nxm+nwm+nxp+1, nxm+nwm+nxp+1, nwp, nwp);
    PsiPartials(q).wpxm = getSubMatrix(squeeze(Psi_II(q, :, :)), nxm+nwm+nxp+1, 1, nwp, nxm);
    PsiPartials(q).wpwm = getSubMatrix(squeeze(Psi_II(q, :, :)), nxm+nwm+nxp+1, nxm+1, nwp, nwm);
    PsiPartials(q).wplm = getSubMatrix(squeeze(Psi_II(q, :, :)), nxm+nwm+nxp+1, nxm+nwm+nxp+nwp+1, nwp, nlm);
    PsiPartials(q).xmxm = getSubMatrix(squeeze(Psi_II(q, :, :)), 1, 1, nxm, nxm);
    PsiPartials(q).xmwm = getSubMatrix(squeeze(Psi_II(q, :, :)), 1, nxm+1, nxm, nwm);
    PsiPartials(q).xmlm = getSubMatrix(squeeze(Psi_II(q, :, :)), 1, nxm+nwm+nxp+nwp+1, nxm, nlm);
    PsiPartials(q).wmwm = getSubMatrix(squeeze(Psi_II(q, :, :)), nxm+1, nxm+1, nwm, nwm);
    PsiPartials(q).wmlm = getSubMatrix(squeeze(Psi_II(q, :, :)), nxm+1, nxm+nwm+nxp+nwp+1, nwm, nlm);
    PsiPartials(q).lmlm = getSubMatrix(squeeze(Psi_II(q, :, :)), nxm+nwm+nxp+nwp+1, nxm+nwm+nxp+nwp+1, nlm, nlm);
end
end