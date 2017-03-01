% pltsub.f
% []
% call:
% called by:

function fun_ssymbl(x,y,ht,isymbl)
% plot special symbols centred at (x,y) of height ht

	ht2 = ht ./ 2.0;

	% go to (100,200,300,400,500) isymbl

	% plot a "+"

	% 100
	if isymbl == 1
		fun_plot(x,y-ht2,3);
		fun_plot(x,y+ht2,2);
		fun_plot(x-ht2,y,3);
		fun_plot(x+ht2,y,2);
		return;
	end

	% plot a "x"

	% 200
	if isymbl == 2
		fun_plot(x-ht2,y-ht2,3);
		fun_plot(x+ht2,y+ht2,2);
		fun_plot(x-ht2,y+ht2,3);
		fun_plot(x+ht2,y-ht2,2);
		return;
	end

	% plot a "*"

	% 300
	if isymbl == 3
		fun_plot(x,y-ht2,3);
		fun_plot(x,y+ht2,2);
		fun_plot(x-ht2,y,3);
		fun_plot(x+ht2,y,2);
		fun_plot(x-ht2,y-ht2,3);
		fun_plot(x+ht2,y+ht2,2);
		fun_plot(x-ht2,y+ht2,3);
		fun_plot(x+ht2,y-ht2,2);
		return;
	end

	% plot a square

	% 400
	if isymbl == 4
		fun_plot(x-ht2,y-ht2,3);
		fun_plot(x+ht2,y-ht2,2);
		fun_plot(x+ht2,y+ht2,2);
		fun_plot(x-ht2,y+ht2,2);
		fun_plot(x-ht2,y-ht2,2);
		return;
	end

	% plot a diamond

	% 500
	if isymbl == 5
		fun_plot(x,y-ht2,3);
		fun_plot(x+ht2,y,2);
		fun_plot(x,y+ht2,2);
		fun_plot(x-ht2,y,2);
		fun_plot(x,y-ht2,2);
		return;
	end

	return;
end % fun_ssymbl end