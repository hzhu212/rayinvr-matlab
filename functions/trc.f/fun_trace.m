% trc.f
% [npt,~,~,~,~,~,iflag,~,~,~,~,i1ray,~]
% called by: main; fun_autotr;
% call: fun_strait; fun_check; fun_rngkta; fun_rkdumb; fun_odex; fun_odexfi;
% fun_velprt; fun_odez; fun_odezfi; fun_frefpt; fun_frefl; fun_adjpt; fun_hdwave;
% fun_dstep; fun_vel; done.

function [npt,ifam,ir,iturn,invr,xsmax,iflag,idl,idr,iray,ii2pt,i1ray,modout] = fun_trace(npt,ifam,ir,iturn,invr,xsmax,iflag,idl,idr,iray,ii2pt,i1ray,modout)
% trace a single ray through the model

    % global file_rayinvr_par file_rayinvr_com;
    % global fID_11 fID_12;
    % run(file_rayinvr_par);
    % run(file_rayinvr_com);

    global fID_11 fID_12;
    global ar_ b dstepf fid hdenom hmin iblk ivg ifcbnd idray iwave idump ...
        id ifast isrkc icasel ihdw layer ntray ntpts n2 n3 nptbnd pi2 pi4 pi18 ...
        ppray pi34 ray s smax tol vr vp vs vsvp xr xbnd zr;

    % external odex,odez,odexfi,odezfi
    % real y(2),f(2),w1(2),w2(2),w3(2),left

    [xfr,zfr,ifrpt] = deal([]); % for fun_frefpt
    [lstart,istart] = deal([]); % for fun_adjpt

    ntray = ntray + 1;
    dstepf = 1.0;
    n2 = 0; n3 = 0;
    iflag = 0;
    if ivg(layer,iblk) > 0
        hn = fun_dstep(xr(npt),zr(npt)) ./ hdenom;
    else
        hn = smax ./ hdenom;
    end
    hminn = hn .* hmin;

    % 1000 % -------------------- circle 1000 begin
    cycle1000 = true;
    while cycle1000
        if idump == 1
            fprintf(fID_12,'%2d%3d%4d%8.3f%8.3f%8.2f%8.2f%7.2f%7.2f%3d%3d%3d%3d\n',...
                ifam,ir,npt,xr(npt),zr(npt),ar_(npt,1).*pi18,ar_(npt,2).*pi18,...
                vr(npt,1),vr(npt,2),layer,iblk,id,iwave); % 5
        end
        if iwave == -1 && vr(npt,2) <= 0.001
            vr(npt,2) = 0.0;
            iflag = 1;
            if ir ~= 0
                % 25
                fprintf(fID_11,'***  ray stopped - s-wave cannot propagate  ***\n');
            end
            [~,~,~,vr,~,iflag,ntpts] = fun_goto900(ifcbnd,idray,ii2pt,vr,npt,iflag,ntpts);
            return; % go to 900
        end
        if npt > 1
            if ((ar_(npt,2) - fid.*pi2) .* (ar_(npt-1,2) - fid.*pi2)) <= 0.0
                if iturn ~= 0
                    [~,~,~,vr,~,iflag,ntpts] = fun_goto900(ifcbnd,idray,ii2pt,vr,npt,iflag,ntpts);
                    return; % go to 900
                end
            end
        end

        isrkc = 1;
        if (fid .* ar_(npt,2)) >= pi4 && (fid .* ar_(npt,2)) <= pi34
            % solve o.d.e.'s w.r.t. x

            x = xr(npt);
            y(1) = zr(npt);
            y(2) = ar_(npt,2);

            if ivg(layer,iblk) == 0
                [x,y,~,~] = fun_strait(x,y,npt,0);
            else
                z = x + fid .* fun_dstep(xr(npt),zr(npt)) ./ dstepf;
                [~,z,zr(npt)] = fun_check(0,z,zr(npt));

                if ifast == 0
                    odex = @ fun_odex;
                    [x,~,y,f,hn,~,~,~,w1,w2,w3] = fun_rngkta(x,z,y,f,hn,hminn,tol,odex,w1,w2,w3);
                else
                    odexfi = @ fun_odexfi;
                    [y,~,~,~] = fun_rkdumb(y,x,z,odexfi);
                    x = z;
                end
            end
            if npt == ppray
                [vr,iflag,~,~,~,~,~,~,ntpts] = fun_goto999(vr,iflag,ir,fID_11,ifcbnd,idray,ii2pt,npt,ntpts);
                return; % go to 999
            end
            npt = npt + 1;
            xr(npt) = x;
            zr(npt) = y(1);

        else
            % solve o.d.e.'s w.r.t. z

            x = zr(npt);
            y(1) = xr(npt);
            y(2) = ar_(npt,2);

            if ivg(layer,iblk) == 0
                [x,y,~,~] = fun_strait(x,y,npt,1);
            else
                if (fid.*ar_(npt,2)) <= pi2
                    z = x + fun_dstep(xr(npt),zr(npt)) ./ dstepf;
                else
                    z = x - fun_dstep(xr(npt),zr(npt)) ./ dstepf;
                end

                [~,xr(npt),z] = fun_check(1,xr(npt),z);

                if ifast == 0
                    odez = @ fun_odez;
                    [x,~,y,f,hn,~,~,~,w1,w2,w3] = fun_rngkta(x,z,y,f,hn,hminn,tol,odez,w1,w2,w3);
                else
                    odezfi = @ fun_odezfi;
                    [y,~,~,~] = fun_rkdumb(y,x,z,odezfi);
                    x = z;
                end
            end
            if npt == ppray
                [vr,iflag,~,~,~,~,~,~,ntpts] = fun_goto999(vr,iflag,ir,fID_11,ifcbnd,idray,ii2pt,npt,ntpts);
                return; % go to 999
            end
            npt = npt + 1;
            xr(npt) = y(1);
            zr(npt) = x;
        end

        ar_(npt,1) = y(2);
        ar_(npt,2) = y(2);
        vp(npt,1) = fun_vel(xr(npt),zr(npt));
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
        if ifcbnd > 0
            if nptbnd == 0 || icasel ~= 5
                [~,~,xfr,zfr,ifrpt,iflagf] = fun_frefpt(ir,npt,xfr,zfr,ifrpt,iflagf);
            end
        end

        top = s(layer,iblk,1) .* xr(npt) + b(layer,iblk,1);
        bottom = s(layer,iblk,2) .* xr(npt) + b(layer,iblk,2);
        left = xbnd(layer,iblk,1);
        right = xbnd(layer,iblk,2);

        if zr(npt)>top && zr(npt)<=bottom && xr(npt)>left && xr(npt)<=right
            if iflag == 1
                [~,~,~,~,~,~,~] = fun_frefl(ir,npt,xfr,zfr,ifrpt,modout,invr);
            end
            if ir~=0 && invr==1
                [~,~,~] = fun_velprt(layer,iblk,npt);
            end
            dstepf = 1.0;
            continue; % go to 1000
        else
            nptin = npt;
            [npt,top,bottom,~,~,~,~,~,lstart,istart,~,iflag,~,~,~,~,~,~,~] ...
            = fun_adjpt(npt,top,bottom,left,right,ifam,ir,iturn,lstart,istart,invr,iflag,idl,idr,xfr,zfr,ifrpt,iflagf,modout);

            if ir~=0 && invr==1 && nptin==npt
                [~,~,~] = fun_velprt(lstart,istart,npt);
            end

            if ihdw==1 & (ir~=0 | ii2pt>0)
                [~,~,npt,~,~,iflag,i1ray,~] = fun_hdwave(ifam,ir,npt,invr,xsmax,iflag,i1ray,modout);
            end

            if iflag==0, continue; end % go to 1000
        end

        break; % go to nothing
    end % -------------------- circle 1000 end

    [~,~,~,vr,~,iflag,ntpts] = fun_goto900(ifcbnd,idray,ii2pt,vr,npt,iflag,ntpts);
    return; % go to 900

end % function end


% 900
% [~,~,~,vr,~,iflag,ntpts]
function [ifcbnd,idray,ii2pt,vr,npt,iflag,ntpts] = fun_goto900(ifcbnd,idray,ii2pt,vr,npt,iflag,ntpts)

    if ifcbnd > 0 && idray(2) ~= 4 && ii2pt == 2
        vr(npt,2) = 0.0;
        iflag = 1;
    end
    ntpts = ntpts + npt;
    return;
end

% 999
% [vr,iflag,~,~,~,~,~,~,ntpts]
function [vr,iflag,ir,fID_11,ifcbnd,idray,ii2pt,npt,ntpts] = fun_goto999(vr,iflag,ir,fID_11,ifcbnd,idray,ii2pt,npt,ntpts)

    vr(500,2) = 0.0;
    iflag = 1;
    if ir ~= 0
        fprintf(fID_11,'***  ray stopped - consists of too many points  ***\n'); % 15
    end
    if ifcbnd > 0 && idray(2) ~= 4 && ii2pt == 2
        vr(npt,2) = 0.0;
        iflag = 1;
    end
    ntpts = ntpts + npt;
    return;
end