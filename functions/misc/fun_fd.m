% misc.f
% [~,~,~,~]
% called by: main;
% call: fun_xzpt; fun_vel; done.

function [dxz,xmmin,xmmax,ifd] = fun_fd(dxz,xmmin,xmmax,ifd)
% output the velocity model on a uniform grid for input to the
% finite difference program FD

	% global file_rayinvr_par file_rayinvr_com;
	% global fID_35;
	% run(file_rayinvr_par);
	% run(file_rayinvr_com);

	global fID_35;
	global iblk layer pxgrid zmin;

	global b nblk nlayer s xbnd; % for fun_xzpt

	% real vzgrid(pxgrid),xgmt(pxgrid),zgmt(pxgrid)

	nx = fix((xmmax-xmmin) ./ dxz); % int -> int
	nz = fix((zmax-zmin) ./ dxz); % int -> int
	xmmaxr = xmmin + nx .* dxz; % float
	zmaxr = zmin + nz .* dxz; % float

	disp(sprintf('%10.3f%10.3f%10.3f%10.3f%10.3f%10d%10d\n', xmmin,xmmaxr,zmin,zmaxr,dxz,nx+1,nz+1));
	if ifd ~= 2
		% 5
		fprintf(fID_35, '%10.3f%10.3f%10.3f%10.3f%10.3f%10d%10d\n', xmmin,xmmaxr,zmin,zmaxr,dxz,nx+1,nz+1);
	end

	for ii = 1:nz+1 % 10
		zmod = zmin + (ii-1).*dxz; % float
		for jj = 1:nx+1 % 20
			xmod = xmmin + (jj-i).*dxz;

			[layer,iblk,iflag] = fun_xzpt(xmod,zmod, b,nblk,nlayer,s,xbnd);

			if iflag == 0
				vzgrid(jj) = fun_vel(xmod,zmod, c,iblk,layer);
			else
				vzgrid(jj) = 9.999;
			end

			xgmt(jj) = xmod;
			zgmt(jj) = -zmod;
		end % 20

		if ifd ~= 2
			% 25
			fprintf(fID_35, '%10.3f', vzgrid(1:nx+1));
			fprintf(fID_35, '\n');
		else
			for jj = 1:nx+1 % 30
				% 15
				fprintf(fID_35, '%10.3f%10.3f%10.3f\n', xgmt(jj),zgmt(jj),vzgrid(jj));
			end % 30
		end
	end % 10
	return;
end % fun_fd end
