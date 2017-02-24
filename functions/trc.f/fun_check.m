% trc.f
% [~,x,z]
% called by: fun_trace;
% call: none.

function [iflag,x,z] = fun_check(iflag,x,z)
% check that the new ray point will still be inside the current
% trapezoid; if not, adjust the step length so it falls 1 meter
% outside the trapezoid

    % global file_rayinvr_par file_rayinvr_com;
    % run(file_rayinvr_par);
    % run(file_rayinvr_com);

    global b iblk id layer s xbnd;

    if iflag == 0
        if x < xbnd(layer,iblk,1), x = xbnd(layer,iblk,1) - 0.001; end
        if x > xbnd(layer,iblk,2), x = xbnd(layer,iblk,2) + 0.001; end
    else
        z1 = s(layer,iblk,1).*xbnd(layer,iblk,1) + b(layer,iblk,1);
        z2 = s(layer,iblk,1).*xbnd(layer,iblk,2) + b(layer,iblk,1);
        zt = s(layer,iblk,1).*x + b(layer,iblk,1);
        z3 = s(layer,iblk,2).*xbnd(layer,iblk,1) + b(layer,iblk,2);
        z4 = s(layer,iblk,2).*xbnd(layer,iblk,2) + b(layer,iblk,2);
        zb = s(layer,iblk,2).*x + b(layer,iblk,2);
        if id < 0
            zt = min(z1,zt); % amin1 -> min
            zb = max(z3,zb); % amax1 -> max
        else
            zt = min(z2,zt); % amin1 -> min
            zb = max(z4,zb); % amax1 -> max
        end
        if z < zt, z = zt - 0.001; end
        if z > zb, z = zb + 0.001; end
    end
    return;
end % function end