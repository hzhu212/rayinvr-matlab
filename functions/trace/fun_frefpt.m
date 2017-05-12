% trc.f
% [xfr,zfr,ifrpt,iflagf]
% called by: fun_trace;
% call: none.

function [xfr,zfr,ifrpt,iflagf] = fun_frefpt(npt)
% determine intersection point of ray with a floating reflector
% 求当前射线前进的小线段与当前浮动界面的交点
% npt: 当前节点在当前射线上的编号
% xfr,zfr: 交点的 x 和 z 坐标(此处求的是直线交点，而非线段交点)
% iflagf: 1-找到交点
% ifrpt: 交点对应的浮动界面节点编号

	% ifcbnd: 当前浮动边界的编号
	% npfref: 数组，每个浮动边界的节点个数
	% xfrefl,zfrefl: 浮动界面上每个节点的坐标
    global ifcbnd npfref xfrefl xr zfrefl zr;

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
            ifrpt = ii;
            break; % go to 999
        end
    end % 10

    % 999
    return;
end % function end
