% inv.f
% [~,~,~,~,~,~,~,~,~]
% called by: fun_hdwave; fun_adjpt;
% call: none.

function [lu,iu,v1,v2,a1,a2,alphaalpha,npt,itype] = fun_bndprt(lu,iu,v1,v2,a1,a2,alphaalpha,npt,itype)
% calculate boundary partial derivatives

	global file_rayinvr_par file_rayinvr_com;
	run(file_rayinvr_par);
	run(file_rayinvr_com);

	if abs(itype)==2, a2=pi-2; end % iabs -> abs
	if itype > 0
	    iz1 = 3;
	    iz2 = 4;
	else
		iz1 = 1;
		iz2 = 2;
	end

	for ii = iz1:iz2 % 10
	    if izv(lu,iu,ii) ~= 0
	        jv = izv(lu,iu,ii);
	        if cz(lu,iu,ii,2) ~= 0.0
	            slptrm = cos(alphaalpha) .* abs(cz(lu,iu,ii,1)-xr(npt)) ./ cz(lu,iu,ii,2);
	        else
	        	slptrm = 1.0;
	        end
	        if itype < 0
	            ibz = 0;
	        else
	        	ibz = 1;
	        end
	        if nzed(lu+ibz) == 1
	            fudge = 2.0;
	        else
	        	fudge = 1.0;
	        end
	        fpart(ninv,jv) = fpart(ninv,jv) + fudge.*sign(itype) .* (cos(a1)./v1-cos(a2)./v2) .* slptrm;
	    end
	end % 10
	return;
end % fun_bndprt end