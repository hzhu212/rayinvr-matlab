% plt.f
% []
% call:
% called by: main;

function fun_my_pltmod(ncont,ibnd,imod,iaxlab,ivel,velht,idash,ifrbnd,idata,iroute,i33)
% plot model using matlab graphic functions.

	global albht b cosmth ibsmth ifcol iplots isep ititle itx ivg mcol nblk ...
		ndecix ndeciz nfrefl nlayer npbnd npfref ntickx ntickz nzed orig s ...
		sep title_ tmm vm vsvp xbnd xfrefl xm xmax xmin xmm xscale xsinc ...
		xtitle xtmax xtmin xwndow ytitle ywndow zfrefl zm zmax zmin zmm zscale ...
		ztmax ztmin;
	colors = 'krgbcmyw';

	% 创建并获取 figure 对象
	Hfigure = figure();

	% 获取 axis 对象
	Haxis = gca();

	% 将 x 轴放在顶部，并将 y 轴方向朝下
	set(Haxis,'XAxisLocation','top','YDir','reverse');

	hold on;

	% 绘制坐标轴标题
	if iaxlab == 1
		xlabel('DISTANCE (km)');
		ylabel('DEPTH (km)');
	end

	% 绘制图像边框
	box on;

	% 设定 lineStyle (实线还是虚线)
	if idash == 1, lineStyle = '--';
	else lineStyle = '-'; end
	% 设定 lineColor，默认为黑色
	lineColor = 'k';

	% 绘制模型轮廓
	if imod == 1

		% 绘制模型层界面（水平方向）
		lineColor = colors(mcol(1));
		for ii = 1:ncont
			nptsc = nzed(ii);
			if nptsc == 1
				xcp = [0, xm(ii,1)];
				zcp = [zm(ii,1), zm(ii,1)];
			else
				xcp = xm(ii,1:nptsc);
				zcp = zm(ii,1:nptsc);
			end
			plot(xcp,zcp,[lineStyle,lineColor]);
		end

		lineColor = colors(mcol(3));

		% 绘制 floating-reflectors
		% ifrbnd = 1;
		if ifrbnd == 1
			for ii = 1:nfrefl
				xcp = xfrefl(ii,1:npfref(ii));
				zcp = zfrefl(ii,1:npfref(ii));
				plot(xcp,zcp,[lineStyle,lineColor]);
			end
		end

		% 绘制模型中每个 block 的竖直边界
		% ibnd = 1;
		if ibnd == 1
		    lineColor = colors(mcol(2));
		    for ii = 1:nlayer
		        if nblk(ii) > 1
		            for jj = 1:nblk(ii)
		            	coorx = xbnd(ii,jj,2);
		                xcp = [coorx, coorx];
		                zcp = squeeze(s(ii,jj,1:2) .* coorx + b(ii,jj,1:2));
						plot(xcp,zcp,[lineStyle,lineColor]);
		            end
		        end
		    end
		end

	end

	hold off;

	return;
end % fun_my_pltmod end