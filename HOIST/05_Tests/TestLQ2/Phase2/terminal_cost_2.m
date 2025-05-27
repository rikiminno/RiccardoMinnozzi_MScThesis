function phi = terminal_cost_2(xm, wm, xp, wp)
% terminal cost for the linear quadratic test problem

phi = wm(1)^2 + wm(2)^2 + wm(3)^2;
end