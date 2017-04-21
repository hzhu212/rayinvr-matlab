% atrc.f
% [~,~,~,~,~,vshot,vtop,vbotom]
% called by: fun_auto;
% call: fun_vel; done.

function [xshot,zshot,lsls,ibs,l,vshot,vtop,vbotom] = fun_calvel(xshot,zshot,lsls,ibs,l,vshot,vtop,vbotom)

    global iblk iwave iccbnd icbnd layer nblk vm vsvp xbnd;

    global c iblk layer; % for fun_vel

    layer = lsls;
    iblk = ibs;
    iwave = 1;
    iccbnd = 1;
    vshot = fun_vel(xshot,zshot, c,iblk,layer);
    % 如果射线以 S 波从炮点发出
    if icbnd(1) == 0
        % 由 S 波波速求 P 波波速
        vshot = vshot .* vsvp(layer,iblk);
        iwave = - iwave ;
        iccbnd = 2;
    end
    vlmax = vshot;
    xfctr = (xshot-xbnd(layer,iblk,1)) ./ (xbnd(layer,iblk,2)-xbnd(layer,iblk,1));
    vb1 = (vm(layer,iblk,4)-vm(layer,iblk,3)) .* xfctr + vm(layer,iblk,3);
    if iwave == -1, vb1 = vb1 .* vsvp(layer,iblk); end
    if vb1 > vlmax, vlmax = vb1; end
    nloop = l - layer;
    if nloop == 0
        vtop = vshot;
        vbotom = vlmax;
        return;
    end
    for k = 1:nloop % 10
        ii = layer + k;
        for jj = 1:nblk(ii) % 20
            if xbnd(ii,jj,1) <= xshot && xbnd(ii,jj,2) >= xshot
                vti = (vm(ii,jj,2)-vm(ii,jj,1)) .* xfctr + vm(ii,jj,1);
                vbi = (vm(ii,jj,4)-vm(ii,jj,3)) .* xfctr + vm(ii,jj,3);
                if icbnd(iccbnd) == k
                    iwave = -iwave;
                    iccbnd = iccbnd + 1;
                end
                if iwave == -1
                    vti = vti .* vsvp(ii,jj);
                    vbi = vbi .* vsvp(ii,jj);
                end
                if ii < l
                    if vti > vlmax, vlmax = vti; end
                    if vbi > vlmax, vlmax = vbi; end
                else
                    if vti > vlmax
                        vtop = vti;
                        vlmax = vti;
                    else
                        vtop = vlmax;
                    end
                    if vbi > vlmax
                        vbotom = vbi;
                    else
                        vbotom = vlmax;
                    end
                end
            end
        end % 20
    end % 10
end % function end
