% rngkta.f

function [y,x1,x2,derivs] = fun_rkdumb(y,x1,x2,derivs)
% routine to solve a 2x2 system of first order o.d.e.'s
% using a 4th-order runge-kutta method without error control
% derivs 是一个函数参数

    % dimension y(2),dydx(2),yt(2),dyt(2),dym(2)
    x = x1;
    h = x2 - x1;
    if x+h==x, return; end

    [x,y,dydx] = derivs(x,y,dydx);

    hh = h .* 0.5;
    h6 = h ./ 6.0;
    xh = x + hh;
    for ii = 1:2 % 11
        yt(ii) = y(ii) + hh .* dydx(ii);
    end % 11

    [xh,yt,dyt] = derivs(xh,yt,dyt);

    for ii = 1:2 % 12
        yt(ii) = y(ii) + hh .* dyt(ii);
    end % 12

    [xh,yt,dym] = derivs(xh,yt,dym);

    for ii = 1:2 % 13
        yt(ii) = y(ii) + h .* dym(ii);
        dym(ii) = dyt(ii) + dym(ii);
    end % 13

    [~,yt,dyt] = derivs(x+h,yt,dyt);

    for ii = 1:2 % 14
        y(ii) = y(ii) + h6 .* (dydx(ii)+dyt(ii)+2.0.*dym(ii));
    end % 14
    return;

end % function end