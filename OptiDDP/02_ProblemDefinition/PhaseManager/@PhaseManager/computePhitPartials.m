function phitPartials = computePhitPartials(obj, xm, wm, xp, wp, lm, sigma)
% function that evaluates the augmented Lagrangian partials on
% the current inter-phase point, which is defined as [xm, wm,
% xp, wp]

% evaluate full augmented partial
phitPartials = InterPhasePartials();
I = [xm; wm; xp; wp; lm];
phit_I = feval(obj.phit_I_file, I, sigma);
phit_II = feval(obj.phit_II_file, I, sigma);

% get input sizes and assign partials
[nxm, ~, nwm, nlm, nxp, nwp] = obj.getInputSizes();

phitPartials.xm    = getSubMatrix(phit_I, 1, 1, 1, nxm);
phitPartials.wm    = getSubMatrix(phit_I, 1, nxm+1, 1, nwm);
phitPartials.xp    = getSubMatrix(phit_I, 1, nxm+nwm+1, 1, nxp);
phitPartials.wp    = getSubMatrix(phit_I, 1, nxm+nwm+nxp+1, 1, nwp);
phitPartials.lm    = getSubMatrix(phit_I, 1, nxm+nwm+nxp+nwp +1, 1, nlm);
phitPartials.xpxp  = getSubMatrix(phit_II, nxm+nwm+1, nxm+nwm+1, nxp, nxp);
phitPartials.xpwp  = getSubMatrix(phit_II, nxm+nwm+1, nxm+nwm+nxp+1, nxp, nwp);
phitPartials.xpxm  = getSubMatrix(phit_II, nxm+nwm+1, 1, nxp, nxm);
phitPartials.xpwm  = getSubMatrix(phit_II, nxm+nwm+1, nxm+1, nxp, nwm);
phitPartials.xplm  = getSubMatrix(phit_II, nxm+nwm+1, nxm+nwm+nxp+nwp+1, nxp, nlm);
phitPartials.wpwp  = getSubMatrix(phit_II, nxm+nwm+nxp+1, nxm+nwm+nxp+1, nwp, nwp);
phitPartials.wpxm  = getSubMatrix(phit_II, nxm+nwm+nxp+1, 1, nwp, nxm);
phitPartials.wpwm  = getSubMatrix(phit_II, nxm+nwm+nxp+1, nxm+1, nwp, nwm);
phitPartials.wplm  = getSubMatrix(phit_II, nxm+nwm+nxp+1, nxm+nwm+nxp+nwp+1, nwp, nlm);
phitPartials.xmxm  = getSubMatrix(phit_II, 1, 1, nxm, nxm);
phitPartials.xmwm  = getSubMatrix(phit_II, 1, nxm+1, nxm, nwm);
phitPartials.xmlm  = getSubMatrix(phit_II, 1, nxm+nwm+nxp+nwp+1, nxm, nlm);
phitPartials.wmwm  = getSubMatrix(phit_II, nxm+1, nxm+1, nwm, nwm);
phitPartials.wmlm  = getSubMatrix(phit_II, nxm+1, nxm+nwm+nxp+nwp+1, nwm, nlm);
phitPartials.lmlm  = getSubMatrix(phit_II, nxm+nwm+nxp+nwp+1, nxm+nwm+nxp+nwp+1, nlm, nlm);
end