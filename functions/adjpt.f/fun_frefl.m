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
    alpha = atan(slope);
    a1 = fid .* (ar(n,1)+alpha);
    a2 = a1;
    ar(n,2) = fid .* (pi-a2) - alpha;
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
        [vr(n,1),a1,alpha,n,ifrpt] = fun_frprt(vr(n,1),a1,alpha,n,ifrpt);
    end
    return;
end % fun_frefl end