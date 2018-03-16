% plt.f
% []
% call:
% called by: main;

function fun_my_pltmod(ncont,ibnd,imod,iaxlab,ivel,velht,idash,ifrbnd,idata,iroute,i33)
% plot model with matlab graphic functions.

	global b cosmth ibsmth ifcol ivg mcol nblk nfrefl nlayer npbnd npfref ...
		nzed s vm vsvp xbnd xfrefl xm xsinc zfrefl zm zmax zmin;
	global matlabColors currentColor hFigure1;

	if isempty(hFigure1)
		% 创建一个 figure 对象
		hFigure1 = figure('NumberTitle','off','Name','Ray Tracing','Position',[200,130,900,500]);
		% (在当前 figure 对象上)创建一个 axes 子对象
		axes('FontName','Consolas','position',[0.06,0.1,0.9,0.8]);
	else
		figure(hFigure1);
		% cla(gca(),'reset');
	end

	% 设定x轴位置为顶部，y轴方向朝下
	set(gca(),'XAxisLocation','top','YDir','reverse');

	hold on;

	% 绘制坐标轴标题
	if iaxlab == 1
		xlabel('Distance (km)','FontName','Consolas','FontSize',11);
		ylabel('Depth (km)','FontName','Consolas','FontSize',11);
	end

	% 绘制图像边框
	box on;

	% 设定 lineStyle (实线还是虚线)
	if idash == 1, lineStyle = '--';
	else lineStyle = '-'; end
	% 设定颜色，默认为前景色
	% currentColor = matlabColors{ifcol};

	% 绘制模型轮廓
	if imod == 1

		% 绘制模型层界面（水平方向）
		currentColor = matlabColors{mcol(1)};
		for ii = 1:ncont
			nptsc = nzed(ii);
			if nptsc == 1
				xcp = [0, xm(ii,1)];
				zcp = [zm(ii,1), zm(ii,1)];
			else
				xcp = xm(ii,1:nptsc);
				zcp = zm(ii,1:nptsc);
			end
			plot(xcp,zcp,lineStyle,'Color',currentColor);
		end

		currentColor = matlabColors{mcol(3)};

		% 绘制 floating-reflectors
		% ifrbnd = 1;
		if ifrbnd == 1
			for ii = 1:nfrefl
				xcp = xfrefl(ii,1:npfref(ii));
				zcp = zfrefl(ii,1:npfref(ii));
				plot(xcp,zcp,lineStyle,'Color',currentColor);
			end
		end

		% 绘制模型中每个 block 的竖直边界
		% ibnd = 1;
		if ibnd == 1
			currentColor = matlabColors{mcol(2)};
			for ii = 1:nlayer
				if nblk(ii) > 1
					for jj = 1:nblk(ii)
						coorx = xbnd(ii,jj,2);
						xcp = [coorx, coorx];
						zcp = squeeze(s(ii,jj,1:2) .* coorx + b(ii,jj,1:2));
						plot(xcp,zcp,lineStyle,'Color',currentColor);
					end
				end
			end
		end

		% 绘制 smoothed bounderies
		% ibsmth = 2;
		if ibsmth == 2
			currentColor = matlabColors{mcol(4)};
			xcp = ((1:npbnd) - 1) .* xsinc;
			for ii = 1:nlayer+1
				% zcp = cosmth(ii,1:npbnd) - zmax;
				zcp = cosmth(ii,1:npbnd) - zmin;
				plot(xcp,zcp,lineStyle,'Color',currentColor);
			end
		end

		% 在模型中每个小梯形中写上 P 波和 S 波的速度值
		% ivel = 1;
		if ivel ~= 0
			currentColor = matlabColors{mcol(5)};
			% currentColor = 'r';
			for ii = 1:nlayer
				for jj = 1:nblk(ii)
					if ivg(ii,jj) ~= -1
						x1 = xbnd(ii,jj,1);
						x2 = xbnd(ii,jj,2);
						x3 = x1;
						x4 = x2;
						z1 = s(ii,jj,1) .* x1 + b(ii,jj,1);
						z2 = s(ii,jj,1) .* x2 + b(ii,jj,1);
						z3 = s(ii,jj,2) .* x1 + b(ii,jj,2);
						z4 = s(ii,jj,2) .* x2 + b(ii,jj,2);
						% x = [x1,x2,x3,x4];
						% z = [z1,z2,z3,z4];
						v = squeeze(vm(ii,jj,1:4));
						if ivel < 0
							v = v .* vsvp(ii,jj);
						end
						text(x1,z1,sprintf('%4.2f',v(1)),'FontSize',8,'Color',currentColor,'VerticalAlignment','top');
						text(x2,z2,sprintf('%4.2f',v(2)),'FontSize',8,'Color',currentColor,'VerticalAlignment','top','HorizontalAlignment','right');
						text(x3,z3,sprintf('%4.2f',v(3)),'FontSize',8,'Color',currentColor,'VerticalAlignment','bottom');
						text(x4,z4,sprintf('%4.2f',v(4)),'FontSize',8,'Color',currentColor,'VerticalAlignment','bottom','HorizontalAlignment','right');
					end
				end
			end
		end
	end

	hold off;

	currentColor = matlabColors{ifcol};

	return;
end % fun_my_pltmod end
