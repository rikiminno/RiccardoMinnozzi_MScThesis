function L = running_cost_2(t, x, u, w)
% function that computes the running cost for the linear quadratic test
% problem

L = myNormSquared(u);

end

function n = myNormSquared(vec)
% custom norm function for 3D vector

n = vec(1)^2;
end