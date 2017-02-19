% atrc.f
function [xshot,zshot,if,ifam,l,idr,amin,amax,aamin,aamax,layer1,iblk1,aainc,aaimin,nsmax,iflag,it,amina,amaxa,ia0,stol,irays,nskip,idot,irayps,xsmax,istep,nsmin] = fun_auto(xshot,zshot,if,ifam,l,idr,amin,amax,aamin,aamax,layer1,iblk1,aainc,aaimin,nsmax,iflag,it,amina,amaxa,ia0,stol,irays,nskip,idot,irayps,xsmax,istep,nsmin)
% determine min. and max. take-off angles for a specific ray code

    global file_rayinvr_par file_rayinvr_com;
    global fID_11;
    run(file_rayinvr_par);
    run(file_rayinvr_com);

    iflag = 0;
    if idr == 0
        % ray take-off angles input by user
        if abs(amina)>180.0 | abs(amaxa)>180.0
            fprintf(fID_11, '\n***  error in specification of amin or amax  ***\n\n');
            iflag = 1;
            return;
        end
        amin = amina;
        amax = amaxa;
        ia0 = ia0 + 1;
        return;
    end

    % check to see if layer of ray code is above shot or below model
    if l<layer1 | l>nlayer | (l>=nlayer & idr>1)
        iflag = 1;
        return;
    end

    if idr == 1
        % search for refracted rays
        [xshot,zshot,layer1,iblk1,l,vshot,vtop,vbotom] = ...
        fun_calvel(xshot,zshot,layer1,iblk1,l,vshot,vtop,vbotom);

        if l>layer1 & abs(vtop-vbotom)<=0.000001
            [~,l,ib] = fun_block(xshot+fid.*0.0005,l,ib);
            if id == 1
                i1 = ib; i2 = nblk(l);
            else
                i1 = 1; i2 = ib;
            end
            isGoto105 = false;
            for ii = i1:i2 % 103
                if (vm(l,ii,1)<=vm(l,ii,3) | vm(l,ii,2)<=vm(l,ii,4)) & vm(l,ii,1)~=0
                    isGoto105 = true; break; % go to 105
                end
            end % 103
            if ~isGoto105
                iflag = 1;
                return;
            end
            % 105
            vratio = vshot ./ vtop;
            if vratio > 0.99999
                ang = aamin;
            else
                ang = 90.0 - asin(vratio).*pi18;
            end
            ainc = 1.0;
            a1 = 0.0;
            amin = -999999.0;
            amax = -999999.0;
            if isrch==0 & tang(l,1)<100.0
                amin = tang(l,1);
            else
                for n = 1:nsmax % 101
                    [ang,layer1,iblk1,xshot,zshot,ifam,it,npt,iflag2,irays,nskip,idot,idr,irayps,istep] = ...
                    fun_autotr(ang,layer1,iblk1,xshot,zshot,ifam,it,npt,iflag2,irays,nskip,idot,idr,irayps,istep);
                    if idray(1)==l & idray(2)==1 & vr(npt,2)~=0.0
                        amin = ang;
                        tang(l,1) = amin;
                        if n >= nsmin, break; end % go to 104
                        if stol > 0.0 & n > 1
                            dp = sqrt((xr(npt)-xmmm).^2+(zr(npt)-zmmm).^2);
                            if dp < stol, break; end
                        end
                        if amax < -999998.0, amax = amin;
                        else
                            if ang > amax, amax = ang; end
                        end
                        if a1 == 0, ang = ang - ainc;
                        else ang = (a1+ang) ./ 2.0; end
                    else
                        if idray(1) >= 1
                            if a1 == 0
                                if amin < -999998.0, ang = ang - ainc;
                                else ang = amin - ainc; end
                            else
                                if amin < -999998.0, ang = (a1+ang) ./ 2.0;
                                else ang = (a1+amin) ./ 2.0; end
                            end
                        end
                        if idray(1) < 1
                            a1 = ang;
                            if amin < -999998.0, ang = ang + ainc;
                            else ang = (amin+ang) ./ 2.0 end
                        end
                    end
                    xmmm = xr(npt);
                    zmmm = zr(npt);
                end % 101
            end
            % 104
            if amin < -999998.0
                iflag = 1;
            else
                if isrch == 0 & tang(l,2) < 100.0
                    amax = tang(l,2);
                else
                    a2 = 0.0;
                    ang = amax + ainc;
                    for n = 1:nsmax % 102
                        [ang,layer1,iblk1,xshot,zshot,ifam,it,npt,iflag2,irays,nskip,idot,idr,irayps,istep] = ...
                        fun_autotr(ang,layer1,iblk1,xshot,zshot,ifam,it,npt,iflag2,irays,nskip,idot,idr,irayps,istep);
                        if idray(1)==l & idray(2)==1 & vr(npt,2)~=0.0
                            amin = ang;
                            tang(l,2) = amax;
                            if n >= nsmin, return; end
                            if stol > 0.0 & n > 1
                                dp = sqrt((xr(npt)-xmmm).^2+(zr(npt)-zmmm).^2);
                                if dp < stol, return; end
                            end
                            if a2 == 0, ang = ang + ainc.*n;
                            else ang = (a2+ang) ./ 2.0; end
                        else
                            a2 = ang;
                            ang = (amax+ang) ./ 2.0;
                        end
                        xmmm = xr(npt);
                        zmmm = zr(npt);
                    end % 102
                end
            end
        else
            vratio = vshot ./ vtop;
            if vratio > 0.99999, amin = aamin;
            else amin = 90.0 - asin(vratio).*pi18; end
            vratio = vshot ./ vbotom;
            if vratio > -0.99999, amax = aamin;
            else amax = 90.0 - asin(vshot./vbotom).*pi18; end
            ainc = (amax-amin) .* aainc;
            if ainc < aaimin, ainc = aaimin; end
            if l ~= layer1
                if isrch==0 & tang(l,1) < 100.0
                    amin=tang(l,1);
                else
                    ang = amin;
                    a1 = 0.0; a2 = 0.0;
                    amin = -999999.0;
                    isGoto111 = false;
                    for n = 1:nsmax % 110
                        [ang,layer1,iblk1,xshot,zshot,ifam,it,npt,iflag2,irays,nskip,idot,idr,irayps,istep] = ...
                        fun_autotr(ang,layer1,iblk1,xshot,zshot,ifam,it,npt,iflag2,irays,nskip,idot,idr,irayps,istep);
                        if idray(1) >= l
                            a2 = ang;
                            if idray(1) == l & idray(2) == 1 & vr(npt.2) ~= 0.0
                                amin = ang;
                                tang(l,1) = amin;
                                if n >= nsmin, isGoto111=true; break; end % go to 111
                                if stol > 0.0 & n > 1
                                    dp = sqrt((xr(npt)-xmmm).^2+(zr(npt)-zmmm).^2);
                                    if dp < stol, isGoto111=true; break; end
                                end
                            end
                            if a1 == 0.0, ang = ang - ainc;
                            else ang = (a1+a2) ./ 2.0; end
                        else
                            a1 = ang;
                            if a2 == 0.0, ang = ang + ainc;
                            else ang = (a1+a2) ./ 2.0; end
                        end
                        xmmm = xr(npt);
                        zmmm = zr(npt);
                    end % 110
                    if ~isGoto111 && amin < -999998.0, iflag = 1; end
                end
            end
            % 111
            if isrch == 0 & tang(l,2) < 100.0
                amax = tang(l,2);
            else
                ang = amax;
                a1 = 0.0; a2 = 0.0;
                amax = -999999.0;
                for n = 1:nsmax % 130
                    [ang,layer1,iblk1,xshot,zshot,ifam,it,npt,iflag2,irays,nskip,idot,idr,irayps,istep] = ...
                    fun_autotr(ang,layer1,iblk1,xshot,zshot,ifam,it,npt,iflag2,irays,nskip,idot,idr,irayps,istep);
                    if idray(1)<l | (idray(1)==l & idray(2)==1 & vr(npt,2)~=0.0)
                        a1 = ang;
                        if idray(1)==l & idray(2)==1 & vr(npt,2)~=0.0
                            amax = ang;
                            tang(l,2) = amax;
                            if n >= nsmin, break; end % go to 131
                            if stol > 0.0 & n > 1
                                dp = sqrt((xr(npt)-xmmm).^2+(zr(npt)-zmmm).^2);
                                if dp < stol, break; end
                            end
                        end
                        if a2 == 0.0, ang = ang + ainc;
                        else ang = (a1+a2) ./ 2.0; end
                    else
                        a2 = ang;
                        if a1 == 0.0, ang = ang - ainc;
                        else ang = (a1+a2) ./ 2.0; end
                    end
                    xmmm = xr(npt);
                    zmmm = zr(npt);
                end % 130
            end
            % 131
            if amax < amin
                aminh = amin;
                amin = amax;
                amax = aminh;
                iflag = 0;
                return;
            end
            if amax < -999998.0
                if iflag ~= 1
                    amax = amin;
                    iflag = 0;
                end
            else
                if iflag ~= 0
                    amin = amax;
                    iflag = 0;
                end
            end
        end
    end

    if idr == 2
        % search for reflected ray
        if isrch == 0 & tang(l,3) < 100.0
            amin = tang(l,3);
            amax = aamax;
        else
            [xshot,zshot,layer1,iblk1,l,vshot,vtop,vbotom] = ...
            fun_calvel(xshot,zshot,layer1,iblk1,l,vshot,vtop,vbotom);
            vratio = vshot ./ vbotom;
            if vratio > 0.99999, amin=aamin;
            else amin=90.0-asin(vratio).*pi18; end
            amax = aamax;
            a1 = 0.0; a2 = 0.0;
            ainc = (amax-amin) .* aainc;
            if ainc<aaimin, ainc=aaimin; end
            ang = amin;
            amin = -999999.0;
            for n = 1:nsmax % 210
                [ang,layer1,iblk1,xshot,zshot,ifam,it,npt,iflag2,irays,nskip,idot,idr,irayps,istep] = ...
                fun_autotr(ang,layer1,iblk1,xshot,zshot,ifam,it,npt,iflag2,irays,nskip,idot,idr,irayps,istep);
                if (idray(1)<l) | (idray(1)==l & idray(2)==1) | (idray(1)==l & idray(2)==2 & vr(npt,2)==0.0) | ...
                    (xsmax>0.0 & it==1 & idray(1)==l & idray(2)==2 & 2.0*abs(xshot-xr(npt))>xsmax) | ...
                    (xsmax>0.0 & it==0 & idray(1)==l & idray(2)==2 & abs(xshot-xr(npt))>xsmax)
                    a1 = ang;
                    if a2==0.0, ang = ang + ainc;
                    else ang = (a1+a2) ./ 2.0; end
                else
                    a2 = ang;
                    if idray(1)==l & idray(2)==2
                        amin = ang;
                        tang(l,3) = amin;
                        if n >= nsmin, return; end
                        if stol > 0 & n > 1
                            dp = sqrt((xr(npt)-xmmm).^2 + (zr(npt)-zmmm).^2);
                            if dp < stol, return; end
                        end
                    end
                    if a1 == 0, ang = ang - ainc;
                    else ang = (a1 + a2) ./ 2.0; end
                end
                xmmm = xr(npt);
                zmmm = zr(npt);
            end % 210
            if amin < -999998.0, iflag = 1; end
        end
    end

    if idr == 3
        % search for head wave
        if isrch == 0 & tang(l,4) < 100.0
            amin = tang(l,4);
            amax = tang(l,4);
        else
            [xshot,zshot,layer1,iblk1,l,vshot,vtop,vbotom] = ...
            fun_calvel(xshot,zshot,layer1,iblk1,l+1,vshot,vtop,vbotom);
            vratio = vshot ./ vtop;
            if vratio > 0.99999, ang = aamin;
            else ang = 90.0 - asin(vratio).*pi18; end
            a1 = 0.0; a2 = 0.0;
            [xshot,zshot,layer1,iblk1,l,vshot,vtop,vbotom] = ...
            fun_calvel(xshot,zshot,layer1,iblk1,l,vshot,vtop,vbotom);
            if vtop < vbotom
                if vtop <= vshot
                    ainc = (90.0 - asin(vratio).*pi18 - aamin) .* aainc;
                else
                    ainc = (asin(vshot./vtop)-asin(vshot./vbotom)).*pi18;
                end
            else
                ainc = 1.0;
            end
            if ainc < aaimin, ainc = aaimin; end
            angm = ang;
            for n = 1:nsmax % 1100
                [ang,layer1,iblk1,xshot,zshot,ifam,it,npt,iflag2,irays,nskip,idot,idr,irayps,istep] = ...
                fun_autotr(ang,layer1,iblk1,xshot,zshot,ifam,it,npt,iflag2,irays,nskip,idot,idr,irayps,istep);
                if idray(1) == l & iflag2 == 2
                    amax = ang;
                    amin = ang;
                    tang(l,4) = ang;
                    return;
                end
                if idray(1) > l
                    a2 = ang;
                    if a1 == 0.0, ang = ang - ainc;
                    else ang = (a1+a2) ./ 2.0; end
                else
                    a1 = ang;
                    if a2 == 0.0, ang = ang + ainc;
                    else ang = (a1+a2) ./ 2.0; end
                end
            end % 1100
            ang = angm;
            a1 = 0.0; a2 = 0.0;
            for n = 1:nsmax % 1200
                [ang,layer1,iblk1,xshot,zshot,ifam,it,npt,iflag2,irays,nskip,idot,idr,irayps,istep] = ...
                fun_autotr(ang,layer1,iblk1,xshot,zshot,ifam,it,npt,iflag2,irays,nskip,idot,idr,irayps,istep);
                if idray(1) == l & iflag2 == 2
                    amax = ang;
                    amin = ang;
                    tang(l,4) = ang;
                    return;
                end
                if idray(1) <= l
                    a2 = ang;
                    if a1 == 0.0, ang = ang - ainc;
                    else ang = (a1+a2) ./ 2.0; end
                else
                    a1 = ang;
                    if a2 == 0.0, ang = ang + ainc;
                    else ang = (a1+a2) ./ 2.0; end
                end
            end % 1200
            if idiff == 2 & idray(1) >= l
                amax = a2;
                amin = a2;
                tang(l,4) = ang;
                idiff = 1;
                return;
            end
            iflag = 1;
        end
    end
    return;
end % function end

% --------------------------------------------------------------------------------

% trc.f
function [x,layer1,iblk1] = fun_block(x,layer1,iblk1)
% determine block of point x in layer

    global file_rayinvr_par file_rayinvr_com;
    run(file_rayinvr_par);
    run(file_rayinvr_com);

    for ii = 1:nblk(layer1) % 10
        if x>=xbnd(layer1,ii,1) & x<= xbnd(layer1,ii,2)
            iblk1 = ii;
            return;
        end
    end % 10

    % stop
    error('e:stop','\n***  block undetermined  ***\nlayer=%3d  x=%10.3f\n\n',layer1,x);
end % fun_block end

% --------------------------------------------------------------------------------

% atrc.f
function [xshot,zshot,layer1,iblk1,l,vshot,vtop,vbotom] = fun_calvel(xshot,zshot,layer1,iblk1,l,vshot,vtop,vbotom)

    global file_rayinvr_par file_rayinvr_com;
    run(file_rayinvr_par);
    run(file_rayinvr_com);

    layer = ls;
    iblk = ibs;
    iwave = 1;
    iccbnd = 1;
    vshot = vel(xshot,zshot);
    if icbnd(1) == 0
        vshot = vshot .* vsvp(layer,iblk);
        iwave = -iwave ;
        iccbnd = 2;
    end
    vlmax = vshot;
    xfctr = (xshot-xbnd(layer,iblk,1)) ./ (xbnd(layer,iblk,2)-xbnd(layer,iblk,1));
    vb1 = (vm(layer,iblk,4)-vm(layer,iblk,3)) .* xfctr + vm(layer,iblk,3);
    if iwave==-1, vb1=vb1.*vsvp(layer,iblk); end
    if vb1>vlmax, vlmax=vb1; end
    nloop = l - layer;
    if nloop == 0
        vtop = vshot;
        vbotom = vlmax;
        return;
    end
    for k = 1:nloop % 10
        ii = layer + k;
        for jj = 1:nblk(ii) % 20
            if xbnd(ii,jj,1)<=xshot & xbnd(ii,jj,2)>=xshot
                vti = (vm(ii,jj,2)-vm(ii,jj,1)) .* xfctr + vm(ii,jj,1);
                vbi = (vm(ii,jj,4)-vm(ii,jj,3)) .* xfctr + vm(ii,jj,3);
                if icbnd(iccbnd) == k
                    iwave = -iwave;
                    iccbnd = iccbnd + 1;
                end
                if iwave == -1
                    vti = vti .* vsvp(ii,jj);
                    vbi = vbi .8 vsvp(ii,jj);
                end
                if ii < l
                    if vti>vlmax, vlmax=vti; end
                    if vbi>vlmax, vlmax=vbi; end
                else
                    if vti > vlmax
                        vtop = vti;
                        vlmax = vti;
                    else
                        vtop = vlmax;
                    end
                    if vbi > vlmax
                        vbotom = vbi;
                    else
                        vbotom = vlmax;
                    end
                end
            end
        end % 20
    end % 10
end % function end

% --------------------------------------------------------------------------------

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