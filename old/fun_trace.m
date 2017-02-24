%% fun_trace: trace a single ray through the model
% trc.f
function [npt,ifam,ir,iturn,invr,xsmax,iflag,idl,idr,iray,ii2pt,i1ray,modout] = fun_trace(npt,ifam,ir,iturn,invr,xsmax,iflag,idl,idr,iray,ii2pt,i1ray,modout)

    global file_rayinvr_par file_rayinvr_com;
    global fID_11 fID_12;
    run(file_rayinvr_par);
    % external odex,odez,odexfi,odezfi
    % real y(2),f(2),w1(2),w2(2),w3(2),left
    % [y,f,w1,w2,w3] = deal(zeros(1,2));
    % left = 0;
    run(file_rayinvr_com);

    ntray = ntray + 1;
    dstepf = 1.0;
    n2 = 0; n3 = 0;
    iflag = 0;
    if ivg(layer,iblk) > 0
        hn = dstep(xr(npt),zr(npt)) ./ hdenom;
    else
        hn = smax ./ hdenom;
    end
    hminn = hn .* hmin;

    % 1000
    % -------------------- circle 1000 begin
    isGoto1000 = false;
    while true

    if idump == 1
        fprintf(fID_12,'%2d%3d%4d%8.3f%8.3f%8.2f%8.2f%7.2f%7.2f%3d%3d%3d%3d\n',...
            ifam,ir,npt,xr(npt),zr(npt),ar(npt,1).*pi18,ar(npt,2).*pi18,...
            vr(npt,1),vr(npt,2),layer,iblk,id,iwave); % 5
    end
    if iwave == -1 & vr(npt,2) <= 0.001
        vr(npt,2) = 0.0;
        iflag = 1;
        if ir ~= 0
            fprintf(fID_11,'***  ray stopped - s-wave cannot propagate  ***\n'); % 25
        end
        fun_goto900(); return; % go to 900
    end
    if npt > 1
        if ((ar(npt,2) - fid.*pi2) .* (ar(npt-1,2) - fid.*pi2)) <= 0.0
            if iturn ~= 0, fun_goto900(); return; end % go to 900
        end
    end

    isrkc = 1;
    if (fid .* ar(npt,2)) >= pi4 & (fid .* ar(npt,2)) <= pi34
        % solve o.d.e.'s w.r.t. x

        x = xr(npt);
        y(1) = zr(npt);
        y(2) = ar(npt,2);

        if ivg(layer,iblk) == 0
            [x,y,npt,~] = fun_strait(x,y,npt,0);
        else
            z = x + fid.*dstep(xr(npt),zr(npt))./dstepf;
            [~,xr(npt),z] = fun_check(1,xr(npt),z);

            if ifast == 0
                odex = @ fun_odex;
                [x,z,y,f,hn,hminn,tol,~,w1,w2,w3] = fun_rngkta(x,z,y,f,hn,hminn,tol,odex,w1,w2,w3);
            else
                odexfi = @ fun_odexfi;
                [y,x,z,~] = fun_rkdumb(y,x,z,odexfi);
                x = z;
            end
        end
        if npt == ppray, fun_goto999(); return; end % go to 999
        npt = npt + 1;
        xr(npt) = x;
        zr(npt) = y(1);

    else
        % solve o.d.e.'s w.r.t. z

        x = zr(npt);
        y(1) = xr(npt);
        y(2) = ar(npt,2);

        if ivg(layer,iblk) == 0
            [x,y,npt,~] = fun_strait(x,y,npt,1);
        else
            if (fid*ar(npt,2)) <= pi2
                z = x + dstep(xr(npt),zr(npt)) ./ dstepf;
            else
                z = x - dstep(xr(npt),zr(npt)) ./ dstepf;
            end

            [~,xr(npt),z] = fun_check(1,xr(npt),z)

            if ifast == 0
                % call rngkta(x,z,y,f,hn,hminn,tol,odez,w1,w2,w3)
                odez = @ fun_odez;
                [x,z,y,f,hn,hminn,tol,~,w1,w2,w3] = fun_rngkta(x,z,y,f,hn,hminn,tol,odez,w1,w2,w3);
            else
                % call rkdumb(y,x,z,odezfi)
                odezfi = @ fun_odezfi;
                [y,x,z,~] = fun_rkdumb(y,x,z,odezfi);
                x = z;
            end
        end
        if npt == ppray, fun_goto999(); return; end % go to 999
        npt = npt + 1;
        xr(npt) = y(1);
        zr(npt) = x;
    end

    ar(npt,1) = y(2);
    ar(npt,2) = y(2);
    vp(npt,1) = vel(xr(npt),zr(npt));
    vs(npt,1) = vp(npt,1) .* vsvp(layer,iblk);
    if iwave == 1
        vr(npt,1) = vp(npt,1);
    else
        vr(npt,1) = vs(npt,1);
    end
    vr(npt,2) = vr(npt,1);
    vp(npt,2) = vp(npt,1);
    vs(npt,2) = vs(npt,1);

    iflagf = 0;
    if ifcbnd >= 0
        if nptbnd == 0 | icasel ~= 5
            [ir,npt,xfr,zfr,ifrpt,iflagf] = fun_frefpt(ir,npt,xfr,zfr,ifrpt,iflagf);
        end
    end

    top = s(layer,iblk,1) .* xr(npt) + b(layer,iblk,1);
    bottom = s(layer,iblk,2) .* xr(npt) + b(layer,iblk,2);
    left = xbnd(layer,iblk,1);
    right = xbnd(layer,iblk,2);

    if zr(npt)>top & zr(npt)<=bottom & xr(npt)>left & xr(npt)<=right
        if iflag == 1
            [ir,npt,xfr,zfr,ifrpt,modout,invr] = fun_frefl(ir,npt,xfr,zfr,ifrpt,modout,invr);
        end
        if ir~=0 & invr==1
            [layer,iblk,npt] = fun_velprt(layer,iblk,npt);
        end
        dstepf = 1.0;
        % go to 1000
        isGoto1000 = true;
    else
        nptin = npt;
        [npt,top,bottom,left,right,ifam,ir,iturn,lstart,istart,invr,iflag,idl,idr,xfr,zfr,ifrpt,iflagf,modout] = ...
        fun_adjpt(npt,top,bottom,left,right,ifam,ir,iturn,lstart,istart,invr,iflag,idl,idr,xfr,zfr,ifrpt,iflagf,modout);

        if ir~=0 & invr==1 & nptin==npt
            [lstart,istart,npt] = fun_velprt(lstart,istart,npt);
        end

        if ihdw==1 & (ir~=0 | ii2pt>0)
            [ifam,ir,npt,invr,xsmax,iflag,i1ray,modout] = fun_hdwave(ifam,ir,npt,invr,xsmax,iflag,i1ray,modout);
        end

        if iflag==0, isGoto1000=true; end
    end

    if ~isGoto1000, break; end
    end % -------------------- circle 1000 end

    fun_goto900(); return;

    % 900
    function fun_goto900()
        if ifcbnd > 0 & idray(2) ~= 4 & ii2pt == 2
            vr(npt,2) = 0.0;
            iflag = 1;
        end
        ntpts = ntpts + npt;
        return;
    end

    % 999
    function fun_goto999()
        vr(500,2) = 0.0;
        iflag = 1;
        if ir ~= 0
            fprintf(fID_11,'***  ray stopped - consists of too many points  ***\n'); % 15
        end
        if ifcbnd > 0 & idray(2) ~= 4 & ii2pt == 2
            vr(npt,2) = 0.0;
            iflag = 1;
        end
        ntpts = ntpts + npt;
        return;
    end

end % function end

% --------------------------------------------------------------------------------

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

% --------------------------------------------------------------------------------

% trc.f
function [x,y,f] = fun_odez(x,y,f)
% pair of first order o.d.e.'s solved by runge kutta method
% with z as independent variable

    global file_rayinvr_par file_rayinvr_com;
    global fID_12;
    run(file_rayinvr_par);
    % real y(2),f(2)
    % logical ok
    run(file_rayinvr_com);
    % common /rkcs/ ok

    f(1) = tan(y(2));
    term1 = c(layer,iblk,3) + c(layer,iblk,4) .* y(1);
    term2 = y(1) .* (c(layer,iblk,1)+c(layer,iblk,2).*y(1)) + term1.*x + c(layer,iblk,5);
    vxv = (y(1).*(c(layer,iblk,8) + c(layer,iblk,9).*y(1)) + c(layer,iblk,10).*x + c(layer,iblk,11)) ./ (term2.* (c(layer,iblk,6).*y(1)+c(layer,iblk,7)));
    vzv = term1 ./ term2;
    f(2) = vzv .* f(1) - vxv;

    if ~ok
        if isrkc==1 & idump==1
            % 5
            fprintf(fID_12,'***  possible inaccuracies in rngkta w.r.t. z  ***\n|del(v)| = %12.5f\n',vel(y(1),x).*(vxv.^2+vzv.^2).^0.5);
        end
        irkc = 1;
        isrkc = 0;
    end
    return;
end % function end

% --------------------------------------------------------------------------------

% rngkta.f
function [x,y,f] = fun_odexfi(x,y,f)
% pair of first order o.d.e.'s solved by runge kutta method
% with x as independent variable

    global file_rayinvr_par file_rayinvr_com;
    run(file_rayinvr_par);
    % real y(2),f(2)
    run(file_rayinvr_com);

    sa = 1.0 .* sign(y(2));
    n1 = fix(sa.*y(2).*factan) + 1;
    f(1) = mcotan(n1).*y(2) + sa.*bcotan(n1);
    term1 = c(layer,iblk,3) + c(layer,iblk,4) .* x;
    term2 = x.*(c(layer,iblk,1)+c(layer,iblk,2).*x) + term1.*y(1) + c(layer,iblk,5);
    vxv = (x.*(c(layer,iblk,8)+c(layer,iblk,9).*x)+c(layer,iblk,10).*y(1)+c(layer,iblk,11)) ./ (term2.*(c(layer,iblk,6).*x+c(layer,iblk,7)));
    vzv = term1 ./ term2;
    f(2) = vzv - vxv .* f(1);
    return;
end

% --------------------------------------------------------------------------------

% rngkta.f
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

% --------------------------------------------------------------------------------

% trc.f
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
        y(1) = zr(npt) + (x - xr(npt)) ./ tan(ar(npt,2));
        y(2) = ar(npt,2);
    else
        if (fid .* ar(npt,2)) <= pi2
            x = x + smax ./ dstepf;
        else
            x = x - smax ./ dstepf;
        end
        y(1) = xr(npt) + tan(ar(npt,2)) .* (x - zr(npt));
        y(2) = ar(npt,2);
    end
    return;
end % function end

% --------------------------------------------------------------------------------

% trc.f
function [iflag,x,z] = fun_check(iflag,x,z)
% check that the new ray point will still be inside the current
% trapezoid; if not, adjust the step length so it falls 1 meter
% outside the trapezoid

    global file_rayinvr_par file_rayinvr_com;
    run(file_rayinvr_par);
    run(file_rayinvr_com);

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
            zt = amin1(z1,zt);
            zb = amax1(z3,zb);
        else
            zt = amin1(z2,zt);
            zb = amax1(z4,zb);
        end
        if z < zt, z = zt - 0.001; end
        if z > zb, z = zb + 0.001; end
    end
    return;
end % function end

% --------------------------------------------------------------------------------

% trc.f
function [ir,npt,xfr,zfr,ifrpt,iflagf] = fun_frefpt(ir,npt,xfr,zfr,ifrpt,iflagf)
% determine intersection point of ray with a floating reflector

    global file_rayinvr_par file_rayinvr_com;
    run(file_rayinvr_par);
    run(file_rayinvr_com);

    a1 = zr(npt-1) - zr(npt);
    b1 = xr(npt) - xr(npt-1);
    c1 = zr(npt-1).*xr(npt) - zr(npt).*xr(npt-1);

    for ii = 1:npfref(ifcbnd)-1 % 10
        a2 = zfrefl(ifcbnd,ii) - zfrefl(ifcbnd,ii+1);
        b2 = xfrefl(ifcbnd,ii+1) - xfrefl(ifcbnd,ii);
        c2 = zfrefl(ifcbnd,ii).*xfrefl(ifcbnd,ii+1) - zfrefl(ifcbnd,ii+1).*xfrefl(ifcbnd,ii);
        denom = b2.*a1 - b1.*a2;
        if denom ~= 0
            xfr = (b2.*c1 - b1.*c2) ./ denom;
            zfr = -(a2.*c1 - a1.*c2) ./ denom;
        else
            continue; % go to 10
        end
        iflag1 = 0;
        if xr(npt-1) ~= xr(npt)
            if (xfr>xr(npt-1) & xfr<=xr(npt)) | (xfr<xr(npt-1) & xfr>=xr(npt))
                iflag1 = 1;
            end
        else
            iflag1 = 1;
        end
        iflag2 = 0;
        if zr(npt-1) ~= zr(npt)
            if (zfr>zr(npt-1) & zfr<=zr(npt)) | (zfr<zr(npt-1) & zfr>=zr(npt))
                iflag2 = 1;
            end
        else
            iflag2 = 1;
        end
        iflag3 = 0;
        if xfrefl(ifcbnd,ii) ~= xfrefl(ifcbnd,ii+1)
            if (xfr>=xfrefl(ifcbnd,ii) & xfr<=xfrefl(ifcbnd,ii+1)) | (xfr<=xfrefl(ifcbnd,ii) & xfr>=xfrefl(ifcbnd,ii+1))
                iflag3 = 1;
            end
        else
            iflag3 = 1;
        end
        iflag4 = 0;
        if zfrefl(ifcbnd,ii) ~= zfrefl(ifcbnd,ii+1)
            if (zfr>=zfrefl(ifcbnd,ii) & zfr<=zfrefl(ifcbnd,ii+1)) | (zfr<=zfrefl(ifcbnd,ii) & zfr>=zfrefl(ifcbnd,ii+1))
                iflag4 = 1;
            end
        else
            iflag4 = 1;
        end

        if iflag1==1 & iflag2==1 & iflag3==1 & iflag4==1
            iflagf = 1;
            ifrpt = 1;
            break; % go to 999
        end
    end % 10

    % 999
    return;
end % function end

% --------------------------------------------------------------------------------

% adjpt.f
function [ir,n,xfr,zfr,ifrpt,modout,invr] = fun_frefl(ir,n,xfr,zfr,ifrpt,modout,invr)
% calculate angles of incidence and reflection at floating reflector

    global file_rayinvr_par file_rayinvr_com;
    global fID_32;
    run(file_rayinvr_par);
    run(file_rayinvr_com);

    d1 = ((xr(n-1)-xfr).^2 + (zr(n-1)-zfr).^2).^0.5;
    d2 = ((xr(n)-xfr).^2 + (zr(n)-zfr).^2).^0.5;
    if (d1+d2) == 0.0
        ar(n,1) = (ar(n-1,2)+ar(n,1)) ./ 2.0;
    else
        ar(n,1) = (d1.*ar(n,1) + d2.*ar(n-1,2)) ./ (d1+d2);
    end
    xr(n) = xfr;
    zr(n) = zfr;
    if ir>0 & modout == 1
        % fprintf(fID_32,'%10.3f%10.3f%10d\n',xfr,zfr);
    end
    slope = (zfrefl(ifcbnd,ifrpt+1)-zfrefl(ifcbnd,ifrpt)) ./ (xfrefl(ifcbnd,ifrpt+1)-xfrefl(ifcbnd,ifrpt));
    alphaalpha = atan(slope);
    a1 = fid .* (ar(n,1)+alphaalpha);
    a2 = a1;
    ar(n,2) = fid .* (pi-a2) - alphaalpha;
    vp(n,1) = vel(xr(n),zr(n));
    vs(n,1) = vp(n,1) .* vsvp(layer,iblk);
    vr(n,1) = vp(n,1);
    if iwave==-1, vr(n,1)=vs(n,1); end
    vr(n,2) = vr(n,1);
    vp(n,2) = vp(n,1);
    vs(n,2) = vs(n,1);
    if (fid .* ar(n,2) < 0.0)
        id = -id;
        fid = id; % fid = float(id)
    end
    if fid .* ar(n,2) > pi
        ar(n,2) = fid .* pit2 + ar(n,2);
        id = -id;
        fid = id; %fid = float(id)
    end
    idray(2) = 4;
    n2 = 0;
    n3 = 0;
    icasel = 5;
    dstepf = 1.0;
    nptbnd = n;
    nbnd = nbnd + 1;
    if npskp~=1, nbnda(nbnd)=n; end
    if ir ~= 0 & invr == 1
        [vr(n,1),a1,alphaalpha,n,ifrpt] = fun_frprt(vr(n,1),a1,alphaalpha,n,ifrpt);
    end
    return;
end % fun_frefl end

% --------------------------------------------------------------------------------

% inv.f
function [vfr,afr,alphaalpha,npt,ifrpt] = fun_frprt(vfr,afr,alphaalpha,npt,ifrpt)
% calculate partial derivatives for floating reflectors

    global file_rayinvr_par file_rayinvr_com;
    run(file_rayinvr_par);
    run(file_rayinvr_com);

    x1 = xfrefl(ifcbnd,ifrpt);
    x2 = xfrefl(ifcbnd,ifrpt+1);

    for ii = ifrpt:ifrpt+1 % 10
        if ivarf(ifcbnd,ii) > 0
            jv = ivarf(ifcbnd,ii);
            if x2-x1 ~= 0.0
                if ii == ifrpt
                    ind = ifrpt + 1;
                else
                    ind = ifrpt;
                end
                slptrm = cos(alphaalpha) .* abs(xfrefl(ifcbnd,ind)-xr(npt)) ./ (x2-x1);
            else
                slptrm = 1.0;
            end
            fpart(ninv,jv) = fpart(ninv,jv) + 2.0.*(cos(afr)./vfr).*slptrm;
        end
    end % 10
    return;

end % fun_frprt end

% --------------------------------------------------------------------------------

% inv.f
function [lu,iu,npt] = fun_velprt(lu,iu,npt)
% calculate velocity partial derivatives

    global file_rayinvr_par file_rayinvr_com;
    run(file_rayinvr_par);
    run(file_rayinvr_com);

    for jj = 1:4 % 10
        if ivv(lu,iu,jj) ~= 0
            jv = ivv(lu,iu,jj);
            sl = sqrt((xr(npt)-xr(npt-1)).^2 + (zr(npt)-zr(npt-1)).^2);
            v1 = vr(npt-1,2);
            v2 = vr(npt,1);
            dvj1 = (cv(lu,iu,jj,1).*xr(npt-1) + cv(lu,iu,jj,2).*xr(npt-1).^2 + ...
                cv(lu,iu,jj,3).*zr(npt-1) + cv(lu,iu,jj,4).*xr(npt-1).*zr(npt-1) + ...
                cv(lu,iu,jj,5)) ./ (c(lu,iu,6).*xr(npt-1) + c(lu,iu,7));
            dvj2 = (cv(lu,iu,jj,1).*xr(npt) + cv(lu,iu,jj,2).*xr(npt).^2 + ...
                cv(lu,iu,jj,3).*zr(npt) + cv(lu,iu,jj,4).*xr(npt).*zr(npt) + ...
                cv(lu,iu,jj,5)) ./ (c(lu,iu,6).*xr(npt) + c(lu,iu,7));
            dvv2 = (dvj1 ./ v1.^2 + dvj2 ./ v2.^2) ./ 2.0;
            fpart(ninv,jv) = fpart(ninv,jv) - sl.*dvv2;
        end
    end % 10
    return;
end % fun_velprt end

% --------------------------------------------------------------------------------

% rngkta.f
function [x,z,y,f,h,hmin,e,func,g,s,t] = fun_rngkta(x,z,y,f,h,hmin,e,func,g,s,t)
% routine to solve a 2x2 system of first order o.d.e.'s
% using the runge-kutta method with error control
% func 是一个函数参数

    % real y(2),f(2),t(2),s(2),g(2)
    % logical*1 be,bh,br,bx
    % logical bxx
    % common /rkcs/ bxx

    bh = true;
    br = true;
    bx = true;
    bxx = true;
    if z > x & h < 0.0, h = -h; end
    if z < x & h > 0.0, h = -h; end

    isGoto10 = true;
    while isGoto10 % -------------------- circle 10 begin
    isGoto10 = false;
    % 10
    xs = x;

    g(1) = y(1);
    g(2) = y(2);

    isGoto20 = true;
    while isGoto20 % -------------------- circle 20 begin
    isGoto20 = false;

    % 20
    hs = h;
    q = x + h - z;
    be = true;
    if (h>0.0 & q>=0.0) | (h<0.0 & q<=0.0)
        h = z - x;
        br = false;
    end
    h3 = h ./ 3;

    % call func(x,y,f)
    [x,y,f] = func(x,y,f);

    for ii = 1:2 % 210
        q = h3 .* f(ii);
        t(ii) = q;
        r = q;
        y(ii) = g(ii) + r;
    end % 210
    x = x + h3;

    [x,y,f] = func(x,y,f);

    for ii = 1:2 %220
        q = h3 .* f(ii);
        r = 0.5 .* (q+t(ii));
        y(ii) = g(ii) + r;
    end %220

    [x,y,f] = func(x,y,f);

    for ii = 1:2 %230
        q = h3 .* f(ii);
        r = 3.0 .* q;
        s(ii) = r;
        r = 0.375 .* (r+t(ii));
        y(ii) = g(ii) + r;
    end %230
    x = x + 0.5 .* h3;

    [x,y,f] = func(x,y,f);

    for ii = 1:2 % 240
        q = h3 .* f(ii);
        r = t(ii) + 4.0 .* q;
        t(ii) = r;
        r = 1.5 .* (r-s(ii));
        y(ii) = g(ii) + r;
    end % 240
    x = x + 0.5.*h;

    [x,y,f] = func(x,y,f);

    for ii = 1:2 % 250
        q = h3 .* f(ii);
        r = 0.5 .* (q+t(ii));
        q = abs(r+r-1.5.*(q+s(ii)));
        y(ii) = g(ii) + r;
        r = abs(y(ii));
        if r < 0.001
            r = e;
        else
            r = e .* r;
        end
        if q >= r & bx
            br = true;
            bh = false;
            h = 0.5 .* h;
            if abs(h) < hmin
                sigh = 1.0;
                if h < 0.0, sigh=-1.0; end
                h = sigh .* hmin;
                bx = false;
                bxx = false;
            end
            y(1) = g(1);
            y(2) = g(2);
            x = xs;
            % go to 20
            isGoto20 = true; break;
        end
        if q>=0.03125.*r, be=false; end
    end % 250
    end % -------------------- circle 20 end

    if be & bh & br
        h = h + h;
        bx = true;
    end
    bh = true;
    if br
        % go to 10
        isGoto10 = true;
    end
    end % -------------------- circle 10 end

    h = hs;
    return;

end % fun_rngkta end

% --------------------------------------------------------------------------------

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