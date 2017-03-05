% pltlib.f
% []
% call:
% called by: fun_axis; fun_plttx;

function fun_symbol(x,y,ht,label,ang,nchar)
% plot the character string label; special symbols can be plotted
% with the routine ssymbol

	global fID_19;
	% common /cplot/ iplot,isep,iseg,nseg,xwndow,ywndow,ibcol,ifcol,sf
	global iplot isep iseg nseg xwndow ywndow ibcol ifcol sf;
	% label = ' ';

	if iplot >= 0
		% call rtxhei(ht)
		% call rtxang(ang)
		% call rtx(nchar,label,x*sf,y*sf)
	end

	if iplot <= 0
		% 5
		fprintf(fID_19, ['%2d\n%10d\n%15.5e%15.5e%15.5e%15.5e\n%',num2str(nchar),'s\n'], 3,nchar,x,y,ht,ang,label(1:nchar));
	end

	return;

end % fun_symbol end