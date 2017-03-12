% plt.f
% []
% call: fun_pcolor; fun_plot; fun_dot;
% called by: fun_plttx;

function fun_pltdat(iszero,idata,xshot,idr,nshot,tadj,xshota,xbmin,xbmax,tbmin,tbmax,itxbox,ida)
% plot observed travel times

	% include 'rayinvr.par'
	% real xshot(1)
	% integer idr(1)
	% include 'rayinvr.com'

	global colour ifcol ilshot ipf ipinv isep itcol itx narinv ncol orig symht ...
		tpf tscale upf xmint xpf xscalt;
	global imod iray;

	% npick: 当前处理到 tx.in 中的第几条射线
	% nsfc: 当前处理到第 tx.in 中的第几个炮点
	% ilshot: i-line-shot. tx.in 中所有炮点位于的行编号
	% isf: 当前处理到 tx.in 中的第几行
	npick = 0;
	nsfc = 1;
	isf = ilshot(nsfc);

	% 100 % -------------------- cycle 100 begin
	cycle100 = true;
	while cycle100
		% xpf tpf upf ipf 分别为 tx.in 中的第 1、2、3、4 列
		xp = xpf(isf);
		tp = tpf(isf);
		up = upf(isf);
		ip = ipf(isf);

		% ip < 0 说明到达 tx.in 的结尾
		if ip < 0, break; end % go to 999

		% ip = 0 说明到达一个新的炮点
		if ip == 0
		    xsp = xp;
		    idp = 1.0 .* sign(tp);
		    isGoto100 = false;
		    for ii = 1:nshot % 10
		        xdiff = abs(xshot(ii) - xshota);
		        if (xdiff < 0.001 && ida == idr(ii) && (imod > 0 || iray > 0)) || (xdiff < 0.001 && imod.*iray == 0) || isep < 2
		            xdiff = abs(xshot(ii) - xsp);
		            if xdiff < 0.001 && idr(ii) == idp
		                iplt = 1;
		                npick = isf - nsfc;
		                isf = isf + 1;
		                nsfc = nsfc + 1;
		                icshot = ii;
		                isGoto100 = true; break; % go to 100 --step1
		            end
		        end
		    end % 10
		    if isGoto100, continue; end % go to 100 --step2
		    iplt = 0;
		    nsfc = nsfc + 1;
		    isf = ilshot(nsfc);
		    continue; % go to 100

		% 否则，说明是一个接收点
		else
			% abs(data) = 2 时，只绘制反演过的走时，未反演的跳过
			if abs(idata) == 2
			    npick = npick + 1;
			    iflag = 0;
			    for ii = 1:narinv % 20
			        if ipinv(ii) == npick
			            iflag = 1;
			            break; % go to 30
			        end
			    end % 20
			else
				iflag = 1;
			end

			% 30
			if iplt == 1 && iflag == 1
			    if iszero == 0
			        xplot = (xp - xmint) ./ xscalt + orig;
			    else
			    	xplot = ((xp-xsp).*idp - xmint) ./ xscalt + orig; % float
			    end
			    if itx ~= 4
			        tplot = (tp-tadj) ./ tscale + orig;
			    else
			    	tplot = (abs(ip)-tadj) ./ tscale + orig; % float
			    end
			    if itcol == 1 || itcol == 2
			        if itcol ~= 2
			            ipcol = colour(mod(ip-1,ncol)+1);
			        else
			        	ipcol = colour(mod(icshot-1,ncol)+1);
			        end
			        fun_pcolor(ipcol);
			    end
			    if itxbox == 0 || (xplot >= xbmin && xplot <= xbmax && tplot >= tbmin && tplot <= tbmax)
			        if idata > 0
			            fun_plot(xplot,tplot-up./tscale,3);
			            fun_plot(xplot,tplot+up./tscale,2);
			        else
			        	% call ssymbl(xplot,tplot,symht,1)
			        	fun_dot(xplot,tplot,symht,ifcol);
			        end
			    end
			end
		end
		isf = isf + 1;
		continue; % go to 100
		break; % go to nothing
	end % -------------------- cycle 100 end

	% 999
	if itcol ~= 0
	    fun_pcolor(ifcol);
	end
	return;
end % fun_pltdat end