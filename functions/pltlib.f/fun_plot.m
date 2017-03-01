% pltlib.f
% []
% call:
% called by: fun_axis; fun_box; fun_plttx;

function fun_plot(x,y,ipen)
% move to the point (x,y); pen up if ipen=3, pen down if ipen=2

	global fID_19;
	% common /cplot/ iplot,isep,iseg,nseg,xwndow,ywndow,ibcol,ifcol,sf
	global iplot isep iseg nseg xwndow ywndow ibcol ifcol sf;

	% if(iplot.ge.0) call gvect(x*sf,y*sf,3-ipen)

	if iplot <= 0
		% 5
		fprintf(fID_19, '%2d\n%15.5e%15.5e%10d\n', 1,x,y,ipen);
	end

	return;
end % fun_plot end