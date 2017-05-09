% trc.f
% [layers,iblks,iflag]
% called by: main; fun_modwr; fun_fd;
% call: none.

function [layers,iblks,iflag] = fun_xzpt(xpt,zpt, b,nblk,nlayer,s,xbnd)
% 给定一个炮点 (xpt,zpt)，找到该炮点所在的 block

% 返回值：
% layers: block 所在层号
% iblks: 在层内的序号
% iflag: 是否成功找到，0-成功，1-失败，即找不到满足条件的 block

    % global b nblk nlayer s xbnd;

    iflag = 0;

    for ii = 1:nlayer
        for jj = 1:nblk(ii)
            left = xbnd(ii,jj,1);
            right = xbnd(ii,jj,2);

            % 如果 x 坐标小于当前 block 左边界，则进入下一个 layer
            if xpt + 0.001 < left, break; end

            % 如果 x 坐标大于当前 block 右边界，则进入下一个 block
            if xpt - 0.001 > right, continue; end

            top = s(ii,jj,1) .* xpt + b(ii,jj,1);
            bottom = s(ii,jj,2) .* xpt + b(ii,jj,2);

            % 如果 x 坐标在当前 block 范围内，但 z 坐标出界，则进入下一个 layer
            if zpt + 0.001 < top || zpt - 0.001 > bottom || abs(top-bottom) < 0.001
                break;
            end

            layers = ii;
            iblks = jj;
            return;
        end
    end
    iflag = 1;

end
