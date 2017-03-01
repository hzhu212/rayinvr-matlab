% pltlib.f
% []
% call:
% called by: fun_pltmod;

function fun_erase()
% erase the screen

	global fID_19;
	% common /cplot/ iplot,isep,iseg,nseg,xwndow,ywndow,ibcol,ifcol,sf
	global iplot isep iseg nseg xwndow ywndow ibcol ifcol sf;

	if iplot >= 0
		if ibcol ~= 0
			% call rrect(0.,0.,xwndow,ywndow,ibcol,0.)
		else
			% call gclear
		end
	end

	if iplot <= 0
		% 5
		fprintf(fID_19, '%2d\n', -2);
	end

	return;
end % fun_erase end
