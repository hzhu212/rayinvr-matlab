% pltlib.f
% []
% call:
% called by: fun_pltmod; fun_plttx;

function fun_pcolor(icol)
% set the colour for polylines

	global fID_19;
	% common /cplot/ iplot,isep,iseg,nseg,xwndow,ywndow,ibcol,ifcol,sf
	global iplot isep iseg nseg xwndow ywndow ibcol ifcol sf;

	% if(iplot.ge.0) call gwicol(-1.,icol)
	% if(iplot.ge.0) call gwicol(.001,icol)

	if iplot <= 0
		% 5
		fprintf(fID_19, '%2d\n%10d\n', 7,icol);
	end

	return;
end % fun_pcolor end