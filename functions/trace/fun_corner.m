% trc.f
% [xn,zn,an,icase]
% called by: fun_adjpt;
% call: none.

function [xn,zn,an,icase] = fun_corner(x,z,x1,z1,a1,i1,x2,z2,a2,i2)
% determine which point (x1,z1) or (x2,z2) is nearest to (x,z)
% and assign new point (xn,zn) accordingly as well as an and icase

    d1 = sqrt((x-x1).^2 + (z-z1).^2);
    d2 = sqrt((x-x2).^2 + (z-z2).^2);
    if d1 < d2
        icase = i1;
        xn = x1;
        zn = z1;
        an = a1;
    else
        icase = i2;
        xn = x2;
        zn = z2;
        an = a2;
    end
    return;
end % fun_corner end
