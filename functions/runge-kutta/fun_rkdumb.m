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
    y = y(1:2);

    x = x1;
    h = x2 - x1;
    if x+h == x, return; end
    [dydx] = derivs(x,y, btan,c,factan,iblk,layer,mtan);

    hh = h .* 0.5;
    h6 = h ./ 6.0;
    xh = x + hh;
    yt = y + hh .* dydx;
    [dyt] = derivs(xh,yt, btan,c,factan,iblk,layer,mtan);

    yt = y + hh .* dyt;
    [dym] = derivs(xh,yt, btan,c,factan,iblk,layer,mtan);

    yt = y + h .* dym;
    dym = dyt + dym;

    % if yt(2) > 1000000
    %     disp('-- fun_rkdumb 4 --');
    %     disp(yt(2));
    % end
    [dyt] = derivs(x+h,yt, btan,c,factan,iblk,layer,mtan);

    y = y + h6 .* (dydx+dyt+2.0.*dym);

end % function end
