% plt.f
% []
% call: fun_plots; fun_segmnt; fun_erase; fun_box; fun_pcolor; fun_line; fun_number; fun_empty;
% called by: main;

function fun_pltmod(ncont,ibnd,imod,iaxlab,ivel,velht,idash,ifrbnd,idata,iroute,i33)
% plot the velocity model

	% include 'rayinvr.par'
	% real xcp(pnsmth),zcp(pnsmth)
	% include 'rayinvr.com'

	global fID_33;
	global albht b cosmth ibsmth ifcol iplots isep ititle itx ivg mcol nblk ...
		ndecix ndeciz nfrefl nlayer npbnd npfref ntickx ntickz nzed orig s ...
		sep title_ tmm vm vsvp xbnd xfrefl xm xmax xmin xmm xscale xsinc ...
		xtitle xtmax xtmin xwndow ytitle ywndow zfrefl zm zmax zmin zmm zscale ...
		ztmax ztmin;

	% 初始化绘图
	if iplots == 0
		if (isep==0 || isep==2) && (itx>0 || idata~=0)
			sep = sep + orig + tmm;
		end
		[xwndow,ywndow,~] = fun_plots(xwndow,ywndow,iroute);
		fun_segmnt(1);
		iplots = 1;
	end
	fun_erase();
	ititle = 0;

	% 绘制坐标轴
	if iaxlab == 1
		[~,~,xtmin,xtmax,ntickx,ndecix] = fun_axtick(xmin,xmax,xtmin,xtmax,ntickx,ndecix);
		[~,~,ztmin,ztmax,ntickz,ndeciz] = fun_axtick(zmin,zmax,ztmin,ztmax,ntickz,ndeciz);
		fun_axis(orig,sep+zmm,xmin,xmax,xmm,xscale,0.0,-1,xtmin,xtmax,ntickx,ndecix,'DISTANCE (km)',13,albht);
		fun_axis(orig,sep,zmin,zmax,zmm,zscale,90.0,1,ztmin,ztmax,ntickz,ndeciz,'DEPTH (km)',10,albht);
	end

	% 绘制图像边框
	fun_box(orig,sep,orig+xmm,sep+zmm);

	% 绘制坐标轴标题
	if ititle == 0 & title_ ~= ' '
		if xtitle < -999999.0, xtitle = 0.0; end
		if ytitle < -999999.0, ytitle = 0.0; end
		fun_symbol(xtitle,ytitle,albht,title_,0.0,80);
		ititle = 1;
	end

	% 绘制模型轮廓
	if imod == 1

		% 绘制模型层界面（水平方向）
		fun_pcolor(mcol(1));

		% 对模型的每个层边界进行循环(ncont为层边界数)
		for ii = 1:ncont % 10
			nptsc = nzed(ii);
			if nptsc == 1
				nptsc = 2;
				xcp(1) = orig;
				zcp(1) = (zm(ii,1)-zmax) ./ zscale + sep;
				xcp(2) = xmm + orig;
				zcp(2) = zcp(1);
			else
				for jj = 1:nptsc % 20
					xcp(jj) = (xm(ii,jj)-xmin) ./ xscale + orig;
					zcp(jj) = (zm(ii,jj)-zmax) ./ zscale + sep;
				end % 20
			end
			if idash ~= 1
				fun_line(xcp,zcp,nptsc);
				% 335
				if i33 == 1
					fprintf(fID_33, '%12.4f%4d%4d%12.4f%12.4f\n', 0.0,0,0,0.0,0.0);
				end
			else
				dash = xmm ./ 150.0;
				fun_dashln(xcp,zcp,nptsc,dash);
			end
		end % 10

		% 绘制 floating-reflectors
		fun_pcolor(mcol(3));

		if ifrbnd == 1
			for ii = 1:nfrefl % 110
				for jj = 1:npfref(ii) % 120
					xcp(jj) = (xfrefl(ii,jj)-xmin)./xscale + orig;
					zcp(jj) = (zfrefl(ii,jj)-zmax)./zscale + sep;
				end % 120
				if idash ~= 1
					fun_line(xcp,zcp,npfref(ii));
					if i33 == 1
						% 335
						fprintf(fID_33, '%12.4f%4d%4d%12.4f%12.4f\n', 0.0,0,0,0.0,0.0);
					end
				else
					dashfr = xmm ./ 300.0;
					fun_dashln(xcp,zcp,npfref(ii),dashfr);
				end
			end % 110
		end

		% 绘制模型中每个 block 的竖直边界
		if ibnd == 1
			fun_pcolor(mcol(2));

			for ii = 1:nlayer % 30
				if nblk(ii) > 1
					for jj = 1:nblk(ii)-1 % 40
						xcp(1) = (xbnd(ii,jj,2)-xmin) ./ xscale + orig;
						xcp(2) = xcp(1);
						zp1 = s(ii,jj,1) .* xbnd(ii,jj,2) + b(ii,jj,1);
						zp2 = s(ii,jj,2) .* xbnd(ii,jj,2) + b(ii,jj,2);
						if abs(zp2 - zp1) > 0.001
							zcp(1) = (zp1-zmax)./zscale + sep;
							zcp(2) = (zp2-zmax)./zscale + sep;
							if idash ~= 1
								fun_line(xcp,zcp,2);
								if i33 == 1
									% 335
									fprintf(fID_33, '%12.4f%4d%4d%12.4f%12.4f\n', 0.0,0,0,0.0,0.0);
								end
							else
								fun_dashln(xcp,zcp,2,dash);
							end
						end
					end % 40
				end
			end % 30
		end

		% 绘制 smoothed bounderies
		if ibsmth == 2

			fun_pcolor(mcol(4));

			for ii = 1:npbnd % 600
				x = xmin + (ii-1) .* xsinc;
				xcp(ii) = (x-xmin) ./ xscale + orig;
			end % 600
			for ii = 1:nlayer+1 % 610
				% 620
				zcp(1:npbnd) = (cosmth(ii,1:npbnd) - zmax) ./ zscale + sep;
				fun_line(xcp,zcp,npbnd);
				if i33 == 1
					% 335
					fprintf(fID_33, '%12.4f%4d%4d%12.4f%12.4f\n', 0.0,0,0,0.0,0.0);
				end
			end % 610
		end
	end

	% 在模型中每个小梯形中写上 P 波和 S 波的速度值
	if ivel ~= 0

		fun_pcolor(mcol(5));

		ht = albht .* velht;
		for ii = 1:nlayer % 50
			for jj = 1:nblk(ii) % 60
				htt = ht;
				if ivg(ii,jj) ~= -1
					% 165 % -------------------- cycle165 begin
					cycle165 = true;
					while cycle165
						xp = xbnd(ii,jj,1);
						z1 = s(ii,jj,1).*xp + b(ii,jj,1);
						zp1 = (z1-zmax)./zscale - 1.5.*htt + sep;
						xp1 = (xp-xmin)./xscale + 0.5.*htt + orig;
						xp = xbnd(ii,jj,2);
						z2 = s(ii,jj,1).*xp + b(ii,jj,1);
						zp2 = (z2-zmax)./zscale - 1.5.*htt + sep;
						xp2 = (xp-xmin)./xscale - 4.0.*htt + orig;
						xp = xbnd(ii,jj,1);
						z3 = s(ii,jj,2).*xp + b(ii,jj,2);
						zp3 = (z3-zmax)./zscale + 0.5.*htt + sep;
						xp3 = xp1;
						xp = xbnd(ii,jj,2);
						z4 = s(ii,jj,2).*xp + b(ii,jj,2);
						zp4 = (z4-zmax)./zscale + 0.5.*htt + sep;
						xp4 = xp2;

						if abs(z1 - z3) > 0.005 && abs(z2 - z4) > 0.005
							xhmin = 4.0 .* htt;
						else
							xhmin = 8.0 .* htt;
						end

						if xp2-xp1 < xhmin || (abs(z1-z3) > 0.005 && zp1-zp3 <= 1.5.*htt) ...
							|| (abs(z2-z4) > 0.005 && zp2-zp4 <= 1.5.*htt)
							htt = htt ./ 1.25;
							continue; % go to 165
						end
						break; % go to nothing
					end % -------------------- cycle165 end

					v1 = vm(ii,jj,1);
					if ivel < 0
						v1 = v1 .* vsvp(ii,jj);
					end
					if abs(z1-z3) > 0.005
						fun_number(xp1,zp1,htt,v1,0.0,2);
						v3 = vm(ii,jj,3);
						if ivel < 0
							v3 = v3 .* vsvp(ii,jj);
						end
						fun_number(xp3,zp3,htt,v3,0.0,2);
					else
						fun_number(xp1+4.0.*htt,zp1,htt,v1,0.0,2)
					end
					v2 = vm(ii,jj,2);
					if ivel < 0
						v2 = v2 .* vsvp(ii,jj);
					end
					if abs(z2-z4) > 0.005
						fun_number(xp2,zp2,htt,v2,0.0,2);
						v4 = vm(ii,jj,4);
						if ivel < 0
							v4 = v4 .* vsvp(ii,jj);
						end
						fun_number(xp4,zp4,htt,v4,0.0,2);
					else
						fun_number(xp2-4.0.*htt,zp2,htt,v2,0.0,2);
					end
				end
			end % 60
		end % 50
	end

	fun_pcolor(ifcol);

	fun_empty();

	return;
end % fun_pltmod end
