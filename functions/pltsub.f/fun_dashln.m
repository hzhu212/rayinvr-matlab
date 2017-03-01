% pltsub.f
% []
% call:
% called by: fun_pltmod; fun_plttx;

function fun_dashln(x,y,npts,dash)
% connect the npts (x,y) points with dashed straight line segments
% of length dash

	nmax = 10000;
	% real x(npts),y(npts),xp(nmax),yp(nmax)

	nplt = 1;
	xp(1) = x(1);
	yp(1) = y(1);
	rem_ = 0.0;
	for ii = 1:npts-1 % 10
		if rem_ > 0.0
			dx = x(ii+1) - x(ii);
			dy = y(ii+1) - y(ii);
			distxy = sqrt(dx.^2+dy.^2);
			if distxy < 0.00001, continue; end % go to 10
			fctr = rem_ ./ distxy;
			if fctr <= 1.0
				nplt = nplt + 1;
				if nplt > nmax
					fun_line(x,y,npts); return; % go to 999
				end
				xp(nplt) = x(ii) + dx .* fctr;
				yp(nplt) = y(ii) + dy .* fctr;
			else
				rem_ = rem_ - distxy;
				continue; % go to 10
			end
		end
		dx = x(ii+1) - xp(nplt);
		dy = y(ii+1) - yp(nplt);
		distxy = sqrt(dx.^2+dy.^2);
		fctr = dash ./ distxy;
		nptss = fix(1.0 ./ fctr + 0.00001); % int --> fix
		if nptss > 0
			for jj = 1:nptss % 20
				nplt = nplt + 1;
				if nplt > nmax
					fun_line(x,y,npts); return; % go to 999
				end
				xp(nplt) = xp(nplt-1) + dx .* fctr;
				yp(nplt) = yp(nplt-1) + dy .* fctr;
			end % 20
		end
		if abs(1.0./fctr - nptss) > 0.00001
			rem_ = dash .* (1.0 - 1.0./fctr + nptss);
		else
			rem_ = 0.0;
		end
	end % 10

	ipen = 3;
	for ii = 1:nplt % 30
		fun_plot(xp(ii),yp(ii),ipen);
		if ipen == 3
			ipen = 2;
		else
			ipen = 3;
		end
	end % 30
	fun_plot(x(npts),y(npts),ipen);

	return;
	% 999
	% fun_line(x,y,npts);
end % fun_dashln end