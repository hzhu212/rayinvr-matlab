% plt.f
% []
% call:
% called by: main;

function fun_pltmod(ncont,ibnd,imod,iaxlab,ivel,velht,idash,ifrbnd,idata,iroute,i33)
% plot the travel time curves for all rays reaching the surface -
% for each group of rays a separate curve is drawn for each
% ray code

	% include 'rayinvr.par'
	% real xh(pnrayf),th(pnrayf),rh(pnrayf),xs(pnrayf),f(pnrayf),
	%      x(pnrayf),t(pnrayf),xshot(1),xsh(pnrayf),fh(pnrayf)
	% character tlab*12
	% integer npts(1),idr(1),ibrka(1),ivraya(1)
	% include 'rayinvr.com'

	global ;

	if itx > 0 || idata ~= 0
		ipflag = 1;
	else
		ipflag = 0;
	end
	xcshot = -999999.0;
	fc = 0.0;
	dashtl = tmm ./ 100.0;
	if vred ~= 0.0
		rvred = 1.0 ./ vred;
	else
		rvred = 0.0;
	end

	if iaxlab == 1
		if vred == 0
			nchart = 8;
			tlab = 'TIME (s)';
			% nchart=9
			% tlab='TIME (ms)'
		else
			i1 = fix(vred); % int -> fix
			id1 = fix((vred-i1).*10 + 0.05); % int -> fix
			id2 = fix((vred-i1-id1./10.0).*100.0 + 0.5); % int -> fix
			if id1 == 0 && id2 == 0
				nchart = 9;
				tlab = 'T-D/  (s)';
				tlab(5) = char(i1+48);
			else
				if id2 == 0
					nchart = 11;
					tlab = 'T-D/    (s)';
					tlab(5:7) = [char(i1+48),'.',char(id1+48)];
				else
					nchart = 12;
					tlab = 'T-D/     (s)';
					tlab(5:8) = [char(i1+48),'.',char(id1+48),char(id2+48)];
				end
			end
		end
	end

	if itrev ~= 1
		tadj = tmin;
	else
		tadj = tmax;
	end

	xshoth = -99999.0;
	fidh = 0.0;
	iflag1 = 0;
	n = 0;
	ib = 0;
	xbmin = orig;
	xbmax = orig + xmmt;
	tbmin = orig;
	tbmax = orig + tmm;

	for ii = 1:ifam % 10

		nh1 = n;

		if npts(ii) > 0
			for jj = 1:npts(ii) % 20
				xh(jj) = range_(jj+nh1);
				th(jj) = tt(jj+nh1);
				rh(jj) = rayid(jj+nh1);
				xsh(jj) = xshtar(jj+nh1);
				fh(jj) = fidarr(jj+nh1);
				n = n+1
			end % 20
			if isep == 2 && (abs(xsh(1)-xshotr) > 0.001 || fh(1) ~= fidrr)
				continue; % go to 10
			end
			if iflag1 == 0
				iflaga = 1;
			else
				if xsh(1) ~= xshota && isep > 1
					iflaga = 1;
				else
					iflaga = 0;
				end
			end
			xshota = xsh(1);
			ida = round(fh(1)); % nint --> round

			if iflaga == 1
				if ipflag == 0
					go to 1010
				end
				if iplots == 0
					fun_plots(xwndow,ywndow,iroute);
					fun_segmnt(1);
					iplots = 1;
				end
			end
		end
	end % 10
end % fun_pltmod end