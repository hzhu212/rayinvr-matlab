% trc.f
% old: [npt,~,~,~,~,~,iflag,~,~,~,~,i1ray,~] = fun_trace(npt,ifam,ir,iturn,invr,xsmax,iflag,idl,idr,iray,ii2pt,i1ray,modout)
% [npt,iflag,i1ray]
% called by: main; fun_autotr;
% call: fun_strait; fun_check; fun_rngkta; fun_rkdumb; fun_odex; fun_odexfi;
% fun_velprt; fun_odez; fun_odezfi; fun_frefpt; fun_frefl; fun_adjpt; fun_hdwave;
% fun_dstep; fun_vel; done.

function [npt,iflag,i1ray] = fun_trace(npt,ifam,ir,iturn,invr,xsmax,idl,idr,iray,ii2pt,i1ray,modout)
% trace a single ray through the model
% npt: 当前射线的节点数
% ifam: 累计射线组编号
% ir: 当前射线在射线组内的编号
% xsmax: 当前射线可到达的最远距离
% idl: 射线组编号-层号
% idr: 射线组编号-射线类型编号
% iray: 1-绘制所有射线，2-只绘制到达边界的射线
% iflag: 0-函数正常完成，1-未正常完成

    global fID_11 fID_12;
    global ar_ b dstepf fid hdenom hmin iblk ivg ifcbnd idray iwave idump ...
        id ifast isrkc icasel ihdw layer ntray ntpts n2 n3 nptbnd pi2 pi4 pi18 ...
        ppray pi34 ray s smax tol vr vp vs vsvp xr xbnd zr;

    global bcotan c factan iblk layer mcotan; % for fun_rkdumb -> fun_odexfi
    global btan c factan iblk layer mtan; % for fun_rkdumb -> fun_odezfi
    global ar_ b c crit cosmth dstepf fid fid1 iblk id ivg iwave icasel ircbnd iccbnd ...
      idray istop ibsmth icbnd iheadf idifff ihdw layer nbnd nptbnd npskp ...
      n2 n3 nblk nstepr nccbnd nbnda nlayer piray pi2 pit2 ray refll s vm ...
      vr vp vs vsvp xmin xr xsinc zr; % for fun_adjpt
    global c iblk layer smax smin step_; % for fun_dstep
    global xmax;

    % layer: 当前节点所在的层号
    % iblk: 当前节点所在的 block 编号

    iflag = 0;

    while iflag == 0
        x1 = xbnd(layer,iblk,1);
        x2 = xbnd(layer,iblk,2);
        z1 = s(layer,iblk,1).*x1 + b(layer,iblk,1);
        z2 = s(layer,iblk,1).*x2 + b(layer,iblk,1);
        z3 = s(layer,iblk,2).*x2 + b(layer,iblk,2);
        z4 = s(layer,iblk,2).*x1 + b(layer,iblk,2);
        A = [x1,z1];
        B = [x2,z2];
        C = [x2,z3];
        D = [x1,z4];
        x0 = xr(npt);
        z0 = zr(npt);
        theta0 = ar_(npt,2);

        xspan = [x0, xbnd(layer,iblk,2)+0.001];
        if fid < 0
            xspan = [x0, xbnd(layer,iblk,1)-0.001];
        end
        c_flatten = squeeze(c(layer,iblk,:));
        % opts = odeset('RelTol',1e-2,'AbsTol',1e-4);
        % [x,y] = ode113(@(x,y) fun_ode(x,y, c_flatten), xspan, [z0; theta0], opts);
        [x,y] = ode45(@(x,y) fun_ode(x,y, c_flatten), xspan, [z0; theta0]);

        % 找到第一个穿出边界的节点
        index = length(x);
        isInside = fun_isInside(A,B,C,D, [x(index),y(index,1)]);
        if isInside
            error('trace:assert', 'assert failed!');
        end
        for index = length(x):-1:1
            isInside = fun_isInside(A,B,C,D, [x(index),y(index,1)]);
            if isInside
                break;
            end
        end
        index = index + 1;

        begin = npt + 1;
        npt = npt + index;

        xr(begin:npt) = x(1:index);
        zr(begin:npt) = y(1:index,1);
        ar_(begin:npt,1) = y(1:index,2);
        ar_(begin:npt,2) = y(1:index,2);

        % [xr(npt),zr(npt)] = fun_check(0,xr(npt),zr(npt), b,iblk,id,layer,s,xbnd);
        % [xr(npt),zr(npt)] = fun_check(1,xr(npt),zr(npt), b,iblk,id,layer,s,xbnd);

        vp(begin:npt,1) = fun_vel(xr(begin:npt),zr(begin:npt), c,iblk,layer);
        vp(begin:npt,2) = vp(begin:npt,1);
        vs(begin:npt,1) = vp(begin:npt,1) .* vsvp(layer,iblk);
        vs(begin:npt,2) = vs(begin:npt,1);
        if iwave == 1
            vr(begin:npt,1:2) = vp(begin:npt,1:2);
        else
            vr(begin:npt,1:2) = vs(begin:npt,1:2);
        end

        % 如果节点数超过预设上限，退出
        if npt >= ppray
            warning('节点数 %d 超过上限 %d', npt, ppray);
            [vr,iflag,ntpts] = fun_goto999(vr,iflag,ir,fID_11,ifcbnd,idray,ii2pt,npt,ntpts);
            return; % go to 999
        end

        top = s(layer,iblk,1) .* xr(npt) + b(layer,iblk,1);
        bottom = s(layer,iblk,2) .* xr(npt) + b(layer,iblk,2);
        left = xbnd(layer,iblk,1);
        right = xbnd(layer,iblk,2);

        if ~exist('lstart','var'), [lstart,istart,xfr,zfr,ifrpt,iflagf] = deal([]); end
        [ar_,b,c,crit,cosmth,dstepf,fid,fid1,iblk,id,ivg,iwave,icasel,ircbnd,iccbnd,...
            idray,istop,ibsmth,icbnd,iheadf,idifff,ihdw,layer,nbnd,nptbnd,npskp,...
            n2,n3,nblk,nstepr,nccbnd,nbnda,nlayer,piray,pi2,pit2,ray,refll,s,vm,...
            vr,vp,vs,vsvp,xmin,xr,xsinc,zr, ...
        npt,top,bottom,~,~,~,~,~,lstart,istart,~,iflag,~,~,~,~,~,~,~] ...
        = fun_adjpt(ar_,b,c,crit,cosmth,dstepf,fid,fid1,iblk,id,ivg,iwave,icasel,ircbnd,iccbnd,...
            idray,istop,ibsmth,icbnd,iheadf,idifff,ihdw,layer,nbnd,nptbnd,npskp,...
            n2,n3,nblk,nstepr,nccbnd,nbnda,nlayer,piray,pi2,pit2,ray,refll,s,vm,...
            vr,vp,vs,vsvp,xmin,xr,xsinc,zr, ...
            xbnd, ...
        npt,top,bottom,left,right,ifam,ir,iturn,lstart,istart,invr,iflag,idl,idr,xfr,zfr,ifrpt,iflagf,modout);
    end

end % function end


function isInside = fun_isInside(A,B,C,D,P)
% 判断一个点 P 是否在凸四边形 ABCD 的内部

    AB = B - A;
    BC = C - B;
    CD = D - C;
    DA = A - D;
    AP = P - A;
    BP = P - B;
    CP = P - C;
    DP = P - D;
    res = [det([AB;AP]), det([BC;BP]), det([CD;CP]), det([DA;DP])];
    if all(res > 0) || all(res < 0)
        isInside = true;
    else
        isInside = false;
    end
end

% 900
% [vr,iflag,ntpts]
function [vr,iflag,ntpts] = fun_goto900(ifcbnd,idray,ii2pt,vr,npt,iflag,ntpts)

    if ifcbnd > 0 && idray(2) ~= 4 && ii2pt == 2
        vr(npt,2) = 0.0;
        iflag = 1;
    end
    ntpts = ntpts + npt;
    return;
end

% 999
% [vr,iflag,ntpts]
function [vr,iflag,ntpts] = fun_goto999(vr,iflag,ir,fID_11,ifcbnd,idray,ii2pt,npt,ntpts)

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
