function phi = terminal_cost_1(xm, wm, xp, wp)
% terminal cost for the linear quadratic test problem

rfbar = xm(1);
ufbar = xm(3);
vfbar = xm(4);

orbitalEnergy = (ufbar^2 + vfbar^2)/2 - 1/rfbar;

phi = - orbitalEnergy;
end

