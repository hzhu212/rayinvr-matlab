% misc.f
% [~,~,~,~,~,~,itt,~,~,~,~]
% called by: main;
% call: none.

function [is,xshot,npt,nr,a1,ifam,itt,iszero,iflag,uf,irayf] = fun_ttime(is,xshot,npt,nr,a1,ifam,itt,iszero,iflag,uf,irayf)
% calculate travel time along a single ray using the equation:
%
%                   t=2*h/(v1+v2)
%
% for the travel time between two points a distance h apart

	global file_rayinvr_par file_rayinvr_com;
	global fID_11 fID_12;
	run(file_rayinvr_par);
	% real vave(ppray)
	% integer itt(1)
	run(file_rayinvr_com);

	if idump == 1
		% 15
	    fprintf(fID_12, '%2d%3d%4d%8.3f%8.3f%8.2f%8.2f%7.2f%7.2f%3d%3d%3d%3d\n', ...
	    	ifam,nr,npt,xr(npt),zr(npt),ar(npt,1).*pi18,ar(npt,2).*pi18,vr(npt,1),vr(npt,2),layer,iblk,id,iwave);
	end

	time = 0.0;
	iflagw = 0;

	for ii = 1:npt-1 % 10
		tr(ii) = sqrt((xr(ii+1)-xr(ii)).^2 + (zr(ii+1)-zr(ii)).^2);
		vave(ii) = (vr(ii,2) + vr(ii+1,1)) ./ 2.0;
		if iflagw == 0 & vave(ii) > 1.53
		    iflagw = 1;
		end
		if iflagw == 1 & vave(ii) < 1.53 & nr ~= 0
		    % 67
		    % fprintf(fID_67, '%5d%10.3f%10.3f%10.3f%10.3f%10d\n', nr,xr(ii),zr(ii),time,uf,irayf);
		    iflagw = 2;
		end
		time = time + tr(ii) ./ vave(ii);
	end % 10

	a2 = fid1 .* (90.0-fid.*ar(npt,1).*pi18) ./ fid;
	nptr = npt;
	if vred == 0.0
	    timer = time;
	else
		timer = time - abs(xr(npt)-xshot) ./ vred;
	end
	rayid(ntt) = idray(1) + idray(2)./10.0; % float
	if nr == 0, return; end % go to 999
	% 5
	fprintf(fID_11, '%4d%4d%9.3f%9.3f%9.3f%8.2f%8.3f%6d%6.1f\n',
		is,nr,a1,a2,xr(npt),zr(npt),timer,nptr,rayid(ntt));
	if vr(npt,2) ~= 0.0
	    itt(ifam) = itt(ifam) + 1;
	    if iszero == 0
	        range(ntt) = xr(npt);
	    else
	    	range(ntt) = abs(xr(npt)-xshot);
	    end
	    tt(ntt) = timer;
	    xshtar(ntt) = xshot;
	    fidarr(ntt) = fid1;
	    ntt = ntt + 1;
	end
	% 999
	return;
end % fun_ttime end