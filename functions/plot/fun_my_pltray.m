% plt.f
% []
% call:
% called by: main;

function fun_my_pltray(npt,nskip,idot,irayps,istep,anglew)
% plot one ray path with matlab graphic functions.

    global ifcol ircol irrcol nbnd nbnda npskp orig ppray ray s sep symht ...
        vp vr xmin xmm xr xscale zmin zr zscale;
    global matlabColors currentColor hFigure1;

    % assign tag for ray groups
    global xshotr idray;

    npts = npt - nskip;
    if npts < 2, return; end

    % x,z 为射线控制点的横纵坐标
    % x(1:npts) = xr(nskip+1:npt) - xmin;
    % z(1:npts) = zr(nskip+1:npt) - zmin;
    x(1:npts) = xr(nskip+1:npt);
    z(1:npts) = zr(nskip+1:npt);
    vra(1:npts) = vr(nskip+1:npt,2);
    vpa(1:npts) = vp(nskip+1:npt,2);

    if npskp ~= 1
        nbnds = find(nbnda(1:nbnd)>(nskip+1),1);

        nbnd = nbnd - nbnds + 1;
        nbnda(1:nbnd) = nbnda(nbnds:nbnd+nbnds-1) - nskip;

        npts = 1;
        np1 = 2;
        for jj = 1:nbnd % 110
            if nbnda(jj) > np1 && nbnda(jj)-np1 > npskp
                for ii = np1:npskp:nbnda(jj)-1 % 120
                    npts = npts + 1;
                    x(npts) = x(ii);
                    z(npts) = z(ii);
                    vra(npts) = vra(ii);
                    vpa(npts) = vpa(ii);
                end % 120
            end
            npts = npts + 1;
            x(npts) = x(nbnda(jj));
            z(npts) = z(nbnda(jj));
            vra(npts) = vra(nbnda(jj));
            vpa(npts) = vpa(nbnda(jj));
            np1 = nbnda(jj) + 1;
        end % 110
    end

    % 将 figure1(模型图像) 设为当前图像
    % figure(hFigure1);
    % set(hFigure1,'CurrentAxes',gca());

    hold on;

    if ircol ~= 0
        currentColor = matlabColors{mod(irrcol, length(matlabColors)) + 1};
    end

    % 设置线型与节点符号
    lineStyle = '-';
    lineSymbol = '';
    markerSize = symht .* 5;

    % 100
    if idot > 0
        lineSymbol = 's';
    end
    if idot == 2
        lineStyle = '';
    end

    % get current ray code and x coordinate of current shot for tag
    ray_code = idray(1) + idray(2)./10.0;
    tag = sprintf('%.4f-%.1f', xshotr, ray_code);

    % p 波画实线，s 波画虚线
    if idot ~= 2 && irayps == 1
        maskp = (vra(1:npts-1) == vpa(1:npts-1));
        masks = ~maskp;
        maskp = [maskp, 0] | [0, maskp];
        masks = [masks, 0] | [0, masks];
        hline = plot(x(maskp),z(maskp),['-',lineSymbol],'Color',currentColor,'MarkerSize',markerSize);
        hline.UserData.tag = ['ray/', tag, '/p'];
        hline = plot(x(masks),z(masks),['--',lineSymbol],'Color',currentColor,'MarkerSize',markerSize);
        hline.UserData.tag = ['ray/', tag, '/s'];
    else
        hline = plot(x(1:npts),z(1:npts),[lineStyle,lineSymbol],'Color',currentColor,'MarkerSize',markerSize);
        hline.UserData.tag = ['ray/', tag, '/ps'];
    end

    if ircol ~= 0
        currentColor = matlabColors{ifcol};
    end

    hold off;

    return;
end % fun_my_pltray end
