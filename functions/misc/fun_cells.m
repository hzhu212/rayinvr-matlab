% misc.f
% [~,~,~,~]
% called by: main;
% call: none.

function [npt,xmmin,dx,dz] = fun_cells(npt,xmmin,dx,dz)
% identify grid cells that have been sampled by ray path

	% global file_rayinvr_par file_rayinvr_com;
	% run(file_rayinvr_par);
	% run(file_rayinvr_com);

	global sample xr zmin zr;

	for ii = 1:npt-1 % 10
		nspts = round((((xr(ii+1)-xr(ii)).^2+(zr(ii+1)-zr(ii)).^2).^0.5) ./ min(dx,dz)) + 1;
		if nspts <= 1, nspts = 2; end
		xinc = (xr(ii+1)-xr(ii)) ./ (nspts-1); % float
		zinc = (zr(ii+1)-zr(ii)) ./ (nspts-1); % float
		for jj = 1:nspts % 20
			xrp = xr(ii) + (jj-1) .* xinc; % float
			zrp = zr(ii) + (jj-1) .* zinc; % float
			nx = round((xrp-xmmin)./dx) + 1; % nint -> round
			nz = round((zrp-zmin)./dz) + 1; % nint -> round
			if nx <= 0 || nz <= 0
			    break;
			end
			sample(nz,nx) = sample(nz,nx) + 1;
		end % 20
	end % 10
	return;
end % fun_cells end
