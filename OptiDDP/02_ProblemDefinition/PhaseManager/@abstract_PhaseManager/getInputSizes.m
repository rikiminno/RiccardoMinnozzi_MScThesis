function [nx, nu, nw, nl, nxp, nwp] = getInputSizes(obj)
% function that retrieves the inputs sizes for the current
% phase problem files

nx = obj.nx;
nu = obj.nu;
nw = obj.nw;
nl = obj.nl;
nxp = obj.nxp;
nwp = obj.nwp;
end