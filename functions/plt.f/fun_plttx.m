% plt.f
% []
% call: fun_plot; fun_axtick; fun_axis; fun_empty; fun_plots; fun_segmnt; fun_aldone;
% fun_pcolor; fun_erase; fun_ssymbl; fun_box; fun_symbol; fun_dashln; fun_pltdat; fun_dot;
% called by: main;

function fun_plttx(ifam,npts,iszero,idata,iaxlab,xshot,idr,nshot,itxout,ibrka,ivraya,ttunc,itrev,xshotr,fidrr,itxbox,iroute,iline)
% plot the travel time curves for all rays reaching the surface -
% for each group of rays a separate curve is drawn for each
% ray code

	% include 'rayinvr.par'
	% real xh(pnrayf),th(pnrayf),rh(pnrayf),xs(pnrayf),f(pnrayf),
	%      x(pnrayf),t(pnrayf),xshot(1),xsh(pnrayf),fh(pnrayf)
	% character tlab*12
	% integer npts(1),idr(1),ibrka(1),ivraya(1)
	% include 'rayinvr.com'

	global fID_17;
	global albht colour fidarr icalc ifcol iplots ircalc isep itcol ititle itx ...
		narinv ncol ndecit ndecxt ntckxt ntickt orig pnrayf range_ ray rayid ...
		s symht tcalc time title_ tmax tmin tmm tobs tscale tt ttmax ttmin ...
		uobs vred xcalc xmaxt xmint xmmt xscalc xscalt xshtar xtitle xtmaxt ...
		xtmint xwndow ytitle ywndow;

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
				n = n + 1;
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
				isGoto1010 = false;

				if ipflag == 0
					isGoto1010 = true; % go to 1010
				end
				if ~ isGoto1010 % -------------------- block ~isGoto1010 begin
					if iplots == 0
						fun_plots(xwndow,ywndow,iroute);
						fun_segmnt(1);
						iplots = 1;
					end
					if (isep < 2 || isep == 3) && iflag1 ~= 0
						fun_empty();
						fun_aldone();
					end
					if (isep < 2 || isep == 3) && (iflag1 ~= 0 || isep == 1.0 || isep == 3)
						fun_erase();
						ititle = 0;
					end

					if iaxlab == 1
						[~,~,xtmint,xtmaxt,ntckxt,ndecxt] = fun_axtick(xmint,xmaxt,xtmint,xtmaxt,ntckxt,ndecxt);
						[~,~,ttmin,ttmax,ntickt,ndecit] = fun_axtick(tmin,tmax,ttmin,ttmax,ntickt,ndecit);

						% call axis(orig,orig,xmint,xmaxt,xmmt,xscalt,0.,1,xtmint,xtmaxt,ntckxt,ndecxt,'OFFSET (m)',10,albht)
						fun_axis(orig,orig,xmint,xmaxt,xmmt,xscalt,0.0,1,xtmint,xtmaxt,ntckxt,ndecxt,'DISTANCE (km)',13,albht);
						fun_axis(orig,orig,tmin,tmax,tmm,tscale,90.0,1,ttmin,ttmax,ntickt,ndecit,tlab,nchart,albht);
					end
					fun_box(orig,orig,orig+xmmt,orig+tmm);

					if ititle == 0 & title_ ~= ' '
						if xtitle < -999999.0, xtitle = 0.0; end
						if ytitle < -999999.0, ytitle = 0.0; end
						fun_symbol(xtitle,ytitle,albht,title_,0.0,80);
						ititle = 1;
					end

					if itx == 4
						ntlmax = fix(tmax - 0.001) % int --> fix
						for jj = 1:ntlmax % 310
							tp = (jj-tadj) ./ tscale + orig;
							x(1) = orig;
							x(2) = orig + xmmt;
							t(1) = tp;
							t(2) = tp;
							fun_dashln(x,t,2,dashtl);
						end % 310
					end

					if idata ~= 0
						fun_pltdat(iszero,idata,xshot,idr,nshot,tadj,xshota,xbmin,xbmax,tbmin,tbmax,itxbox,ida);
					end
				end % -------------------- block ~isGoto1010 end

				% 1010
				if (itx >= 3 || itxout == 3) && narinv > 0
					ichold = -999999;
					for jj = 1:narinv % 120
						if (abs(xscalc(jj)-xshota) < 0.001 && icalc(jj).*fh(1) > 0.0 && isep == 2) ...
							|| (abs(xscalc(jj)-xshota) < 0.001 && isep == 3) || isep < 2
							if itx >= 3
								xplot = (xcalc(jj)-xmint) ./ xscalt + orig;
								if itx == 3
									tplot = (tcalc(jj)-tadj) ./ tscale + orig;
								else
									tplot = (tcalc(jj)-tobs(jj)+abs(icalc(jj))-tadj) ./ tscale + orig;
								end
								if itxbox == 0 || (xplot >= xbmin && xplot <= xbmax && tplot >= tbmin && tplot <= tbmax)
									if itcol == 3
										ipcol = colour(mod(ircalc(jj)-1,ncol)+1);
										fun_pcolor(ipcol);
									end
									if iline == 0
										% call ssymbl(xplot,tplot,symht,4)
										% call ssymbl(xplot,tplot,symht,3)
										fun_dot(xplot,tplot,symht,ifcol);
									else
										if ircalc(jj) == ichold
											fun_plot(xplot,tplot,2);
										else
											fun_plot(xplot,tplot,3);
											ichold = ircalc(jj);
										end
									end
								end
							end
							if itxout == 3
								% fcalc=sign(1.,icalc(jj))
								fcalc = sign(icalc(jj)) .* 1.0;
								if xscalc(jj) ~= xcshot || fcalc ~= fc
									if iszero ~= 1
										% 5
										fprintf(fID_17, '%10.3f%10.3f%10.3f%10d\n', xs(1),f(1),0.0,0);
										xsr = xs(1);
									else
										fprintf(fID_17, '%10.3f%10.3f%10.3f%10d\n', 0.0,1.0,0.0,0);
										xsr = 0.0;
									end
								end
								xcshot = xscalc(jj);
								fc = fcalc;
								twrite = tcalc(jj) + abs(xcalc(jj)-xsr).*rvred;
								% write(17,5) xcalc(jj),twrite,ttunc,abs(icalc(jj))
								fprintf(fID_17, '%10.3f%10.3f%10.3f%10d\n', xcalc(jj),twrite,uobs(jj),abs(icalc(jj)));
							end
						end
					end % 120
					if itx >= 3 && itcol == 3
						fun_pcolor(ifcol);
					end
				end
			end

			iflag1 = 1;

			if itx ~= 1 && itx ~= 2 && itxout ~= 1 && itxout ~= 2
				continue; % go to 10
			end

			nh2 = 0;

			% 1000 % -------------------- cycle1000 begin
			while nh2 < npts(ii)
				k = 0;

				% 100 % -------------------- cycle100 begin
				cycle100 = true;
				while cycle100
					k = k + 1;
					if (k+nh2) <= npts(ii)
						x(k) = (xh(k+nh2)-xmint)./xscalt + orig;
						t(k) = (th(k+nh2)-tadj)./tscale + orig;
						xs(k) = xsh(k+nh2);
						f(k) = fh(k+nh2);
						if k == 1
							rhc = rh(k+nh2);
							continue; % go to 100
						else
							if rh(k+nh2) == rhc
								continue; % go to 100
							end
						end
					end
					break; % go to nothing
				end % -------------------- cycle100 end
				npt = k - 1;
				nh2 = nh2 + npt;
				if ibrka(ii) == 0 || itx == 2 || npt < 3
					if itxout == 1 || itxout == 2
						if xs(1) ~= xshoth || f(1) ~= fidh
							ib = 0;
							if iszero ~= 1
								fprintf(fID_17, '%10.3f%10.3f%10.3f%10d\n', xs(1),f(1),0.0,0);
								xsr = xs(1);
							else
								fprintf(fID_17, '%10.3f%10.3f%10.3f%10d\n', 0.0,1.0,0.0,0);
								xsr = 0.0;
							end
							xshoth = xs(1);
							fidh = f(1);
						end
						if itxout == 1
							ib = ib + 1;
						else
							ib = ivraya(ii);
						end
						for jj = 1:npt % 40
							xw = (x(jj)-orig).*xscalt + xmint;
							tw = (t(jj)-orig).*tscale + tadj + abs(xsr-xw).*rvred;
							fprintf(fID_17, '%10.3f%10.3f%10.3f%10d\n', xw,tw,ttunc,ib);
						end % 40
					end
					if npt > 1
						if itx ~= 2
							if itx < 3 && itxbox == 0
								fun_line(x,t,npt);
							else
								if x(1) >= xbmin && x(1) <= xbmax && t(1) >= tbmin && t(1) <= tbmax
									if itx < 3
										fun_plot(x(1),t(1),3);
									end
									iout = 0;
								else
									iout = 1;
								end
								for jj = 2:npt % 42
									ipen = 3;
									if x(jj) >= xbmin && x(jj) <= xbmax && t(jj) >= tbmin && t(jj) <= tbmax
										if iout == 0, ipen = 2; end
										iout = 0;
									else
										iout = 1;
									end
									if itx < 3
										fun_plot(x(jj),t(jj),ipen);
									end
								end % 42
							end
						else
							if itx < 3 && symht > 0.0
								for jj = 1:npt % 41
									if itxbox == 0 || (x(jj) >= xbmin ...
										&& x(jj) <= xbmax && t(jj) >= tbmin ...
										&& t(jj) <= tbmax)
										fun_ssymbl(x(jj),t(jj),symht,4);
									end
								end % 41
							end
						end
					else
						if (itxbox == 0 || (x(1) >= xbmin && x(1) <= xbmax ...
							&& t(1) >= tbmin && t(1) <= tbmax)) ...
							&& symht > 0.0 && itx < 3
							fun_ssymbl(x(1),t(1),symht,4);
						end
					end
				else
					ih = 0;
					if itxout == 1 || itxout == 2
						if xs(1) ~= xshoth || f(1) ~= fidh
							ib = 0;
							if iszero ~= 1
								fprintf(fID_17, '%10.3f%10.3f%10.3f%10d\n', xs(1),f(1),0.0,0);
								xsr = xs(1);
							else
								fprintf(fID_17, '%10.3f%10.3f%10.3f%10d\n', 0.0,1.0,0.0,0);
								xsr = 0.0;
							end
							xshoth = xs(1);
							fidh = f(1);
						end
						if itxout == 1
							ib = ib + 1;
						else
							ib = ivraya(ii);
						end
						xw = (x(1)-orig).*xscalt + xmint;
						tw = (t(1)-orig).*tscale + tadj + abs(xsr-xw).*rvred;
						fprintf(fID_17, '%10.3f%10.3f%10.3f%10d\n', xw,tw,ttunc,ib);
						xw = (x(2)-orig).*xscalt + xmint;
						tw = (t(2)-orig).*tscale + tadj + abs(xsr-xw).*rvred;
						fprintf(fID_17, '%10.3f%10.3f%10.3f%10d\n', xw,tw,ttunc,ib);
					end
					if itxbox == 0
						if itx < 3
							fun_plot(x(1),t(1),3);
							fun_plot(x(2),t(2),2);
						end
					else
						if x(1) >= xbmin && x(1) <= xbmax && t(1) >= tbmin ...
							&& t(1) <= tbmax && x(2) >= xbmin && x(2) <= xbmax ...
							&& t(2) >= tbmin && t(2) <= tbmax
							if itx < 3
								fun_plot(x(1),t(1),3);
								fun_plot(x(2),t(2),2);
							end
							iout = 0;
						else
							if x(2) >= xbmin && x(2) <= xbmax && t(2) >= tbmin && t(2) <= tbmax
								iout = 0;
							else
								iout = 1;
							end
						end
					end
					for jj = 3:npt % 30
						ipen = 3;
						if (x(jj)-x(jj-1)).*(x(jj-1)-x(jj-2)) >= 0 || ih == (jj-1)
							if itxout == 1 || itxout == 2
								xw = (x(jj)-orig).*xscalt + xmint;
								tw = (t(jj)-orig).*tscale + tadj + abs(xsr-xw).*rvred;
								fprintf(fID_17, '%10.3f%10.3f%10.3f%10d\n', xw,tw,ttunc,ib);
							end
							if itxbox == 0 || (x(jj) >= xbmin && x(jj) <= xbmax && t(jj) >= tbmin && t(jj) <= tbmax && iout == 0)
								ipen = 2;
							end
						else
							if itxout == 1
								ib = ib + 1;
							else
								ib = ivraya(ii);
							end
							if itxout == 1 || itxout == 2
								xw = (x(jj)-orig).*xscalt + xmint;
								tw = (t(jj)-orig).*tscale + tadj + abs(xsr-xw).*rvred;
								fprintf(fID_17, '%10.3f%10.3f%10.3f%10d\n', xw,tw,ttunc,ib);
							end
							ih = jj;
						end
						if itx < 3
							fun_plot(x(jj),t(jj),ipen);
						end
						if itxout ~= 0
							if x(jj) >= xbmin && x(jj) <= xbmax && t(jj) >= tbmin && t(jj) <= tbmax
								iout = 0;
							else
								iout = 1;
							end
						end
					end % 30
					if (itxbox == 0 || (x(npt) >= xbmin && x(npt) <= xbmax && t(npt) >= tbmin && t(npt) <= tbmax)) && ih == npt && symht > 0.0 && itx < 3
						fun_ssymbl(x(npt),t(npt),symht,4);
					end
				end
				continue; % go to 1000
				break; % go to nothing
			end % -------------------- cycle1000 end
		end
	end % 10

	t0 = 131.0;
	vrms = 0.95;
	for ii = 1:19 % 101
		xpl = (ii-1) .* 10.0; % float
		tpl = sqrt(t0.^2 + (xpl./vrms).^2);
		% write(0,*) xpl,tpl
		xppl = (xpl-xmint)./xscalt + orig;
		tppl = (tpl-tadj)./tscale + orig;
		if ii == 1
			ipen = 3;
		else
			ipen = 2;
		end
		% call plot(xppl,tppl,ipen)
	end % 101

	if ipflag == 1
		fun_empty();
	end

	return;
end % fun_plttx end