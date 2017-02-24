% inv.f
% [~,~,~,~,~,iflagw,~,~]
% called by: main;
% call: none.

function [xshotr,ig,iray,idr,ximax,iflagw,iszero,x2pt] = fun_calprt(xshotr,ig,iray,idr,ximax,iflagw,iszero,x2pt)
% calculate the partial derivatives at the location of the travel
% time picks by interpolating across the end points of a single
% ray family

	global file_rayinvr_par file_rayinvr_com;
	global fID_11;
	run(file_rayinvr_par);
	run(file_rayinvr_com);

	npick = 0;
	iflagw = 0;
	nsfc = 1;
	isf = ilshot(nsfc);

	% 100 % -------------------- cycle100 begin
	cycle100 = true;
	while cycle100
		xf = xpf(isf);
		tf = tpf(isf);
		uf = upf(isf);
		irayf = ipf(isf);

		if irayf < 0, return; end % go to 999
		if irayf == 0
			xshotf = xf;
			idf = 1.0 .* sign(tf);
			if abs(xshotr-xshotf) < 0.001 & idr == idf
				iflag = 1;
				npick = isf - nsfc;
				isf = isf + 1;
			else
				iflag = 0;
				nsfc = nsfc + 1;
				isf = ilshot(nsfc);
			end
		else
			npick = npick + 1;
			if iflag == 1 & iray == irayf
				if iszero == 0
					xpick = xf;
				else
					xpick = abs(xshotr-xf);
				end
				tpick = tf;
				upick = uf;
				tvmin = 99999.0;
				if ninv > 1
					for ii = 1:ninv-1 % 10
						x1 = xfinv(ii) - x2pt;
						x2 = xfinv(ii+1) + x2pt;
						x3 = xfinv(ii) + x2pt;
						x4 = xfinv(ii+1) - x2pt;
						if (xpick>=x1 & xpick<=x2) | (xpick<=x3 & xpick>=x4)
							if ximax > 0.0 & min(abs(xfinv(ii)-xpick),abs(xfinv(ii+1)-xpick)) > ximax
								if iflagw == 0
									% 15
									fprintf(fID_11, '***  attempt to interpolate over ximax  ***\n');
								end
								iflagw = 1;
								continue; % go to 10
							end
							denom = xfinv(ii+1) - xfinv(ii);
							if denom ~= 0.0
								tintr = (xpick-xfinv(ii)) ./ denom .* (tfinv(ii+1)-tfinv(ii)) + tfinv(ii);
							else
								tintr = (tfinv(ii+1) + tfinv(ii)) ./ 2.0;
							end
							if tintr < tvmin
								ifpos = ii;
								tvmin = tintr;
							end
						end
					end % 10
				else
					x1 = xfinv(1) - x2pt;
					x2 = xfinv(1) + x2pt;
					if xpick >= x1 & xpick <= x2
						isGoto1010 = false;
						if ximax > 0.0 & abs(xfinv(1)-xpick) > ximax
							if iflagw == 0
								% 15
								fprintf(fID_11, '***  attempt to interpolate over ximax  ***\n');
							end
							iflagw = 1;
							isGoto1010 = true; % go to 1010
						end
						if ~isGoto1010
							tintr = tfinv(1);
							if tintr < tvmin
								ifpos = ii;
								tvmin = tintr;
							end
						end
					end
				end

				% 1010
				if tvmin > 9999.0
					% go to 110
					isf = isf + 1;
					continue; % go to 100
				end
				iapos = 0;
				if narinv > 0
					for ii = 1:narinv % 20
						if ipinv(ii) == npick
							iapos = ii;
							break; % go to 30
						end
					end % 20
				end
				% 30
				if iapos == 0
					narinv = narinv + 1;
					iapos = narinv;
				else
					if tcalc(iapos) <= tvmin
						% go to 110
						isf = isf + 1;
						continue; % go to 100
					end
				end
				ipinv(iapos) = npick;
				tobs(iapos) = tpick;
				uobs(iapos) = upick;
				tcalc(iapos) = tvmin;
				xcalc(iapos) = xpick;
				xscalc(iapos) = xshotr;
				icalc(iapos) = idr .* iray;
				ircalc(iapos) = ig;
				dx = xfinv(ifpos+1) - xfinv(ifpos);
				if dx ~= 0.0
					c1 = abs((xpick-xfinv(ifpos)) ./ dx);
					c2 = abs((xpick-xfinv(ifpos+1)) ./ dx);
				else
					c1 = 0.5;
					c2 = 0.5;
				end
				for ii = 1:nvar % 40
					if fpart(ifpos,ii) ~= 0.0 & fpart(ifpos+1,ii) ~= 0.0
						apart(iapos,ii) = c1.*fpart(ifpos,ii) + c2.*fpart(ifpos+1,ii);
					else
						apart(iapos,ii) = 0.0;
					end
				end % 40
			end
			% 110
			isf = isf + 1;
		end
		continue; % go to 100
		break; % go to nothing
	end % -------------------- cycle100 end

	% 999
	return;

end % fun_calprt end