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