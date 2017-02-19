% trc.f

function [x,y,f] = fun_odex(x,y,f)
% pair of first order o.d.e.'s solved by runge kutta method
% with x as independent variable

    global file_rayinvr_par file_rayinvr_com;
    global fID_12;
    run(file_rayinvr_par);
    % real y(2),f(2)
    % logical ok
    run(file_rayinvr_com);
    % common /rkcs/ ok

    f(1) = 1.0 ./ tan(y(2));
    term1 = c(layer,iblk,3) + c(layer,iblk,4) .* x;
    term2 = x .* (c(layer,iblk,1)+c(layer,iblk,2).*x) + term1.*y(1) + c(layer,iblk,5);
    vxv = (x.*(c(layer,iblk,8) + c(layer,iblk,9).*x) + c(layer,iblk,10).*y(1) + c(layer,iblk,11)) ./ (term2.* (c(layer,iblk,6).*x+c(layer,iblk,7)));
    vzv = term1 ./ term2;
    f(2) = vzv - vxv .* f(1);

    if ~ok
        if isrkc==1 & idump==1
            % 5
            fprintf(fID_12,'***  possible inaccuracies in rngkta w.r.t. x  ***\n|del(v)| = %12.5f\n',vel(x,y(1)).*(vxv.^2+vzv.^2).^0.5);
        end
        irkc = 1;
        isrkc = 0;
    end
    return;
end % function end