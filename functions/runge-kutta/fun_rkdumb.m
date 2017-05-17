% rngkta.f
% [y]
% called by: fun_trace;
% call: derivs -> fun_odezfi, derivs -> fun_odexfi

function [y] = fun_rkdumb(y,x1,x2,derivs, btan,c,factan,iblk,layer,mtan)
% routine to solve a 2x2 system of first order o.d.e.'s
% using a 4th-order runge-kutta method without error control
% derivs 是一个函数参数
% 使用 4 阶不带错误控制的 龙格-库塔方法解决 2×2 的一阶常微分方程组

% x1: 当前节点的 x 坐标
% x2: 下一个节点的 x 坐标(通过当前 x 坐标与步长求得)
% y(1): 当前节点的 z 坐标
% y(2): 当前节点的入射角
% 返回值: y(1),y(2) 分别为下一个节点的 z 坐标和入射角

	% dimension y(2),dydx(2),yt(2),dyt(2),dym(2)

	x = x1;
	h = x2 - x1;
	if x+h == x, return; end

	[dydx] = derivs(x,y, btan,c,factan,iblk,layer,mtan);

	hh = h .* 0.5;
	h6 = h ./ 6.0;
	xh = x + hh;

	for ii = 1:2 % 11
		yt(ii) = y(ii) + hh .* dydx(ii);
	end % 11

	[dyt] = derivs(xh,yt, btan,c,factan,iblk,layer,mtan);

	for ii = 1:2 % 12
		yt(ii) = y(ii) + hh .* dyt(ii);
	end % 12

	[dym] = derivs(xh,yt, btan,c,factan,iblk,layer,mtan);

	for ii = 1:2 % 13
		yt(ii) = y(ii) + h .* dym(ii);
		dym(ii) = dyt(ii) + dym(ii);
	end % 13

	[dyt] = derivs(x+h,yt, btan,c,factan,iblk,layer,mtan);

	for ii = 1:2 % 14
		y(ii) = y(ii) + h6 .* (dydx(ii)+dyt(ii)+2.0.*dym(ii));
	end % 14
	return;

end % function end
