% pltlib.f
% [x,y,~]
% call:
% called by: fun_pltmod;

function [x,y,iroute] = fun_plots(x,y,iroute)
% initialize the plot; this must be the first plot call
% iroute = 1 plots to the screen
%          2 creates a postscript file
%          3 creates a uniras file for the VERSATEC plotter
%          4 creates a postscript file for the colour plotter
%          5 creates a legal size postscript file
%          6 creates an A3 postscript file

	global fID_19;
	% common /cplot/ iplot,isep,iseg,nseg,xwndow,ywndow,ibcol,ifcol,sf
	global iplot isep iseg nseg xwndow ywndow ibcol ifcol sf;

	proute = ' ';
	x = x .* sf;
	y = y .* sf;

	if iplot >= 0
		if iroute < 2 || iroute > 7
			if x <= 0 || y <= 0.0
				proute = 'select mx11;exit';
			else
				if x > 350.0, x = 350.0; end
				if y > 265.0, y = 265.0; end
				ix = round(x); % nint -> round
				iy = round(y); % nint -> round
				ixd1 = ix ./ 100;
				ixd2 = (ix-ixd1.*100) ./ 10;
				ixd3 = ix - ixd1.*100 - ixd2.*10;
				iyd1 = iy ./ 100;
				iyd2 = (iy-iyd1.*100) ./ 10;
				iyd3 = iy - iyd1.*100 - iyd2.*10;
				proute = 'select mx11;area    ,   ;exit';
				proute(18:20) = char([ixd1,ixd2,ixd3]+48);
				proute(22:24) = char([iyd1,iyd2,iyd3]+48);
			end
		else
			if iroute == 2, proute = 'select mpost;exit'; end
			if iroute == 3, proute = 'select gv7236;exit'; end
			if iroute == 4, proute = 'select hcposta;exit'; end
			if iroute == 5, proute = 'select hpostl;exit'; end
			if iroute == 6, proute = 'select hposta3;exit'; end
			if iroute == 7, proute = 'select hposta4;exit'; end
		end

		% call groute(proute)
		% call gshmes('SUP','SUP')
		% call gopen

		if ibcol ~= 0
			% call grpsiz(xwndow,ywndow)
			% call rrect(0.,0.,xwndow,ywndow,ibcol,0.)
		end
		if ifcol ~= 1
			% call gwicol(-1.,ifcol)
			% call gwicol(.001,ifcol)
			% call rtxcol(ifcol,ifcol)
		end
	end

	if iplot <= 0
		% 5
		fprintf(fID_19, '%2d\n%10d%10d\n', -1,ibcol,ifcol);
	end

	return;
end % fun_plots end