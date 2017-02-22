% trc.f
% [x,y,~,~]
% called by: fun_trace;
% call: none.

function [x,y,npt,iflag] = fun_strait(x,y,npt,iflag)
% if the upper and lower velocities in a layer are nearly the same
% (or equal) the ray path is essentially a straight line segment.
% therefore, no need to use runge kutta routine. this routine
% calculates new ray coordinates and tangent for a zero gradient
% layer.

%              iflag=0 --  x is present x coordinate
%              iflag=1 --  x is present z coordinate

    global file_rayinvr_par file_rayinvr_com;
    run(file_rayinvr_par);
    % y = zeros(1,2);
    run(file_rayinvr_com);

    if iflag == 0
        x = xr(npt) + fid.*smax./dstepf;
        y(1) = zr(npt) + (x - xr(npt)) ./ tan(arar(npt,2));
        y(2) = arar(npt,2);
    else
        if (fid .* arar(npt,2)) <= pi2
            x = x + smax ./ dstepf;
        else
            x = x - smax ./ dstepf;
        end
        y(1) = xr(npt) + tan(arar(npt,2)) .* (x - zr(npt));
        y(2) = arar(npt,2);
    end
    return;
end % function end