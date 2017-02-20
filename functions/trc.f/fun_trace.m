% trc.f
% [npt,~,~,~,~,~,iflag,~,~,~,~,~,~]
% called by: main; fun_autotr;
% call: fun_strait; fun_check; fun_rngkta; fun_rkdumb; fun_odex; fun_odexfi;
% fun_velprt; fun_odez; fun_odezfi; fun_frefpt; fun_frefl; fun_adjpt; fun_hdwave;
% done.

function [npt,ifam,ir,iturn,invr,xsmax,iflag,idl,idr,iray,ii2pt,i1ray,modout] = fun_trace(npt,ifam,ir,iturn,invr,xsmax,iflag,idl,idr,iray,ii2pt,i1ray,modout)
% trace a single ray through the model

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