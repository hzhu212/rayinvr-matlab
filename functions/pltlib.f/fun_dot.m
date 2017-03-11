% pltlib.f
% []
% call:
% called by: fun_plttx; fun_pltdat;

function fun_dot(x,y,size_,icol)
% plot a dot centred at (x,y) of size isize pixels or mm and colour
% icol

	global fID_19;
	% common /cplot/ iplot,isep,iseg,nseg,xwndow,ywndow,ibcol,ifcol,sf
	global iplot isep iseg nseg xwndow ywndow ibcol ifcol sf;

	if iplot >= 0
		% call gwicol(size,icol)
		% call gdot(sf*x,sf*y,1)
		% call gwicol(-1.,1)
		% call gwicol(.001,ifcol)
	end

	if iplot <= 0
		% 5
		fprintf(fID_19, '%2d\n%15.5e%15.5e%15.5e%10d\n', 10,x,y,size_,icol);
	end

	return;
end % fun_dot end