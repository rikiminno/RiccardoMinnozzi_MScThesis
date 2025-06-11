function GammaPartials = computeGammaPartials(obj, w)
% function that computes the values of the initial condition
% partials for the current phase static parameters

GammaPartials = StagePartials();
GammaPartials.w = feval(obj.Gamma_w_file, w);
GammaPartials.ww = feval(obj.Gamma_ww_file, w);
end