% misc.f
% [itt, fidarr,ntt,range_,rayid,time,timer_,tr,tt,xshtar]
% called by: main;
% call: none.

function [itt, fidarr,ntt,range_,rayid,time,timer_,tr,tt,xshtar] = fun_ttime(is,xshot,npt,nr,a1,ifam,itt,iszero,iflag,uf,irayf, ar_,fid,fid1,fidarr,iblk,id,idray,idump,iwave,layer,ntt,pi18,range_,rayid,time,timer_,tr,tt,vr,vred,xr,xshtar,zr)
% calculate travel time along a single ray using the equation:
%
%                   t=2*h/(v1+v2)
%
% for the travel time between two points a distance h apart

    global fID_11 fID_1111 fID_12;
    % global ar_ fid fid1 fidarr iblk id idray idump iwave layer ntt pi18 ...
    %   range_ rayid time timer_ tr tt vr vred xr xshtar zr;

    % real vave(ppray)
    % integer itt(1)

    if idump == 1
        % 15
        fprintf(fID_12, '%2d%3d%4d%8.3f%8.3f%8.2f%8.2f%7.2f%7.2f%3d%3d%3d%3d\n', ...
            ifam,nr,npt,xr(npt),zr(npt),ar_(npt,1).*pi18,ar_(npt,2).*pi18,vr(npt,1),vr(npt,2),layer,iblk,id,iwave);
    end

    time = 0.0;
    iflagw = 0;

    % npt: the number of points defining current ray path
    for ii = 1:npt-1 % 10
        % the distance between two adjacent points of a ray
        tr(ii) = sqrt((xr(ii+1)-xr(ii)).^2 + (zr(ii+1)-zr(ii)).^2);
        % average velocity between the two points
        vave(ii) = (vr(ii,2) + vr(ii+1,1)) ./ 2.0;
        if iflagw == 0 && vave(ii) > 1.53
            iflagw = 1;
        end
        if iflagw == 1 && vave(ii) < 1.53 && nr ~= 0
            % 67
            % fprintf(fID_67, '%5d%10.3f%10.3f%10.3f%10.3f%10d\n', nr,xr(ii),zr(ii),time,uf,irayf);
            iflagw = 2;
        end
        % accumulate the travel time
        time = time + tr(ii) ./ vave(ii);
    end % 10

    % angle of the ray when reaching receiver
    a2 = fid1 .* (90.0-fid.*ar_(npt,1).*pi18) ./ fid;

    nptr = npt;

    % get reduced travel time. Why not original travel time? Maybe for better plotting...
    if vred == 0.0
        timer_ = time;
    else
        timer_ = time - abs(xr(npt)-xshot) ./ vred;
    end

    % get the ray code
    rayid(ntt) = idray(1) + idray(2)./10.0; % float
    if nr == 0, return; end % go to 999

    % output to r1.out
    fprintf(fID_11, '%4d%4d%9.3f%9.3f%9.3f%8.2f%8.3f%6d%6.1f\n',...
        is,nr,a1,a2,xr(npt),zr(npt),timer_,nptr,rayid(ntt));

    % output to r1_ext.out
    [zturn, idx] = max(zr(1:npt));
    xturn = xr(idx);
    % shot  ray  i.angle  f.angle     dist    depth red.time  npts  code    xturn    zturn
    fprintf(fID_1111, '%4d%5d%9.3f%9.3f%9.3f%9.3f%9.3f%6d%6.1f%9.3f%9.3f\n',...
        is,nr,a1,a2,xr(npt),zr(npt),timer_,nptr,rayid(ntt),xturn,zturn);

    if vr(npt,2) ~= 0.0
        itt(ifam) = itt(ifam) + 1;
        if iszero == 0
            range_(ntt) = xr(npt);
        else
            range_(ntt) = abs(xr(npt)-xshot);
        end
        tt(ntt) = timer_;
        xshtar(ntt) = xshot;
        fidarr(ntt) = fid1;
        ntt = ntt + 1;
    end
    % 999
    return;
end % fun_ttime end
