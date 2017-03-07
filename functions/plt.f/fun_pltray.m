% plt.f
% [~,~,~,~,istep,~]
% call: fun_line; fun_dashln; fun_ssymbl; fun_empty; fun_plotnd;
% called by: main;

function [npt,nskip,idot,irayps,istep,anglew] = fun_pltray(npt,nskip,idot,irayps,istep,anglew)
% plot one ray path

	% include 'rayinvr.par'
	% real x(ppray),z(ppray),xa(ppray),za(ppray),vra(ppray),vpa(ppray)
	% character reply*1
	% include 'rayinvr.com'

	global ifcol ircol irrcol nbnd nbnda npskp orig ppray ray s sep symht ...
		vp vr xmin xmm xr xscale zmax zr zscale;

	npts = npt - nskip;
	if npts < 2, return; end

	for ii = 1:npts % 180
		x(ii) = (xr(ii+nskip)-xmin)./xscale + orig;
		z(ii) = (zr(ii+nskip)-zmax)./zscale + sep;
		vra(ii) = vr(ii+nskip,2);
		vpa(ii) = vp(ii+nskip,2);
	end % 180

	if npskp ~= 1
		for ii = 1:nbnd % 190
			if nbnda(ii) > nskip+1
				nbnds = ii;
				break; % go to 130
			end
		end % 190

		% 130
		nbnd = nbnd - nbnds + 1;
		for ii = 1:nbnd % 140
			nbnda(ii) = nbnda(ii+nbnds-1) - nskip;
		end % 140
		npts = 1;
		np1 = 2;
		for jj = 1:nbnd % 110
			if nbnda(jj) > np1 && nbnda(jj)-np1 > npskp
				for ii = np1:npskp:nbnda(jj)-1 % 120
					npts = npts + 1;
					x(npts) = x(ii);
					z(npts) = z(ii);
					vra(npts) = vra(ii);
					vpa(npts) = vpa(ii);
				end % 120
			end
			npts = npts + 1;
			x(npts) = x(nbnda(jj));
			z(npts) = z(nbnda(jj));
			vra(npts) = vra(nbnda(jj));
			vpa(npts) = vpa(nbnda(jj));
			np1 = nbnda(jj) + 1;
		end % 110
	end

	if istep == 1
		% 5
		fprintf('take-off angle: %10.5f\n', anglew);
	end

	if ircol ~= 0
		fun_pcolor(irrcol);
	end

	isGoto100 = false;
	if idot == 2, isGoto100 = true; end % go to 100
	if ~ isGoto100 % -------------------- block ~isGoto100 begin
		if irayps ~= 1
			fun_line(x,z,npts);
		else
			dash = xmm ./ 250.0;
			na = 0;
			if vra(1) == vpa(1)
				ips = 1;
			else
				ips = -1;
			end
			for ii = 1:npts-1 % 30
				if vra(ii) == vpa(ii)
					if ips ~= 1
						na = na + 1;
						xa(na) = x(ii);
						za(na) = z(ii);
						fun_dashln(xa,za,na,dash);
						na = 0;
						ips = 1;
					end
					na = na + 1;
					xa(na) = x(ii);
					za(na) = z(ii);
				else
					if ips ~= -1
						na = na + 1;
						xa(na) = x(ii);
						za(na) = z(ii);
						fun_line(xa,za,na);
						na = 0;
						ips = -1;
					end
					na = na + 1;
					xa(na) = x(ii);
					za(na) = z(ii);
				end
			end % 30
			na = na + 1;
			xa(na) = x(npts);
			za(na) = z(npts);
			if ips == 1
				fun_line(xa,za,na);
			else
				fun_dashln(xa,za,na,dash);
			end
		end
	end % -------------------- block ~isGoto100 end

	% 100
	if idot > 0
		for ii = 1:npts % 20
			fun_ssymbl(x(ii),z(ii),symht,4);
		end % 20
	end

	if ircol ~= 0
		fun_pcolor(ifcol);
	end

	if istep == 1
		fun_empty();
		% 15
		reply = input('please input: ','s');
		if reply(1) == 's'
			fun_plotnd(1);
			error('e:stop','initiative stop in fun_pltray');
		end
		if reply(1) == '0', istep = 0; end
	end

	return;
end % fun_pltray end