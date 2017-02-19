% atrc.f

function [ang,layer1,iblk1,xshot,zshot,ifam,iturn,npt,iflag2,irays,nskip,idot,idr,irayps,istep] = fun_autotr(ang,layer1,iblk1,xshot,zshot,ifam,iturn,npt,iflag2,irays,nskip,idot,idr,irayps,istep)
% trace a single ray through model to its turning point
% (iturn=1) or to completion (iturn=0)

    global file_rayinvr_par file_rayinvr_com;
    global fID_12;
    run(file_rayinvr_par);
    run(file_rayinvr_com);

    ircbnd = 1;
    iccbnd = 1;
    iwave = 1;
    if icbnd(1) == 0
        iwave = -iwave;
        iccbnd = 2;
    end
    nptbnd = 0;
    nbnd = 0;
    npskp = npskip;
    nccbnd = 0;
    id = nint(fid1);
    fid = fid1;
    ir = 0;
    invr = 0;
    angle = fid .* (90.0 - ang) ./ pi18;
    layer = layer1;
    iblk = iblk1;
    npt = 1;
    xr(1) = xshot;
    zr(1) = zshot;
    ar(1,1) = 0.0;
    ar(1,2) = angle;
    vr(1,1) = 0.0;
    vp(1,1) = 0.0;
    vs(1,1) = 0.0;
    vp(1,2) = vel(xshot,zshot);
    vs(1,2) = vp(1,2) .* vsvp(layer1,iblk1);
    if iwave == 1
        vr(1,2) = vp(1,2);
    else
        vr(1,2) = vs(1,2);
    end if
    idray(1) = layer1;
    idray(2) = 1;
    ifcbnd = 0;

    [npt,ifam,ir,iturn,invr,~,iflag2,~,idr,~,~,~,~] = ...
    fun_trace(npt,ifam,ir,iturn,invr,0.,iflag2,0,idr,0,0,0,0);

    if irays == 1
        % call pltray(npt,nskip,idot,irayps,istep,ang)
    end

    if idump == 1
        fprintf(fID_12,'%2d%3d%4d%8.3f%8.3f%8.2f%8.2f%7.2f%7.2f%3d%3d%3d%3d\n',...
            ifam,ir,npt,xr(npt),zr(npt),ar(npt,1).*pi18,ar(npt,2).*pi18,...
            vr(npt,1),vr(npt,2),layer,iblk,id,iwave);
    end

    return;
end % function end