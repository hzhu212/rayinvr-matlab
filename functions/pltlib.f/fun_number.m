% pltlib.f
% []
% call:
% called by: fun_pltmod; fun_axis;

function fun_number(x,y,ht,xnum,ang,ndeci)
% plot the floating point number

	global fID_19;
	% common /cplot/ iplot,isep,iseg,nseg,xwndow,ywndow,ibcol,ifcol,sf
	global iplot isep iseg nseg xwndow ywndow ibcol ifcol sf;

	if iplot >= 0
		% call rtxhei(ht)
		% call rtxang(ang)
		% call rtxn(xnum,ndeci,x*sf,y*sf)
	end

	if iplot <= 0
		% 5
		fprintf(fID_19, '%2d\n%15.5e%15.5e%15.5e%15.5e%15.5e%10d\n', 2,x,y,ht,xnum,ang,ndeci);
	end

	return;

end % fun_number end