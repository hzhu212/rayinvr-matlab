% inv.f
% [~,~,~]
% called by: fun_trace; fun_hdwave;
% call: none.

function [lulu,iu,npt] = fun_velprt(lulu,iu,npt)
% calculate velocity partial derivatives

    % global file_rayinvr_par file_rayinvr_com;
    % run(file_rayinvr_par);
    % run(file_rayinvr_com);

    global c fpart ivv ninv vr xr zr;

    for jj = 1:4 % 10
        if ivv(lulu,iu,jj) ~= 0
            jv = ivv(lulu,iu,jj);
            sl = sqrt((xr(npt)-xr(npt-1)).^2 + (zr(npt)-zr(npt-1)).^2);
            v1 = vr(npt-1,2);
            v2 = vr(npt,1);
            dvj1 = (cv(lulu,iu,jj,1).*xr(npt-1) + cv(lulu,iu,jj,2).*xr(npt-1).^2 + ...
                cv(lulu,iu,jj,3).*zr(npt-1) + cv(lulu,iu,jj,4).*xr(npt-1).*zr(npt-1) + ...
                cv(lulu,iu,jj,5)) ./ (c(lulu,iu,6).*xr(npt-1) + c(lulu,iu,7));
            dvj2 = (cv(lulu,iu,jj,1).*xr(npt) + cv(lulu,iu,jj,2).*xr(npt).^2 + ...
                cv(lulu,iu,jj,3).*zr(npt) + cv(lulu,iu,jj,4).*xr(npt).*zr(npt) + ...
                cv(lulu,iu,jj,5)) ./ (c(lulu,iu,6).*xr(npt) + c(lulu,iu,7));
            dvv2 = (dvj1 ./ v1.^2 + dvj2 ./ v2.^2) ./ 2.0;
            fpart(ninv,jv) = fpart(ninv,jv) - sl.*dvv2;
        end
    end % 10
    return;
end % fun_velprt end