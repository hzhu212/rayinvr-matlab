% pltlib.f
% []
% call:
% called by: fun_pltmod;

function fun_line(x,y,npts)
% connect the (x,y) points with straight line segments

	global fID_19;
	% common /cplot/ iplot,isep,iseg,nseg,xwndow,ywndow,ibcol,ifcol,sf
	global iplot isep iseg nseg xwndow ywndow ibcol ifcol sf;
	% real x(npts),y(npts)

	% if iplot >= 0
	% 	for ii = 1:npts % 10
	% 		x(ii) = x(ii) .* sf;
	% 		y(ii) = y(ii) .* sf;
	% 	end % 10

	% 	% call gvect(x,y,npts)

	% 	for ii = 1:npts % 20
	% 		x(ii) = x(ii) ./ sf;
	% 		y(ii) = y(ii) ./ sf;
	% 	end % 20
	% end

	if iplot <= 0
		% 5
		fprintf(fID_19, '%2d\n%10d\n', 9,npts);
		% 15
		fprintf(fID_19, '%15.5e%15.5e\n', [x(1:npts);y(1:npts)]);
	end

	return;
end % fun_line end