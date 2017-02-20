% rngkta.f
% [~,~,f]
% called by: fun_trace;
% call: none.

function [x,y,f] = fun_odezfi(x,y,f)
% pair of first order o.d.e.'s solved by runge kutta method
% with z as independent variable

    global file_rayinvr_par file_rayinvr_com;
    run(file_rayinvr_par);
    % real y(2),f(2)
    run(file_rayinvr_com);

    sa = 1.0 .* sign(y(2));
    n1 = fix(sa.*y(2).*factan) + 1;
    f(1) = mtan(n1).*y(2) + sa.*btan(n1);
    term1 = c(layer,iblk,3) + c(layer,iblk,4) .* y(1);
    term2 = y(1).*(c(layer,iblk,1)+c(layer,iblk,2).*y(1)) + term1.*x + c(layer,iblk,5);
    vxv = (y(1).*(c(layer,iblk,8)+c(layer,iblk,9).*y(1))+c(layer,iblk,10).*x+c(layer,iblk,11)) ./ (term2.*(c(layer,iblk,6).*y(1)+c(layer,iblk,7)));
    vzv = term1 ./ term2;
    f(2) = vzv .* f(1) - vxv;
    return;
end