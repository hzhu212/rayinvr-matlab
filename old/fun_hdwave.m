% hdw.f
function [ifam,ir,n,invr,xsmax,iflag,i1ray,modout] = fun_hdwave(ifam,ir,n,invr,xsmax,iflag,i1ray,modout)
% ray now travels along a layer boundary as a head wave.
% do not need to use runge kutta routine. after ray has
% traveled a distance hws further than previous ray, it
% is directed upward into the model.

	global file_rayinvr_par file_rayinvr_com;
	global fID_11 fID_12;
	run(file_rayinvr_par);
	run(file_rayinvr_com);

	dhw = 0.0;

	% 10
	cycle10 = true;
	while cycle10
		l1 = layer + 1;
		[xr(n),l1,ib] = fun_block(xr(n),l1,ib);
		if ivg(l1,ib)~=-1, break; end % go to 20
		layer = layer + 1;
		if layer == nlayer, fun_goto999(); return; end
	end

	% 20
	layer = l1;
	iblk = ib;
	idray(2) = 3;
	hwsl = hws;
	ilr = (id+3) ./ 2;
	irl = (3-id) ./ 2;
	alphaalpha = atan(s(layer,iblk,1));

	% 1000
	cycle1000 = true;
	while cycle1000 % -------------------- cycle1000 begin

	if dhw >= (tdhw-0.001)
	    lstart = layer;
        istart = iblk;
        ihdw = 0;
        tdhw = tdhw + hws;
        if dhw == 0.0
            vh = vel(xr(n),zr(n));
            if iwave==-1, vh=vh.*vsvp(layer,iblk); end
        end

        % 30
        cycle30 = true;
        while cycle30
	        l1 = layer - 1;
	        [xr(n),l1,ib] = fun_block(xr(n),l1,ib);
	        if ivg(l1,ib)~=-1, break; end % go to 40
            layer = layer - 1;
            if layer == 1, fun_goto999(); return; end
        end

        % 40
        layer = l1;
        iblk = ib;
        vp(n,2) = vel(xr(n),zr(n));
        vs(n,2) = vp(n,2) .* vsvp(layer,iblk);
        nccbnd = nccbnd + 1;
        if icbnd(iccbnd) == nccbnd
			iconvt = 1;
			iwave = -iwave;
			iccbnd = iccbnd + 1;
        end
        if iwave == 1
            vr(n,2) = vp(n,2);
        else
        	vr(n,2) = vs(n,2);
        end
        if iwave==-1 & vr(n,2)<=0.001
            vr(n,2) = 0.0;
            iflag = 1;
            if ir ~= 0
                fprintf(fID_11, '***  ray stopped - s-wave cannot propagate  ***\n');
            end
            return;
        end
        if ibsmth == 0
            alphaalpha = atan(s(layer,iblk,2));
        else
			npl = ifix((xr(n)-xmin-0.001)./xsinc) + 1;
			npr = npl + 1;
			xpl = xmin + (npl-1) .* xsinc;
			alphaalpha = (cosmth(layer+1,npr)-cosmth(layer+1,npl)) .* (xr(n)-xpl) ./ xsinc + cosmth(layer+1,npl);
        end
        if i1ray == 1
            nhskip = 0;
            i1ray = 0;
        else
        	nhskip = n - 1;
        end
        if hdw~=0, vh=vr(n,1); end
        vratio = vr(n,2) ./ vh;
        if vratio >= 1
            if idiff == 0
                vr(n,2) = 0.0;
                iflag = 1;
                return;
            else
            	a2 = 0.99999 .* pi2;
            end
        else
        	a2 = asin(vratio);
        end
        ar(n,2) = fid .* (pi-a2) - alphaalpha;
        if invr==1 & ir>0
            [lstart,istart,vr(n,1),vr(n,2),pi2,a2,alphaalpha,n,~] = fun_bndprt(lstart,istart,vr(n,1),vr(n,2),pi2,a2,alphaalpha,n,-1);
        end
        iflag = 0;
        return;
    else
    	if idump == 1
    		% 5
    	    fprintf(fID_12, '%2d%3d%4d%8.3f%8.3f%8.2f%8.2f%7.2f%7.2f%3d%3d%3d%3d\n', ...
    	    	ifam,ir,n,xr(n),zr(n),ar(n,1).*pi18,ar(n,2).*pi18,vr(n,1),vr(n,2),layer,iblk,id,iwave);
    	end
	end

	% 500
	cycle500 = true;
	while cycle500 % -------------------- cycle500 begin
		xrp = xr(n) + fid.*hwsl.*cos(alphaalpha);
		if fid.*xrp > fid.*xbnd(layer,iblk,ilr)
		    hl = abs(xbnd(layer,iblk,ilr)-xr(n)) ./ cos(alphaalpha);
	        hwsl = hwsl - hl;
	        if n == ppray
	            fun_goto900(); return;
	        end
	        n = n + 1;
	        nbnd = nbnd + 1;
	        if nbnd==piray, npskp=1; end
	        if npskp~=1, nbnda(nbnd)=n; end
	        xr(n) = xbnd(layer,iblk,ilr);
	        zr(n) = s(layer,iblk,1) .* xr(n) + b(layer,iblk,1);
	        if xsmax>0.0 & abs(xr(n)-xr(1))>xsmax
	            vr(n,2) = 0.0;
	            iflag = 1;
	            ihdwf = 0;
	            return;
	        end
	        vp(n,1) = vm(layer,iblk,ilr);
	        vs(n,1) = vp(n,1) .* vsvp(layer,iblk);
	        if iwave == 1
	            vr(n,1) = vp(n,1);
	        else
	        	vr(n,1) = vs(n,1);
	        end
	        ar(n,1) = ar(n-1,2);
	        iblk = iblk + id;
	        if iblk<1 | iblk>nblk(layer)
	            fun_goto999(); return;
	        end

	    	% 50
	        cycle50 = true;
	        while cycle50
	        	vp(n,2) = vm(layer,iblk,irl);
	        	if vp(n,2) > 0.0, break; end % go to 60
	    	    l1 = layer + 1;
	    	    if l1>nlayer, fun_goto999(); return; end
	    	    [~,l1,ib] = fun_block(xr(n)+fid.*0.001,l1,ib);
	    	    layer = l1;
	    	    iblk = ib;
	        end

	        % 60
	        vs(n,2) = vp(n,1) .* vsvp(layer,iblk);
	        if iwave == 1
	            vr(n,2) = vp(n,2);
	        else
	        	vr(n,2) = vs(n,2);
	        end
	        alphaalpha = atan(s(layer,iblk,1));
	        ar(n,2) = fid .* pi2 - alphaalpha;
	        if invr == 1 & ir > 0
	            [layer,iblk,n] = fun_velprt(layer,iblk,n);
	        end

	        if idump == 1
	            fprintf(fID_12, '%2d%3d%4d%8.3f%8.3f%8.2f%8.2f%7.2f%7.2f%3d%3d%3d%3d\n', ...
	            	ifam,ir,n,xr(n),zr(n),ar(n,1)*pi18,ar(n,2)*pi18,vr(n,1),vr(n,2),layer,iblk,id,iwave);
	        end

	        continue; % go to 500
	    else
	    	hwsl = hws;
	    	if n == ppray
	    	    fun_goto900(); return;
	    	end
	    	n = n + 1;
	        nbnd = nbnd + 1;
	        if nbnd==piray, npskp=1; end
	        if npskp~=1, nbnda(nbnd)=n; end
	        xr(n) = xrp;
	        zr(n) = s(layer,iblk,1) .* xr(n) + b(layer,iblk,1);
	        if xsmax > 0.0 & abs(xr(n)-xr(1)) > xsmax
				vr(n,2) = 0.0;
				iflag = 1;
				ihdwf = 0;
				return;
	        end
	        vp(n,1) = vel(xr(n),zr(n));
	        vs(n,1) = vp(n,1) .* vsvp(layer,iblk);
	        if iwave == 1
	            vr(n,1) = vp(n,1);
	        else
	        	vr(n,1) = vs(n,1);
	        end
	        ar(n,1) = ar(n-1,2);
	        vp(n,2) = vp(n,1);
	        vs(n,2) = vs(n,1);
	        vr(n,2) = vr(n,1);
	        ar(n,2) = ar(n,1);
	        if invr == 1 & ir > 0
	            [layer,iblk,n] = fun_velprt(layer,iblk,n);
	        end
	        dhw = dhw + hws;
	        % go to 1000
	        break;
		end
	end % -------------------- cycle500 end
	end % -------------------- cycle1000 end
	return;

	% ------------------------------------------------------------
	function fun_goto999()
		vr(n,2) = 0.0;
		iflag = 1;
		ihdwf = 0;
		return;
	end % fun_goto999 end

	% ------------------------------------------------------------
	function fun_goto900()
		% 25
		fprintf(fID_11, '***  ray stopped - consists of too many points  ***\n');
		vr(n,2) = 0.0;
		iflag = 1;
		ihdwf = 0;
		return;
	end % fun_goto900 end

end % fun_hdwave end

% --------------------------------------------------------------------------------

% inv.f
function [lu,iu,v1,v2,a1,a2,alphaalpha,npt,itype] = fun_bndprt(lu,iu,v1,v2,a1,a2,alphaalpha,npt,itype)
% calculate boundary partial derivatives

	global file_rayinvr_par file_rayinvr_com;
	run(file_rayinvr_par);
	run(file_rayinvr_com);

	if iabs(itype)==2, a2=pi-2; end
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

% --------------------------------------------------------------------------------

% trc.f
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

% --------------------------------------------------------------------------------

% inv.f
function [lu,iu,npt] = fun_velprt(lu,iu,npt)
% calculate velocity partial derivatives

    global file_rayinvr_par file_rayinvr_com;
    run(file_rayinvr_par);
    run(file_rayinvr_com);

    for jj = 1:4 % 10
        if ivv(lu,iu,jj) ~= 0
            jv = ivv(lu,iu,jj);
            sl = sqrt((xr(npt)-xr(npt-1)).^2 + (zr(npt)-zr(npt-1)).^2);
            v1 = vr(npt-1,2);
            v2 = vr(npt,1);
            dvj1 = (cv(lu,iu,jj,1).*xr(npt-1) + cv(lu,iu,jj,2).*xr(npt-1).^2 + ...
                cv(lu,iu,jj,3).*zr(npt-1) + cv(lu,iu,jj,4).*xr(npt-1).*zr(npt-1) + ...
                cv(lu,iu,jj,5)) ./ (c(lu,iu,6).*xr(npt-1) + c(lu,iu,7));
            dvj2 = (cv(lu,iu,jj,1).*xr(npt) + cv(lu,iu,jj,2).*xr(npt).^2 + ...
                cv(lu,iu,jj,3).*zr(npt) + cv(lu,iu,jj,4).*xr(npt).*zr(npt) + ...
                cv(lu,iu,jj,5)) ./ (c(lu,iu,6).*xr(npt) + c(lu,iu,7));
            dvv2 = (dvj1 ./ v1.^2 + dvj2 ./ v2.^2) ./ 2.0;
            fpart(ninv,jv) = fpart(ninv,jv) - sl.*dvv2;
        end
    end % 10
    return;
end % fun_velprt end