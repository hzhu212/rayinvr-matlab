% adjpt.f
% []
% called by: fun_adjpt; fun_trace;
% call: fun_frprt; fun_vel; done.

function fun_frefl(ir,n,xfr,zfr,ifrpt,modout,invr)
% calculate angles of incidence and reflection at floating reflector
% 计算射线遇到浮动界面时的入射角与反射角

% ir: 射线方向，1-向右，-1-向左
% n: 当前节点编号。背景条件是：当前射线在 n-1 ~ n 段与浮动界面相交
% xfr,zfr: 交点的 x,z 坐标

    global fID_32;
    global ar_ dstepf fid ifcbnd id iblk iwave idray icasel layer n2 n3 ...
        nbnd nptbnd npskp nbnda pit2 vp vr vs vsvp xr xfrefl zr zfrefl;

    % d1,d2: 分别为交点前后两个线段的长度
    d1 = ((xr(n-1)-xfr).^2 + (zr(n-1)-zfr).^2).^0.5;
    d2 = ((xr(n)-xfr).^2 + (zr(n)-zfr).^2).^0.5;
    if (d1+d2) == 0.0
        ar_(n,1) = (ar_(n-1,2)+ar_(n,1)) ./ 2.0;
    else
        ar_(n,1) = (d1.*ar_(n,1) + d2.*ar_(n-1,2)) ./ (d1+d2);
    end
    % 将第 n 个节点的位置挪到交点处
    xr(n) = xfr;
    zr(n) = zfr;
    if ir > 0 && modout == 1
        fprintf(fID_32,'%10.3f%10.3f%10d\n',xfr,zfr);
    end
    % 浮动界面在交点处的坡度
    slope = (zfrefl(ifcbnd,ifrpt+1)-zfrefl(ifcbnd,ifrpt)) ./ (xfrefl(ifcbnd,ifrpt+1)-xfrefl(ifcbnd,ifrpt));
    % 坡度对应的坡角
    alpha_ = atan(slope);
    a1 = fid .* (ar_(n,1)+alpha_);
    a2 = a1;
    ar_(n,2) = fid .* (pi-a2) - alpha_;
    vp(n,1) = fun_vel(xr(n),zr(n), c,iblk,layer);
    vs(n,1) = vp(n,1) .* vsvp(layer,iblk);
    vr(n,1) = vp(n,1);
    if iwave==-1, vr(n,1)=vs(n,1); end
    vr(n,2) = vr(n,1);
    vp(n,2) = vp(n,1);
    vs(n,2) = vs(n,1);
    if (fid .* ar_(n,2) < 0.0)
        id = -id;
        fid = id; % fid = float(id)
    end
    if fid .* ar_(n,2) > pi
        ar_(n,2) = fid .* pit2 + ar_(n,2);
        id = -id;
        fid = id; % fid = float(id)
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
        fun_frprt(vr(n,1),a1,alpha_,n,ifrpt);
    end
    return;
end % fun_frefl end
