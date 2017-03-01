% pltsub.f
% [~,~,amint,amaxt,ntick,ndeci]
% call:
% called by: fun_pltmod; fun_plttx;

function [amin,amax,amint,amaxt,ntick,ndeci] = fun_axtick(amin,amax,amint,amaxt,ntick,ndeci)
% determine appropriate values for the minimum and maximum position
% of tick marks, the number of tick marks, and the number of
% digits after the decimal given the minimum and maximum axis
% values

	ndiv = 18;
	% [tcndec,tcmax,tcinc] = deal(zeros(1,ndiv));

	tcmax = [.01,.02,.05,.1,.2,.5,1.,2.,5.,10.,20.,50.,100.,200.,500.,1000.,2000.,5000.];
	tcinc = [.001,.002,.005,.01,.02,.05,.1,.2,.5,1.,2.,5.,10.,20.,50.,100.,200.,500.];
	tcndec = [3,3,3,2,2,2,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1];

	alen = amax - amin;
	isGoto20 = false;
	for ii = 1:ndiv % 10
		if alen <= tcmax(ii)
			ipos = ii;
			isGoto20 = true; break; % go to 20
		end
	end % 10
	if ~ isGoto20
		ipos = ndiv;
	end

	% 20
	if ndeci < -1
		ndeci = tcndec(ipos);
	end
	if amint < -999998.0
		amint = round(amin./tcinc(ipos)) .* tcinc(ipos); % float % nint -> round
		if abs(amint-amin) < 0.00001
			amint = amin;
		end
		if amint < amin
			amint = amint + tcinc(ipos);
		end
	end
	if amaxt < -999998.0
		amaxt = round(amax./tcinc(ipos)) .* tcinc(ipos); % float % nint -> round
		if abs(amaxt-amax) < 0.00001
			amaxt = amax;
		end
		if amaxt > amax
			amaxt = amaxt - tcinc(ipos);
		end
	end
	if ntick <= 0
		ntick = round((amaxt-amint)./tcinc(ipos)); % nint -> round
	end
	if abs(amaxt-amint) < 0.001
		amaxt = amax;
		amint = amin;
		ntick = 1;
		ndeci = 0;
	end

	return;
end % fun_axtick end