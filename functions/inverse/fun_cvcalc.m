% inv.f
% []
% called by: fun_calmod;
% call: none.

function fun_cvcalc(ii,jj,ipos,itype,cf)
% calculate coefficients of velocity partial derivatives

    % global file_rayinvr_par file_rayinvr_com;
    % run(file_rayinvr_par);
    % run(file_rayinvr_com);

    global b cv_ s xbnd;

    if itype == 1
        ssign = 1.0;
        sb = s(ii,jj,2);
        xb = xbnd(ii,jj,2);
        bb = b(ii,jj,2);
    elseif itype == 2
        ssign = -1.0;
        sb = s(ii,jj,2);
        xb = xbnd(ii,jj,1);
        bb = b(ii,jj,2);
    elseif itype == 3
        ssign = -1.0;
        sb = s(ii,jj,1);
        xb = xbnd(ii,jj,2);
        bb = b(ii,jj,1);
    elseif itype == 4
        ssign = 1.0;
        sb = s(ii,jj,1);
        xb = xbnd(ii,jj,1);
        bb = b(ii,jj,1);
    end

    cv_(ii,jj,ipos,1) = cv_(ii,jj,ipos,1) + cf*ssign*(sb*xb-bb);
    cv_(ii,jj,ipos,2) = cv_(ii,jj,ipos,2) - cf*ssign*sb;
    cv_(ii,jj,ipos,3) = cv_(ii,jj,ipos,3) - cf*ssign*xb;
    cv_(ii,jj,ipos,4) = cv_(ii,jj,ipos,4) + cf*ssign;
    cv_(ii,jj,ipos,5) = cv_(ii,jj,ipos,5) + cf*ssign*bb*xb;

    return;
end % fun_cvcalc end
