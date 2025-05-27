function init_opt = computeInitializationPartials(obj, x, w, l, sigma)
% function that computes the optimized cost to go object from
% the last point of the last phase

% initialize output and assemble augmented input
init_opt = OptimizedQuantity();
I = [x; w; 0; 0; l];

% compute the augmented partials
phit_I = feval(obj.phit_I_file, I, sigma);
phit_II = feval(obj.phit_II_file, I, sigma);

% get input sizes and assign partials
[nxm, ~, nwm, nlm, nxp, nwp] = obj.getInputSizes();
nPsi = obj.nPsi;

init_opt.x    = getSubMatrix(phit_I, 1, 1, 1, nxm);
init_opt.w    = getSubMatrix(phit_I, 1, nxm+1, 1, nwm);
init_opt.l    = getSubMatrix(phit_I, 1, nxm+nwm+nxp+nwp+1, 1, nlm);
init_opt.xx   = getSubMatrix(phit_II, 1, 1, nxm, nxm);
init_opt.xw   = getSubMatrix(phit_II, 1, nxm+1, nxm, nwm);
init_opt.xl   = getSubMatrix(phit_II, 1, nxm+nwm+nxp+nwp+1, nxm, nlm);
init_opt.ww   = getSubMatrix(phit_II, nxm+1, nxm+1, nwm, nwm);
init_opt.wl   = getSubMatrix(phit_II, nxm+1, nxm+nwm+nxp+nwp+1, nwm, nlm);
init_opt.ll   = getSubMatrix(phit_II, nxm+nwm+nxp+nwp+1, nxm+nwm+nxp+nwp+1, nlm, nlm);
init_opt.ER = 0;

% concatenate the constraints partials to the init_opt variable
init_opt(2 : nPsi+1) = OptimizedQuantity();

% compute the augmented partials
Psi_I = feval(obj.Psi_I_file, I);
Psi_II = feval(obj.Psi_II_file, I);

% assign the constraint violation partials singularly for each component
for q = 1 : nPsi

    % first order derivatives
    init_opt(q + 1).x = getSubMatrix(Psi_I, q, 1, 1, nxm);
    init_opt(q + 1).w = getSubMatrix(Psi_I, q, nxm+1, 1, nwm);
    init_opt(q + 1).l = getSubMatrix(Psi_I, q, nxm+nwm+nxp+nwp+1, 1, nlm);

    % second order partials
    init_opt(q + 1).xx = getSubMatrix(squeeze(Psi_II(q, :, :)), 1, 1, nxm, nxm);
    init_opt(q + 1).xw = getSubMatrix(squeeze(Psi_II(q, :, :)), 1, nxm+1, nxm, nwm);
    init_opt(q + 1).xl = getSubMatrix(squeeze(Psi_II(q, :, :)), 1, nxm+nwm+nxp+nwp+1, nxm, nlm);
    init_opt(q + 1).ww = getSubMatrix(squeeze(Psi_II(q, :, :)), nxm+1, nxm+1, nwm, nwm);
    init_opt(q + 1).wl = getSubMatrix(squeeze(Psi_II(q, :, :)), nxm+1, nxm+nwm+nxp+nwp+1, nwm, nlm);
    init_opt(q + 1).ll = getSubMatrix(squeeze(Psi_II(q, :, :)), nxm+nwm+nxp+nwp+1, nxm+nwm+nxp+nwp+1, nlm, nlm);

    % expected reduction
    init_opt(q + 1).ER = 0;
end

end