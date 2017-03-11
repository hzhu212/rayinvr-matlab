% inv.f
% [~,~,~]
% called by: fun_trace; fun_hdwave;
% call: none.

function [lu_,iu,npt] = fun_velprt(lu_,iu,npt)
% calculate velocity partial derivatives

    % global file_rayinvr_par file_rayinvr_com;
    % run(file_rayinvr_par);
    % run(file_rayinvr_com);

    global c cv fpart ivv ninv vr xr zr;

    for jj = 1:4 % 10
        if ivv(lu_,iu,jj) ~= 0
            jv = ivv(lu_,iu,jj);
            sl = sqrt((xr(npt)-xr(npt-1)).^2 + (zr(npt)-zr(npt-1)).^2);
            v1 = vr(npt-1,2);
            v2 = vr(npt,1);
            dvj1 = (cv(lu_,iu,jj,1).*xr(npt-1) + cv(lu_,iu,jj,2).*xr(npt-1).^2 + ...
                cv(lu_,iu,jj,3).*zr(npt-1) + cv(lu_,iu,jj,4).*xr(npt-1).*zr(npt-1) + ...
                cv(lu_,iu,jj,5)) ./ (c(lu_,iu,6).*xr(npt-1) + c(lu_,iu,7));
            dvj2 = (cv(lu_,iu,jj,1).*xr(npt) + cv(lu_,iu,jj,2).*xr(npt).^2 + ...
                cv(lu_,iu,jj,3).*zr(npt) + cv(lu_,iu,jj,4).*xr(npt).*zr(npt) + ...
                cv(lu_,iu,jj,5)) ./ (c(lu_,iu,6).*xr(npt) + c(lu_,iu,7));
            dvv2 = (dvj1 ./ v1.^2 + dvj2 ./ v2.^2) ./ 2.0;
            fpart(ninv,jv) = fpart(ninv,jv) - sl.*dvv2;
        end
    end % 10
    return;
end % fun_velprt end