% trc.f
% [~,~,iblk1]
% called by: fun_adjpt; fun_auto; fun_hdwave;
% call: none;

function [x,layer1,iblk1] = fun_block(x,layer1,iblk1)
% determine block of point x in layer

    global file_rayinvr_par file_rayinvr_com;
    run(file_rayinvr_par);
    run(file_rayinvr_com);

    for ii = 1:nblk(layer1) % 10
        if x>=xbnd(layer1,ii,1) & x<= xbnd(layer1,ii,2)
            iblk1 = ii;
            return;
        end
    end % 10

    % stop
    error('e:stop','\n***  block undetermined  ***\nlayer=%3d  x=%10.3f\n\n',layer1,x);
end % fun_block end