% pltlib.f
% []
% call: fun_segmnt;
% called by:

function fun_plotnd()
% terminate all Uniras plotting

	global fID_19;
	% common /cplot/ iplot,isep,iseg,nseg,xwndow,ywndow,ibcol,ifcol,sf
	global iplot isep iseg nseg xwndow ywndow ibcol ifcol sf;

	if iplot >= 0
		fun_segmnt(0);
		% call gclose
	end

	if iplot <= 0
		% 5
		fprintf(fID_19, '%2d\n', 6);
	end

	return;
end % fun_plotnd end