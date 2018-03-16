% plt.f
% []
% call:
% called by: main;

function fun_my_plttx(ifam,npts,iszero,idata,iaxlab,xshot,idr,nshot,itxout,ibrka,ivraya,ttunc,itrev,xshotr,fidrr,itxbox,iroute,iline)
% plot the travel time curves for all rays reaching the surface -
% for each group of rays a separate curve is drawn for each
% ray code

	global fID_17;
	global albht colour fidarr icalc ifcol iplots ircalc isep itcol ititle itx ...
		narinv ncol ndecit ndecxt ntckxt ntickt orig pnrayf range_ ray rayid ...
		s symht tcalc time title_ tmax tmin tmm tobs tscale tt ttmax ttmin ...
		uobs vred xcalc xmaxt xmint xmmt xscalc xscalt xshtar xtitle xtmaxt ...
		xtmint xwndow ytitle ywndow;
	global currentColor matlabColors hFigure2;

	if itx > 0 || idata ~= 0
		ipflag = 1;
	else
		ipflag = 0;
	end
	% xcshot = -999999.0;
	% fc = 0.0;
	% dashtl = tmm ./ 100.0;
	% if vred ~= 0.0
	% 	rvred = 1.0 ./ vred;
	% else
	% 	rvred = 0.0;
	% end

	if isempty(hFigure2)
		% 创建一个新的 figure 对象
		hFigure2 = figure('NumberTitle','off','Name',['Travel Time - ',sprintf('%.2f',xshotr)],'Position',[220,100,900,500]);
		% 创建 axes 对象
		axes('FontName','Consolas','position',[0.06,0.1,0.9,0.8]);
    else
    	% set(hFigure2, 'Name', [get(hFigure2, 'Name'), ' - ', sprintf('%.2f',xshotr)]);
    	figure(hFigure2);
	end

	hold on;

	% t 轴标题
	if iaxlab == 1
		tlab = 'Time (s)';
		if vred ~= 0
			tlab = sprintf('Time-Distance/%4.2f (s)', vred);
		end
	end

	% 反转t轴，使之朝下
	if itrev ~= 1
		tadj = tmin;
	else
		tadj = tmax;
		set(gca(),'YDir','reverse');
	end

	% xshoth = -99999.0;
	% fidh = 0.0;
	iflag1 = 0;
	n = 0;
	% ib = 0;
	xbmin = orig;
	xbmax = orig + xmmt;
	tbmin = orig;
	tbmax = orig + tmm;

	for ii = 1:ifam % 10
		nh1 = n;
		if npts(ii) > 0
			tempIndex = (1:npts(ii)) + nh1;
			xh = range_(tempIndex);
			th = tt(tempIndex);
			rh = rayid(tempIndex);
			xsh = xshtar(tempIndex);
			fh = fidarr(tempIndex);
			n = n + npts(ii);
			if isep == 2 && (abs(xsh(1)-xshotr) > 0.001 || fh(1) ~= fidrr)
				continue; % go to 10
			end
			if iflag1 == 0
				iflaga = 1;
			else
				if xsh(1) ~= xshota && isep > 1
					iflaga = 1;
				else
					iflaga = 0;
				end
			end
			xshota = xsh(1);
			ida = round(fh(1));

			if iflaga == 1
				if ipflag ~= 0
					if (isep < 2 || isep == 3) && iflag1 ~= 0
						fun_empty();
						fun_aldone();
					end
					if (isep < 2 || isep == 3) && (iflag1 ~= 0 || isep == 1 || isep == 3)
						fun_erase();
						ititle = 0;
					end

					% 绘制坐标轴
					if iaxlab == 1
						xlabel('Distance (km)','FontName','Consolas','FontSize',11);
						ylabel(tlab,'FontName','Consolas','FontSize',11);
					end

					% 显示图像区域边框
					box on;

					% 绘制图像标题
					if ititle == 0 && ~isempty(strtrim(title_))
						title(title_);
						ititle = 1;
					end

					% 垂直t轴每刻度(s)绘制一根虚线作为参考线
					if itx == 4
						ntlmax = fix(tmax - 0.001);
						x = [xmint, xmaxt];
						for jj = 1:ntlmax % 310
							tp = jj - tadj;
							t = [tp, tp];
							plot(x,t,'--','Color',currentColor);
						end % 310
					end

					% plot observed travel times
					if idata ~= 0
						fun_my_pltdat(iszero,idata,xshot,idr,nshot,tadj,xshota,xbmin,xbmax,tbmin,tbmax,itxbox,ida);
					end
				end

				% 1010
				if (itx >= 3 || itxout == 3) && narinv > 0
					% ichold = -999999;
					index = 1:narinv;
					if isep == 2
						index = find(abs(xscalc(1:narinv)-xshota) < 0.001 & icalc(1:narinv).*fh(1) > 0.0);
					end
					if isep == 3
						index = find(abs(xscalc(1:narinv)-xshota) < 0.001);
					end

					if itx >= 3
						% xplot = xcalc(index) - xmint;
						xplot = xcalc(index);
						if itx == 3
							% tplot = tcalc(index) - tadj;
							tplot = tcalc(index);
						else
							% tplot = tcalc(index) - tobs(index) + abs(icalc(index)) - tadj;
							tplot = tcalc(index) - tobs(index) + abs(icalc(index));
						end
						rayCode = ircalc(index);

						% 如果 itxbox~=0, 则投到绘图区域之外的点不画
						if itxbox ~= 0
							filtIndex = find(xplot >= xbmin & xplot <= xbmax & tplot >= tbmin & tplot <= tbmax);
							xplot = xplot(filtIndex);
							tplot = tplot(filtIndex);
							rayCode = rayCode(filtIndex);
						end

						codeChange = find(rayCode(1:end-1) ~= rayCode(2:end));
						codeChange = [0, codeChange, length(rayCode)];

						% 设置绘图样式
						lineStyle = '-';
						lineSymbol = '';
						if iline == 0
							lineStyle = '';
							lineSymbol = 's';
						end
						markerSize = symht .* 5;

						% itcol = 3;
						for k = 1:length(codeChange)-1
							% aaa = input('input: ');
							codeBegin = codeChange(k) + 1;
							codeEnd = codeChange(k+1);
						    codeIndex = codeBegin:codeEnd;
						    thisCode = rayCode(codeBegin);
						    if itcol == 3
						        ipcol = colour(mod(thisCode-1,ncol)+1);
						        currentColor = matlabColors{ipcol};
						    end
							plot(xplot(codeIndex),tplot(codeIndex),[lineStyle,lineSymbol],'Color',currentColor,'MarkerSize',markerSize);
						end
					end

					% 输出到 tx.out 跳过

					if itx >= 3 && itcol == 3
						currentColor = matlabColors{ifcol};
					end
				end
			end

			iflag1 = 1;

			if itx ~= 1 && itx ~= 2 && itxout ~= 1 && itxout ~= 2
				continue; % go to 10
			end

			nh2 = 0;
			% 1000 % -------------------- cycle1000 begin
			while nh2 < npts(ii)
				k = 0;
				% 100 % -------------------- cycle100 begin
				cycle100 = true;
				while cycle100
					k = k + 1;
					if (k+nh2) <= npts(ii)
						% x(k) = xh(k+nh2) - xmint;
						% t(k) = th(k+nh2) - tadj;
						x(k) = xh(k+nh2);
						t(k) = th(k+nh2);
						xs(k) = xsh(k+nh2);
						f(k) = fh(k+nh2);
						if k == 1
							rhc = rh(k+nh2);
							continue; % go to 100
						else
							if rh(k+nh2) == rhc
								continue; % go to 100
							end
						end
					end
					break; % go to nothing
				end % -------------------- cycle100 end
				npt = k - 1;
				nh2 = nh2 + npt;

				% itx<3 才绘制
				if itx < 3
					lineStyle = '-';
					lineSymbol = '';
					markerSize = symht .* 5;
					% 如果线只包括一个点，则线无法显示，只能绘制点标记
					if itx == 1 && npt == 1
					    lineSymbol = 's';
					end
					% 若 itx=2，则不绘制实线，并在节点处绘制小方块
					if itx == 2
						lineStyle = '';
						lineSymbol = 's';
					end
					% 默认所有点均绘制
					index = 1:npt;
					% 如果限定了 itxbox，则落在坐标框外的不绘制
					if itxbox ~= 0
						index = find(x(index)>=xbmin & x(index)<=xbmax & t(index)>=tbmin & t(index)<=tbmax);
					end
					plot(x(index),t(index),[lineStyle,lineSymbol],'Color',currentColor,'MarkerSize',markerSize);
				end
			end % -------------------- cycle1000 end
		end
	end % 10

	hold off;

	return;
end % fun_my_plttx end
