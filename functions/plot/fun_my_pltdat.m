% plt.f
% []
% call: none.
% called by: none.

function fun_my_pltdat(iszero,idata,xshot,idr,nshot,tadj,xshota,xbmin,xbmax,tbmin,tbmax,itxbox,ida)
% plot observed travel times

	global colour ifcol ilshot ipf ipinv isep itcol itx narinv ncol orig symht ...
		tpf tscale upf xmint xpf xscalt;
	global hFigure2 currentColor matlabColors;

	% 源程序中未声明以下2个变量，因为其不在 rayinvr.par 和 rayinvr.com 中
	global imod iray;

	% 将 figure2(走时图像)设为当前图像
	figure(hFigure2);
	% set(hFigure2,'CurrentAxes',gca());

	for ii = 1:nshot
		thisShot = ilshot(ii);
		nextShot = ilshot(ii+1);

		xThisShot = xpf(thisShot);
		dThisShot = sign(tpf(thisShot));

		% 要绘制的射线所在的行号
		index = thisShot+1:nextShot-1;

		% abs(data) = 2 时，只绘制反演过的射线，未反演的跳过
		if abs(idata) == 2
			% 射线编号，即射线所在行号减去当前炮点编号(因为每个炮点信息占一行)
			rayNumbers = index - ii;
			% 取交集，找到反演过的射线编号
			inversedRay = intersect(rayNumbers,ipinv(1:narinv));
			index = inversedRay + ii;
		end

		codeChange = find(ipf(index(1:end-1)) ~= ipf(index(2:end)));
		codeChange = [0; codeChange; length(index)];
		for jj = 1:length(codeChange)-1
			codeBegin = codeChange(jj) + 1;
			codeEnd = codeChange(jj+1);
			indexThisCode = index(codeBegin:codeEnd);

			xp = xpf(indexThisCode);
			tp = tpf(indexThisCode);
			up = upf(indexThisCode);
			ip = ipf(indexThisCode);
			% rayCode = ip(1);

			if iszero == 0
				% xplot = xp - xmint;
				xplot = xp;
			else
				% xplot = (xp - xThisShot) .* dThisShot - xmint;
				xplot = (xp - xThisShot) .* dThisShot;
			end
			if itx ~= 4
				% tplot = tp - tadj;
				tplot = tp;
			else
				% tplot = abs(ip) - tadj;
				tplot = abs(ip);
			end

			if itcol == 1 || itcol == 2
				if itcol == 1
					ipcol = colour(mod(ip(1)-1,ncol)+1);
				else
					ipcol = colour(mod(ii-1,ncol)+1);
				end
				currentColor = matlabColors(ipcol);
			end

			if itxbox ~= 0
				filtIndex = find(xplot >= xbmin & xplot <= xbmax & tplot >= tbmin & tplot <= tbmax);
				xplot = xplot(filtIndex);
				tplot = tplot(filtIndex);
				up = up(filtIndex);
			end

			lineStyle = '';
			lineSymbol = 's';
			markerSize = symht .* 5;

			if idata > 0
				try
					hErrorbar = my_errorbar(xplot,tplot,2.*up,[lineStyle,currentColor,lineSymbol]);
				catch e
					hErrorbar = errorbar(xplot,tplot,2.*up,[lineStyle,currentColor,lineSymbol]);
				end
				set(hErrorbar,'MarkerSize',markerSize);
			else
				plot(xplot,tplot,[lineStyle,currentColor,lineSymbol],'MarkerSize',markerSize);
			end
		end
	end

	% 999
	if itcol ~= 0
		currentColor = matlabColors(ifcol);
	end
	return;

end % fun_my_pltdat end
