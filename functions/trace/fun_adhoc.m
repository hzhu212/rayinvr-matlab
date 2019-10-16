% trc.f
% [x,z,a]
% called by: fun_adjpt;
% call: none.

function [x,z,a] = fun_adhoc(x1,z1,a1,x2,z2,a2,mb,bb,it)
% calculate intersection point (x,z) along boundary given by:
%
%    it=0 --  slope mb, intercept bb
%    it=1 --  x=bb
%
% between points (x1,z1) and (x2,z2) using a straight line path
% between (x1,z1) and (x2,z2). also calculate angle of
% incidence (a) at boundary

    % real mb, mr
    if (x1-x2)==0.0 && (z1-z2)==0.0
        x = x1;
        z = z1;
        a = (a1+a2) ./ 2.0;
    else
        if (10.0.*abs(x2-x1)) > abs(z2-z1)
            mr = (z2-z1) ./ (x2-x1);
            br = z1 - mr .* x1;
            if it == 0
                if mb-mr == 0.0
                    x = (x1+x2) ./ 2.0;
                else
                    x = (br-bb) ./ (mb-mr);
                end
            else
                x = bb;
            end
            z = mr .* x + br;
        else
            mr = (x2-x1) ./ (z2-z1);
            br = x1 - mr .* z1;
            if it == 0
                if (1.0-mr.*mb) == 0.0
                    z = (z1+z2) ./ 2.0;
                else
                    z = (br.*mb+bb) ./ (1.0-mr.*mb);
                end
            else
                if abs(mr) > 0.000001
                    z = (bb-br) ./ mr;
                else
                    z = (z1+z2) ./ 2.0;
                end
            end
            x = mr .* z + br;
        end
        d1 = sqrt((x1-x).^2 + (z1-z).^2);
        d2 = sqrt((x2-x).^2 + (z2-z).^2);
        if d1 + d2 == 0.0
            a = (a1+a2) ./ 2.0;
        else
            a = (d1.*a2 + d2.*a1) ./ (d1+d2);
        end
    end

end % fun_adhoc end
