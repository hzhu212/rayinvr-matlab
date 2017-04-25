% pltlib.f
% []
% call:
% called by: main; fun_pltmod; fun_plttx;

function fun_empty()
% flush the graphics buffer

	global fID_19;
	% common /cplot/ iplot,isep,iseg,nseg,xwndow,ywndow,ibcol,ifcol,sf
	global iplot isep iseg nseg xwndow ywndow ibcol ifcol sf;

	% if(iplot.ge.0) call gempty

	if iplot <= 0
		% 5
		fprintf(fID_19, '%2d\n', 4);
	end

	return;
end % fun_empty end