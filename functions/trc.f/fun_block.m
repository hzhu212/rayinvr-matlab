% trc.f
% [iblk1]
% called by: fun_adjpt; fun_auto; fun_hdwave;
% call: none;

function [iblk1] = fun_block(x,layer1)
% determine block of point x in layer
% 给定层号和 x 坐标，返回 block 编号

    global nblk xbnd;

    for ii = 1:nblk(layer1) % 10
        if x >= xbnd(layer1,ii,1) && x <= xbnd(layer1,ii,2)
            iblk1 = ii;
            return;
        end
    end % 10

    % stop
    error('e:stop','\n***  block undetermined  ***\nlayer=%3d  x=%10.3f\n\n',layer1,x);
end % fun_block end
