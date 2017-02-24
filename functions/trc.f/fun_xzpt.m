% trc.f
% [~,~,layers,iblks,iflag]
% called by: main; fun_modwr; fun_fd;
% call: none.

function [xpt,zpt,layers,iblks,iflag] = fun_xzpt(xpt,zpt,layers,iblks,iflag)
    % global file_rayinvr_par file_rayinvr_com;
    % run(file_rayinvr_par);
    % run(file_rayinvr_com);

    global b nblk nlayer s xbnd;

    iflag = 0;
    for ii = 1:nlayer % 10
        for jj = 1:nblk(ii) % 20
            top = s(ii,jj,1) .* xpt + b(ii,jj,1);
            bottom = s(ii,jj,2) .* xpt + b(ii,jj,2);
            left = xbnd(ii,jj,1);
            right = xbnd(ii,jj,2);
            if zpt+0.001<top | zpt-0.001>bottom | xpt+0.001<left | xpt-0.001>right | abs(top-bottom)<0.001
                continue; % go to 20
            end
            layers = ii;
            iblks = jj;
            return;
        end % 20
    end % 10
    iflag = 1;
    return;
end