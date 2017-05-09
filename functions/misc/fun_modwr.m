% misc.f
% [frz]
% called by: main;
% call: fun_xzpt; fun_vel; done.

function [frz] = fun_modwr(modout,dx,dz,modi,ifrbnd,frz,xmmin,xmmax)
% output the velocity model on a uniform grid for input to the
% plotting program MODPLT

	global fID_31 fID_32 fID_35 fID_63;
	global b iblk layer npfref nlayer nfrefl pxgrid player s sample xbnd xfrefl ...
		zmin zmax zfrefl;

	global c iblk layer; % for fun_vel
	global b nblk nlayer s xbnd; % for fun_xzpt

	% real vzgrid(pxgrid),xgrid(player+1),xgmt(pxgrid),zgmt(pxgrid)
	% integer igrid(player+1),modi(player),zsmax(pxgrid)

	% 5
	fprintf(fID_31, '%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n', xmmin,xmmax,zmin,zmax,zmin,dx,dz);

	nx = round((xmmax-xmmin)./dx);
	nz = round((zmax-zmin)./dz);

	% 15
	fprintf(fID_31, '%7d%7d%7d%7d%7d%7d%7d%7d%7d%7d\n', nx,nz);

	if abs(modout) == 3
		for jj = 1:nx % 310
			isGoto310 = false;
			for ii = nz:-1:1
				if sample(ii,jj) > 0
					zsmax(jj) = ii;
					isGoto310 = true;
					break;
				end
			end
			if isGoto310, continue; end
			zsmax(jj) = 0;
		end % 310
	end

	for ii = 1:nz+1 % 10
		zmod = zmin + (ii-1).*dz; % float
		for jj = 1:nx+1 % 20
			xmod = xmmin + (jj-1).*dx; % float

			[layer,iblk,iflag] = fun_xzpt(xmod,zmod, b,nblk,nlayer,s,xbnd);

			if iflag == 0
				vzgrid(jj) = fun_vel(xmod,zmod, c,iblk,layer);
			else
				vzgrid(jj) = 9.999;
			end

			xgmt(jj) = xmod;
			zgmt(jj) = zmod;
			if modout <= -2
				zgmt(jj) = -zgmt(jj);
			end
		end % 20

		isGoto112 = false;
		if abs(modout) == 2
			for jj = 1:nx+1 % 110
				iflag = 0;
				if ii > 1 & jj > 1
					if sample(ii-1,jj-1)>0, iflag=1; end
				end
				if ii > 1 & jj <= nx
					if sample(ii-1,jj)>0, iflag=1; end
				end
				if jj > 1 & ii <= nz
					if sample(ii,jj-1)>0, iflag=1; end
				end
				if ii <= nz & jj <= nx
					if sample(ii,jj)>0, iflag=1; end
				end
				if iflag==0, vzgrid(jj)=9.999; end
				if iflag == 1
					jl = jj;
					break; % go to 111
				end
			end % 110

			% 111
			if jl < nx + 1
				for jj = nx+1:-1:jl % 120
					iflag = 0;
					if ii > 1 & jj > 1
						if sample(ii-1,jj-1)>0, iflag=1; end
					end
					if ii > 1 & jj <= nx
						if sample(ii-1,jj)>0, iflag=1; end
					end
					if jj > 1 & ii <= nz
						if sample(ii,jj-1)>0, iflag=1; end
					end
					if ii <= nz & jj <= nx
						if sample(ii,jj)>0, iflag=1; end
					end
					if iflag==0, vzgrid(jj)=9.999; end
					if iflag == 1
						isGoto112=true; break; % go to 112
					end
				end % 120
			end
		end

		if ~ isGoto112
			if abs(modout) == 3
				for jj = 1:nx+1 % 210
					iflag = 0;
					if jj > 1
						if zsmax(jj-1)>=ii, iflag=1; end
					end
					if jj <= nx
						if zsmax(jj)>=ii, iflag=1; end
					end
					if iflag==0, vzgrid(jj)=9.999; end
				end % 210
			end
		end

		% 112 % 25
		fprintf(fID_31, '%10.3f\n', vzgrid(1:nx+1));

		for jj = 1:nx+1 % 130
			if vzgrid(jj) ~= 9.999
				% 35
				fprintf(fID_35, '%10.3f%10.3f%10.3f\n', xgmt(jj),zgmt(jj),vzgrid(jj));
			end
			% 26
			if ii <= nz && jj <= nx
				fprintf(fID_63, '%10.3f%10.3f%10d\n', xgmt(jj),-zgmt(jj),sample(ii,jj));
			end
		end % 130
	end % 10

	isGoto40 = false;
	for ii = nlayer:-1:1 % 30
		if modi(ii) > 0
			nmodi = ii;
			isGoto40 = true; break; % go to 40
		end
	end % 30
	if ~ isGoto40
		nmodi = 0;
	end

	% 40 % 15
	fprintf(fID_31, '%7d%7d%7d%7d%7d%7d%7d%7d%7d%7d\n', nmodi);

	if nmodi > 0
		for ii = 1:nmodi % 50
			igrid(ii) = nx + 1;
			xgrid(ii) = xmmin;
		end % 50

		% 15
		fprintf(fID_31, '%7d', igrid(1:nmodi));
		fprintf(fID_31, '\n');
		% 25
		fprintf(fID_31, '%10.3f', xgrid(1:nmodi));
		fprintf(fID_31, '\n');

		for ii = 1:nmodi % 60
			ii = modi(ii);
			il = ii;
			ib = 1;
			iblk = 1;
			for jj = 1:nx+1 % 70
				x = xmmin + (jj-1).*dx; % float
				if x<xmmin, x=xmmin+0.001; end
				if x>xmmax, x=xmmax-0.001; end
				% 80
				while x<xbnd(il,iblk,1) | x>xbnd(il,iblk,2)
					iblk = iblk + 1;
				end
				vzgrid(jj) = s(il,iblk,ib) .* x + b(il,iblk,ib);
				continue; % go to 70
			end % 70

			% 25
			fprintf(fID_31, '%10.3f', vzgrid(ii:nx+1));
			fprintf(fID_31, '\n');
		end % 60
	end

	if ifrbnd == 1
		if frz==0.0, frz=(zmax-zmin)./1000.0; end
		for ii = 1:nfrefl % 90
			% % 15
			% fprintf(fID_32, '%7d\n', npfref(ii).*2);
			% % 25
			% fprintf(fID_32, '%10.3f', xfref(ii,1:npfref(ii)),zfrefl(ii,1:npfref(ii)),xfrefl(ii,npfref(ii):-1:1),zfrefl(ii,npfref(ii):-1:1)+frz);
			% fprintf(fID_32, '\n');
		end % 90
	end
	return;
end % fun_modwr end
