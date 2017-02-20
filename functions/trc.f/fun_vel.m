% trc.f
% [vel]
% called by: fun_modwr; fun_fd;
% call: none.

% fortran function

function [vel] = fun_vel(x,z)
% calculate p-wave velocity at point (x,z) in model

	global file_rayinvr_par file_rayinvr_com;
	run(file_rayinvr_par);
	run(file_rayinvr_com);

	vel=(c(layer,iblk,1).*x + c(layer,iblk,2).*x.^2 + c(layer,iblk,3).*z + ...
		c(layer,iblk,4).*x.*z + c(layer,iblk,5)) ./ (c(layer,iblk,6).*x + ...
		c(layer,iblk,7));

    return;
end % fun_vel end