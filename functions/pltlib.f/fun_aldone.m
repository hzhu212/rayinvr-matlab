% pltlib.f
% []
% call:
% called by:

function fun_aldone()
% wait unitl the user is ready for the next plot

	global fID_19;
	% common /cplot/ iplot,isep,iseg,nseg,xwndow,ywndow,ibcol,ifcol,sf
	global iplot isep iseg nseg xwndow ywndow ibcol ifcol sf;
	reply = ' ';

	if iplot >= 0
		% 15 % 25
		reply = input('\nEnter <CR> to continue\n','s');
		if reply(1) == 's'
		    fun_plotnd();
		    error('e:stop','stop in fun_aldone.'); % stop
		end
		if any(reply(1) == '0123')
		    iseg = str2num(reply(1));
		end
		fun_segmnt(1);
	end

	if iplot <= 0
		% 5
		fprintf(fID_19, '%2d\n', 5);
	end

	return;
end % fun_aldone end