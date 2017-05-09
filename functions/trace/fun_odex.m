% trc.f
% [~,~,f]
% called by: fun_trace;
% call: fun_vel; done.

function [x,y,f] = fun_odex(x,y,f)
% pair of first order o.d.e.'s solved by runge kutta method
% with x as independent variable
% 使用 龙格-库塔 方法解一阶常微分方程，把 x 当做自变量

% y(1): z
% y(2): theta
% f(1): dz/dx
% f(2): d theta/ dx
% term1: vz 的分子
% term2: v(x,z) 的分子
% vxv, vzv: vx/v, vz/v
% vx, vz: partial v/ partial x, partial v/ partial z

% 该函数的效果是：给定初值 x0,z0,theta0, 求出 dz/dx, dtheta/dx,
% 外层函数得到 dz/dx dtheta/dx, 并引入射线步长，求出下一个射线节点的 x1,z1,theta1,
% 再调用该函数处理下一个射线节点，如此循环往复

    global fID_12;
    global c iblk idump irkc isrkc layer;
    global ok;

    f(1) = 1.0 ./ tan(y(2));
    term1 = c(layer,iblk,3) + c(layer,iblk,4) .* x;
    term2 = x .* (c(layer,iblk,1)+c(layer,iblk,2).*x) + term1.*y(1) + c(layer,iblk,5);
    vxv = (x.*(c(layer,iblk,8) + c(layer,iblk,9).*x) + c(layer,iblk,10).*y(1) + c(layer,iblk,11)) ./ (term2.* (c(layer,iblk,6).*x+c(layer,iblk,7)));
    vzv = term1 ./ term2;
    f(2) = vzv - vxv .* f(1);

    if ~ok
        if isrkc==1 & idump==1
            % 5
            fprintf(fID_12,'***  possible inaccuracies in rngkta w.r.t. x  ***\n|del(v)| = %12.5f\n',fun_vel(x,y(1), c,iblk,layer).*(vxv.^2+vzv.^2).^0.5);
        end
        irkc = 1;
        isrkc = 0;
    end
    return;
end % function end
