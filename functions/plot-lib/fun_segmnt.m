% pltlib.f
% []
% call:
% called by: fun_pltmod; fun_plttx;

function fun_segmnt(iflag)
% open and close Uniras segments

	global fID_19;
	% common /cplot/ iplot,isep,iseg,nseg,xwndow,ywndow,ibcol,ifcol,sf
	global iplot isep iseg nseg xwndow ywndow ibcol ifcol sf;
	global hFigure1 hFigure2;

	if iflag == 1
		hAxes1 = findall(hFigure1,'type','axes');
		hAxes2 = findall(hFigure2,'type','axes');
		cla(hAxes1,'reset');
		cla(hAxes2,'reset');
	end

	if iplot >= 0
		if iseg == 0, return; end
		% if(nseg.gt.0) call gsegcl(nseg)
		if iflag == 1
			nseg = nseg + 1;
			% call gsegcr(nseg)
		end
	end

	if iplot <= 0
		% 5
		fprintf(fID_19, '%2d\n%10d\n', 8,iflag);
	end

	return;
end % fun_segmnt end
