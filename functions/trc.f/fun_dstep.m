% trc.f
% [dstep]
% called by: fun_trace;
% call: fun_vel; done.

% fortran function

function [dstep] = fun_dstep(x,z)
% calculate ray step length - step length is a function of the
% absolute value of the velocity divided by the sum of the
% absolute values of the velocity gradients in the x and z
% directions

	% global file_rayinvr_par file_rayinvr_com;
	% run(file_rayinvr_par);
	% run(file_rayinvr_com);

	global c iblk layer smax smin step_;

	vx = (c(layer,iblk,8).*x + c(layer,iblk,9).*x.*x + c(layer,iblk,10).*z + ...
		c(layer,iblk,11)) ./ (c(layer,iblk,6).*x + c(layer,iblk,7)).^2;
	vz = (c(layer,iblk,3) + c(layer,iblk,4).*x) ./ (c(layer,iblk,6).*x + ...
		c(layer,iblk,7));
	dstep = step_ .* fun_vel(x,z) ./ (abs(vx)+abs(vz));

	if dstep < smin
	    dstep = smin;
	end
	if dstep > smax
	    dstep = smax;
	end
    return;
end % fun_dstep end