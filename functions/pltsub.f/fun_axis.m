% pltsub.f
% []
% call: fun_plot; fun_number; fun_symbol;
% called by: fun_pltmod;

function fun_axis(xorig,yorig,amin,amax,amm,ascale,theta,iside,amint,amaxt,ntick,ndeci,label,nchar,albht)
% plot axis
%
% xorig, yorig - (x,y) origin of axis
% amin, amax   - min and max value of axis
% amm          - length of axis (mm)
% ascale       - plot scale in axis-units/plot-units
% theta        - angle of axis in degrees (i.e. 0 or 90)
% iside        - side of axis that is labelled
%                (+1 for left or bottom, -1 for right or top)
% amint, amaxt - min and max value of tick marks
% ntick        - number of intervals separated by tick marks
%                (i.e. the number of tick marks equals ntick+1)
% ndeci        - number of digits after decimal for axis numbers
% label        - axis label
% nchar        - number of characters in axis label
% albht        - height of axis label
%
% Note: amax must be greater than amin always

	[xtick,ytick] = deal(zeros(1,101));
	% label = ' ';

	whrat = 0.75;
	ticfac = 1.0;
	ticlen = ticfac .* abs(albht);

	% plot axis line
	fun_plot(xorig,yorig,3);
	if theta == 0.0
		fun_plot(xorig+amm,yorig,2);
		iplt = 1;
	else
		fun_plot(xorig,yorig+amm,2);
		iplt = 2;
	end

	if ascale > 0.0
		aadj = amin;
		aadjt = amint;
	else
		aadj = amax;
		aadjt = amaxt;
	end

	% plot tick marks

	ainc = (amaxt-amint) ./ (abs(ascale) .* ntick); % float
	if iplt == 1
		xot = (aadjt-aadj) ./ ascale + xorig;
		for ii = 1:ntick+1 % 10
			xtick(ii) = xot + ii - 1.*ainc;
			ypos = yorig;
			fun_plot(xtick(ii),ypos,3);
			ypos = yorig - iside .* ticlen;
			fun_plot(xtick(ii),ypos,2);
		end % 10
	else
		yot = (aadjt-aadj) ./ ascale + yorig;
		for ii = 1:ntick+1 % 20
			ytick(ii) = yot + ii - 1.*ainc;
			xpos = xorig;
			fun_plot(xpos,ytick(ii),3);
			xpos = xorig - iside .* ticlen;
			fun_plot(xpos,ytick(ii),2);
		end % 20
	end

	% plot axis scale

	if albht < 0.0, return; end
	if amaxt ~= 0.0
		maxdig = fix(alog10(abs(amaxt))) + ndeci + 2; % int -> fix
	else
		maxdig = 1;
	end
	anlen = maxdig .* albht .* whrat;
	if ascale > 0.0
		ainc = (amaxt-amint) ./ ntick;
		a1 = amint;
	else
		ainc = (amint-amaxt) ./ ntick;
		a1 = amaxt;
	end
	if iplt == 1
		if iside == 1
			shfctr = 1.5;
		else
			shfctr = 0.5;
		end
		ypos = ypos - iside .* albht .* shfctr;
		xadj = anlen ./ 2.0;
		for ii = 1:ntick+1 % 30
			value = a1 + (ii-1).*ainc;
			xpos = xtick(ii) - xadj;
			fun_number(xpos,ypos,albht,value,0.0,ndeci);
		end % 30
	else
		if iside == 1
			shfctr = 0.5;
		else
			shfctr = 1.5;
		end
		xpos = xpos - iside.*albht.*shfctr;
		yadj = anlen ./ 2.0;
		for ii = 1:ntick+1 % 40
			value = a1 + (ii-1) .* ainc;
			ypos = ytick(ii) - yadj;
			fun_number(xpos,ypos,albht,value,90.0,ndeci);
		end % 40
	end

	% plot axis label

	alblen=float(nchar)*albht*whrat
	if iplt == 1
		ypos = ypos - iside.*albht.*1.5;
		xpos = xorig + (amm-alblen)./2.0;
		fun_symbol(xpos,ypos,albht,label,0.,nchar);
	else
		xpos = xpos - iside.*albht.*1.5;
		ypos = yorig + (amm-alblen)./2.0;
		fun_symbol(xpos,ypos,albht,label,90.,nchar);
	end

	return;
end % fun_axis end