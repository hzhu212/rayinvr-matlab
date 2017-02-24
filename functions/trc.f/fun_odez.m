% trc.f
% [~,~,f]
% called by: fun_trace;
% call: fun_vel; done.

function [x,y,f] = fun_odez(x,y,f)
% pair of first order o.d.e.'s solved by runge kutta method
% with z as independent variable

    % global file_rayinvr_par file_rayinvr_com;
    % global fID_12;
    % run(file_rayinvr_par);
    % run(file_rayinvr_com);
    % real y(2),f(2)
    % logical ok
    % common /rkcs/ ok

    global fID_12;
    global c iblk idump irkc isrkc layer;
    global ok;

    f(1) = tan(y(2));
    term1 = c(layer,iblk,3) + c(layer,iblk,4) .* y(1);
    term2 = y(1) .* (c(layer,iblk,1)+c(layer,iblk,2).*y(1)) + term1.*x + c(layer,iblk,5);
    vxv = (y(1).*(c(layer,iblk,8) + c(layer,iblk,9).*y(1)) + c(layer,iblk,10).*x + c(layer,iblk,11)) ./ (term2.* (c(layer,iblk,6).*y(1)+c(layer,iblk,7)));
    vzv = term1 ./ term2;
    f(2) = vzv .* f(1) - vxv;

    if ~ok
        if isrkc==1 & idump==1
            % 5
            fprintf(fID_12,'***  possible inaccuracies in rngkta w.r.t. z  ***\n|del(v)| = %12.5f\n',fun_vel(y(1),x).*(vxv.^2+vzv.^2).^0.5);
        end
        irkc = 1;
        isrkc = 0;
    end
    return;
end % function end