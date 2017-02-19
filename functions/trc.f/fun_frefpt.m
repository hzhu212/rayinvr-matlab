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