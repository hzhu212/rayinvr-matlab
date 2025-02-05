% plt.f
% []
% call: none.
% called by: none.

function fun_my_pltdat(iszero,idata,xshot,idr,nshot,tadj,xshota,xbmin,xbmax,tbmin,tbmax,itxbox,ida)
% plot observed travel times
% 绘制从地震数据拾取的标准走时，带 error bar

    global colour ifcol ilshot ipf ipinv isep itcol itx narinv ncol orig symht ...
        tpf tscale upf xmint xpf xscalt;
    global hFigure1 hFigure2 currentColor matlabColors;

    % 源程序中未声明以下2个变量，因为其不在 rayinvr.par 和 rayinvr.com 中
    global imod iray;

    % assign tag for ray groups
    global ray ivray;

    % 将 figure2(走时图像)设为当前图像
    figure(hFigure2);
    % set(hFigure2,'CurrentAxes',gca());

    rayGroupBeginIdx = find(ipf == 0) + 1;
    nRayGroups = length(rayGroupBeginIdx);
%     allRayIds = sort(unique(ipf(rayGroupBeginIdx)));
    for ii = 1:nRayGroups
        thisShot = ilshot(ii);
        nextShot = ilshot(ii+1);

        xThisShot = xpf(thisShot);
        dThisShot = sign(tpf(thisShot));

        % 仅绘制在 r.in 的 xshot 中指定的炮点，略过其他炮点
        if isempty(find(abs(xshot - xThisShot) < 1e-3))
            continue;
        end

        % 要绘制的射线所在的行号
        index = thisShot+1:nextShot-1;

        % abs(data) = 2 时，只绘制反演过的射线，未反演的跳过
        if abs(idata) == 2
            % 射线编号，即射线所在行号减去当前炮点编号(因为每个炮点信息占一行)
            rayNumbers = index - ii;
            % 取交集，找到反演过的射线编号
            inversedRay = intersect(rayNumbers,ipinv(1:narinv));
            index = inversedRay + ii;
        end

        % 如果待绘制的射线组为空，则进行下一组
        if isempty(index)
            continue;
        end

        codeChange = find(ipf(index(1:end-1)) ~= ipf(index(2:end)));
        codeChange = [0; codeChange; length(index)];
        for jj = 1:length(codeChange)-1
            codeBegin = codeChange(jj) + 1;
            codeEnd = codeChange(jj+1);
            indexThisCode = index(codeBegin:codeEnd);

            xp = xpf(indexThisCode);
            tp = tpf(indexThisCode);
            up = upf(indexThisCode);
            ip = ipf(indexThisCode);
            % rayCode = ip(1);

            % 仅绘制在 r.in 的 ivray 中指定的射线组
            % ray groups not in ivray will not be observed
            ray_idx = find(ivray == ip(1), 1);
            if isempty(ray_idx)
                continue;
            end

            % get current ray code and x coordinate of current shot for tag
            % convert ray group to ray code. see r.in: ray, ivray
            ray_code = ray(ray_idx);

            if iszero == 0
                % xplot = xp - xmint;
                xplot = xp;
            else
                % xplot = (xp - xThisShot) .* dThisShot - xmint;
                xplot = (xp - xThisShot) .* dThisShot;
            end
            if itx ~= 4
                % tplot = tp - tadj;
                tplot = tp;
            else
                % tplot = abs(ip) - tadj;
                tplot = abs(ip);
            end

            if itcol == 1 || itcol == 2
                if itcol == 1
                    % ipcol = colour(mod(ip(1)-1,ncol)+1);
                    ipcol = find(ivray == ip(1), 1);
                else
                    % ipcol = colour(mod(ii-1,ncol)+1);
                    ipcol = ii;
                end
                currentColor = matlabColors{mod(ipcol, length(matlabColors)+1) + 1};
            end

            if itxbox ~= 0
                filtIndex = find(xplot >= xbmin & xplot <= xbmax & tplot >= tbmin & tplot <= tbmax);
                xplot = xplot(filtIndex);
                tplot = tplot(filtIndex);
                up = up(filtIndex);
            end

            lineStyle = '';
            lineSymbol = 's';
            markerSize = symht .* 5;

            [~, idx] = min(abs(xshot(1:nshot) - xThisShot));
            tag = sprintf('%.4f-%.1f', xshot(idx), ray_code);

            if idata > 0
                hline = plot(xplot,tplot,'Visible','off');
                hline.UserData.tag = ['time/observe/', tag];
                try
                    hErrorbar = my_errorbar(xplot,tplot,1.*up,[lineStyle,lineSymbol]);
                catch e
                    hErrorbar = errorbar(xplot,tplot,1.*up,[lineStyle,lineSymbol]);
                end
                set(hErrorbar,'MarkerSize',markerSize,'Color',currentColor);
            else
                hline = plot(xplot,tplot,[lineStyle,lineSymbol],'Color',currentColor,'MarkerSize',markerSize);
                hline.UserData.tag = ['time/observe/', tag];
            end
        end
    end

    % 采用 dummy plot 的形式，为 figure1 和 figure2 同时添加图例。
    % 颜色为线条颜色，标签为对应的 ray code
    ax1 = get(hFigure1, 'CurrentAxes');
    ax2 = get(hFigure2, 'CurrentAxes');
    hold(ax1, 'on');
    hold(ax2, 'on');
    valid_ray = ray(1:(find(ray == 0, 1)-1));
    [handles1, handles2] = deal([]);
    labels = {};
    for ii = 1:numel(valid_ray)
        colour = matlabColors{mod(ii, length(matlabColors)+1) + 1};
        label = sprintf('%4.1f', valid_ray(ii));
        dummy1 = plot(ax1, [NaN, NaN], [NaN, NaN], 'Color', colour, 'LineWidth', 0.5);
        dummy2 = plot(ax2, [NaN, NaN], [NaN, NaN], 'Color', colour, 'LineWidth', 0.5);
        handles1 = [handles1, dummy1];
        handles2 = [handles2, dummy2];
        labels = [labels, label];
    end
    % 绘制图例，且阻止后续更新图像后图例自动更新
    legend(ax1, handles1, labels, 'AutoUpdate', 'off');
    legend(ax2, handles2, labels, 'AutoUpdate', 'off');

    % 999
    if itcol ~= 0
        currentColor = matlabColors{ifcol};
    end
    return;

end % fun_my_pltdat end
