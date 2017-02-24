% adjpt.f
% [n,top,bot,~,~,~,~,~,lstart,istart,~,iflag,~,~,~,~,~,~,~]
% called by: fun_trace;
% call: fun_adhoc; fun_corner; fun_block; fun_bndprt; fun_frefl; fun_vel; done.

function [n,top,bot,lef,rig,ifam,ir,iturn,lstart,istart,invr,iflag,idl,idr,xfr,zfr,ifrpt,iflagf,modout] = fun_adjpt(n,top,bot,lef,rig,ifam,ir,iturn,lstart,istart,invr,iflag,idl,idr,xfr,zfr,ifrpt,iflagf,modout)
% ray has intersected a model boundary so must determine correct
% (x,z) coordinates and angle at boundary

	global file_rayinvr_par file_rayinvr_com;
	global fID_11 fID_32;
	run(file_rayinvr_par);
	% real lef
	% integer icasec(5)
	run(file_rayinvr_com);

	[xn,zn,an,xb,zb,ab,xt,zt,at,xl,zl,al,xri,zri,ari] = deal([]); % for fun_adhoc
	ib = []; % for fun_block
	icase = []; % for fun_corner

	icasec = [3,4,1,2,5];

	iconvt = 0;
	if nbnd==piray, npskp=1; end
	npbndm = nptbnd;

	% make appropriate adjustment if point outside current model
	% block is above top boundary and below bottom boundary

	% 100 % -------------------- cycle100 begin
	while (zr(n) <= top && zr(n) > bot)

		isGoto100 = false;

	    xmmm = (xr(n)+xr(n-1)) ./ 2.0;
	    zmmm = (zr(n)+zr(n-1)) ./ 2.0;
	    am = (arar(n,1)+arar(n-1,2)) ./ 2.0;

	    % 500 % -------------------- cycle500 begin
	    cycle500 = true;
	    while cycle500
		    top = s(layer,iblk,1).*xmmm + b(layer,iblk,1);
		    bot = s(layer,iblk,2).*xmmm + b(layer,iblk,2);
		    if zmmm<=top | zmmm>bot | xmmm<=lef | xmmm>rig
				xr(n) = xmmm;
				zr(n) = zmmm;
				arar(n,1) = am;
				isGoto100 = true; break; % go to 100 step1
			else
				xmmm = (xr(n)+xmmm) ./ 2.0;
				zmmm = (zr(n)+zmmm) ./ 2.0;
				am = (arar(n,1)+am) ./ 2.0;
				continue; % go to 500
		    end
		    break; % go to nothing
		end % -------------------- cycle500 end
		if isGoto100, continue; end % go to 100 step2
		break; % go to nothing
	end % -------------------- cycle100 end

	% 为方便快速跳转到1001处，构造一个只执行一次的循环，通过break语句实现与goto类似的效果
	for cycle1001 = 1:1 % -------------------- cycle1001 begin
		if zr(n)<=top & xr(n)>lef & xr(n)<=rig
		    % ray intersects upper boundary
		    icase = 1;
		    [~,~,~,~,~,~,~,~,~,xn,zn,an] = fun_adhoc(xr(n-1),zr(n-1),arar(n-1,2),xr(n),zr(n),arar(n,1),s(layer,iblk,1),b(layer,iblk,1),0,xn,zn,an);
		    break; % go to 1001
		end
		if zr(n)<=top & xr(n)>rig
		    % ray intersects upper right corner
		    [~,~,~,~,~,~,~,~,~,xt,zt,at] = fun_adhoc(xr(n-1),zr(n-1),arar(n-1,2),xr(n),zr(n),arar(n,1),s(layer,iblk,1),b(layer,iblk,1),0,xt,zt,at);
		    [~,~,~,~,~,~,~,~,~,xri,zri,ari] = fun_adhoc(xr(n-1),zr(n-1),arar(n-1,2),xr(n),zr(n),arar(n,1),0.0,rig,1,xri,zri,ari);
		    [~,~,~,~,~,~,~,~,~,~,xn,zn,an,icase] = fun_corner(xr(n-1),zr(n-1),xt,zt,at,1,xri,zri,ari,2,xn,zn,an,icase);
		    if icase==2 & iblk<nblk(layer)
		        if ivg(layer,iblk+1)==-1, icase=1; end
		    end
		    break; % go to 1001
		end
		if zr(n)>bot & xr(n)>lef & xr(n)<=rig
		    % ray intersects lower boundary
		    icase = 3;
		    [~,~,~,~,~,~,~,~,~,xn,zn,an] = fun_adhoc(xr(n-1),zr(n-1),arar(n-1,2),xr(n),zr(n),arar(n,1),s(layer,iblk,2),b(layer,iblk,2),0,xn,zn,an);
		    break; % go to 1001
		end
		if zr(n)>bot & xr(n)>rig
		    % ray intersects lower right corner
		    [~,~,~,~,~,~,~,~,~,xb,zb,ab] = fun_adhoc(xr(n-1),zr(n-1),arar(n-1,2),xr(n),zr(n),arar(n,1),s(layer,iblk,2),b(layer,iblk,2),0,xb,zb,ab);
		    [~,~,~,~,~,~,~,~,~,xri,zri,ari] = fun_adhoc(xr(n-1),zr(n-1),arar(n-1,2),xr(n),zr(n),arar(n,1),0.0,rig,1,xri,zri,ari);
		    [~,~,~,~,~,~,~,~,~,~,xn,zn,an,icase] = fun_corner(xr(n-1),zr(n-1),xb,zb,ab,3,xri,zri,ari,2,xn,zn,an,icase);
		    if icase==2 & iblk<nblk(layer)
		        if ivg(layer,iblk+1)==-1, icase=3; end
		    end
		    break; % go to 1001
		end
		if xr(n)>rig & zr(n)>top & zr(n)<=bot
		    % ray intersects right boundary
		    icase = 2;
		    [~,~,~,~,~,~,~,~,~,xn,zn,an] = fun_adhoc(xr(n-1),zr(n-1),arar(n-1,2),xr(n),zr(n),arar(n,1),0.0,rig,1,xn,zn,an);
		    break; % go to 1001
		end
		if zr(n)<=top & xr(n)<=lef
		    % ray intersects upper left corner
		    [~,~,~,~,~,~,~,~,~,xt,zt,at] = fun_adhoc(xr(n-1),zr(n-1),arar(n-1,2),xr(n),zr(n),arar(n,1),s(layer,iblk,1),b(layer,iblk,1),0,xt,zt,at);
		    [~,~,~,~,~,~,~,~,~,xl,zl,al] = fun_adhoc(xr(n-1),zr(n-1),arar(n-1,2),xr(n),zr(n),arar(n,1),0.0,lef,1,xl,zl,al);
		    [~,~,~,~,~,~,~,~,~,~,xn,zn,an,icase] = fun_corner(xr(n-1),zr(n-1),xt,zt,at,1,xl,zl,al,4,xn,zn,an,icase);
		    if icase == 4 & iblk > 1
		        if ivg(layer,iblk-1)==-1, icase=1; end
		    end
		    break; % go to 1001
		end
		if xr(n)<=lef & zr(n)>top & zr(n)<=bot
		    % ray intersects left boundary
		    icase = 4;
		    [~,~,~,~,~,~,~,~,~,xn,zn,an] = fun_adhoc(xr(n-1),zr(n-1),arar(n-1,2),xr(n),zr(n),arar(n,1),0.0,lef,1,xn,zn,an);
		    break; % go to 1001
		end
		if zr(n)>bot & xr(n)<=lef
		    % ray intersects lower left corner
		    [~,~,~,~,~,~,~,~,~,xb,zb,ab] = fun_adhoc(xr(n-1),zr(n-1),arar(n-1,2),xr(n),zr(n),arar(n,1),s(layer,iblk,2),b(layer,iblk,2),0,xb,zb,ab);
		    [~,~,~,~,~,~,~,~,~,xl,zl,al] = fun_adhoc(xr(n-1),zr(n-1),arar(n-1,2),xr(n),zr(n),arar(n,1),0.0,lef,1,xl,zl,al);
		    [~,~,~,~,~,~,~,~,~,~,xn,zn,an,icase] = fun_corner(xr(n-1),zr(n-1),xb,zb,ab,3,xl,zl,al,4,xn,zn,an,icase);
		    if icase == 4 & iblk > 1
		        if ivg(layer,iblk-1)==-1, icase=3; end
		    end
		    break; % go to 1001
		end
	end % -------------------- cycle1001 end

	% check to see if ray has crossed a floating reflector before
	% leaving the current trapezoid

	% 1001
	if iflagf == 1
	    dfrefl = ((xfr-xr(n-1)).^2 + (zfr-zr(n-1)).^2) .^ 0.5;
        dtrap = ((xn-xr(n-1)).^2 + (zn-zr(n-1)).^2) .^ 0.5;
        if dfrefl <= dtrap
            lstart = layer;
            istart = iblk;
            [ir,n,xfr,zfr,ifrpt,modout,invr] = fun_frefl(ir,n,xfr,zfr,ifrpt,modout,invr);
            return;
        end
	end

	% check to see if ray has crossed the same boundary in two
	% successive points

	if nptbnd > 0
	    if nptbnd == n-1
	        if icasec(icase) == icasel
	            if n2 > nstepr
	                n2 = 0;
	                icasel = icase;
	            else
	            	n2 = n2 + 1;
	            	n = n - 1;
	            	dstepf = dstepf .* 2.0;
	            	return;
	            end
	        else
	        	n2 = 0;
	        	icasel = icase;
	        end
	    else
	    	n2 = 0;
	    	icasel = icase;
	    end
	else
		if n==2 & layer==1 & icase==1
		    if n2 > nstepr
		        n2 = 0;
		        icasel = icase;
		    else
		    	n2 = n2 + 1;
	            n = 1;
	            dstepf = dstepf .* 2.0;
	            nptbnd = 0;
	            return;
		    end
		else
			n2 = 0;
			icasel = icase;
		end
	end
	nbnd = nbnd + 1;
	if npskp~=1, nbnda(nbnd)=n; end
	nptbnd = n;

	arar(n,1) = an;
	if fid .* arar(n,1) < 0.0
	    id = -id;
	    fid = id; % fid = float(id)
	end
	if fid .* arar(n,1) > pi
	    arar(n,1) = fid .* pit2 + arar(n,1);
        id = -id;
        fid = id; % fid = float(id)
	end
	xr(n) = xn;
	zr(n) = zn;
	vp(n,1) = fun_vel(xn,zn);
	vs(n,1) = vp(n,1) .* vsvp(layer,iblk);
	if iwave == 1
	    vr(n,1) = vp(n,1);
	else
		vr(n,1) = vs(n,1);
	end

	lstart = layer;
	istart = iblk;

    % go to (1000,2000,3000,4000), icase

    % ray intersects upper boundary

    % 1000 % -------------------- block 1000 begin
    if ~(icase == 3 | icase == 2 | icase == 4)
    	% ray intersects upper boundary
    	if ibsmth == 0
    	    alphaalpha = atan(s(layer,iblk,1));
    	else
			npl = fix((xr(n)-xmin-0.001)./xsinc) + 1; % ifix -> fix
			npr = npl + 1;
			xpl = xmin + (npl-1) .* xsinc;
			alphaalpha = (cosmth(layer,npr)-cosmth(layer,npl)) .* (xr(n)-xpl) ./ xsinc + cosmth(layer,npl);
    	end
    	a1 = pi - fid .* (arar(n,1)+alphaalpha);
    	if abs(a1)>=pi2 & n3<=nstepr & dstepf<1.0e6
    	    % go to 999
    	    [n3,n,nbnd,nptbnd,~,dstepf] = fun_goto999(n3,n,nbnd,nptbnd,npbndm,dstepf);
    	    return;
    	end
    	n3 = 0;
    	dstepf = 1.0;

    	% check to see if ray is at top of model

    	% if(layer.gt.1) go to 1300
    	if layer <= 1
    	    if refll(ircbnd) ~= -1
    	        vr(n,2) = 1.0;
                arar(n,2) = 0.0;
                iflag = 1;
                return;
            else
            	vp2 = 0.001;
		        vs2 = 0.001;
		        vo = 0.001;
    	    end
    	end

    	% 1300
    	nccbnd = nccbnd + 1;
    	if icbnd(iccbnd) == nccbnd
    	    iconvt = 1;
            iwave = -iwave;
            iccbnd = iccbnd + 1;
    	end
    	vi = fun_vel(xr(n),zr(n));
    	if iwave == -1
    	    vi = vi .* vsvp(layer,iblk);
    	end
    	if layer > 1
    		isGoto1330 = false;
    		% 1320 % -------------------- cycle1320 begin
    	    cycle1320 = true;
    	    while cycle1320
	    	    isGoto1330 = false;

	    	    i1 = layer - 1;
	    	    [~,~,ib] = fun_block(xn,i1,ib);

	    	    if ivg(i1,ib) ~= -1, break; end % go to 1310

    	        layer = layer - 1;
    	        if refll(ircbnd) == -layer
    	            if ir ~= 0
    	            	% 55
    	                fprintf(fID_11, '***  ray stopped - reflected from pinchout  ***\n');
    	            end
	                vr(n,2) = 0.0;
	                iflag = 1;
	                return;
    	        end

    	        if layer > 1, continue; end % go to 1320

    	        if refll(ircbnd) ~= -1
    	            vr(n,2) = 1.0;
    	            iflag = 1;
    	            return;
    	        else
    	        	vp2 = 0.001;
    	        	vs2 = 0.001;
    	        	vo = 0.001;
    	        	isGoto1330 = true;
    	        	break; % go to 1330
    	        end

	    	    break; % go to nothing
	    	end % -------------------- cycle1320 end

	    	% 1310 % -------------------- block 1310 begin
	    	if ~isGoto1330
	    	    vp2 = (c(i1,ib,1).*xn + c(i1,ib,2).*xn.^2 + c(i1,ib,3).*zn + c(i1,ib,4).*xn.*zn + c(i1,ib,5)) ./ (c(i1,ib,6).*xn + c(i1,ib,7));
	    	    vs2 = vp2 .* vsvp(i1,ib);
	    	    if iwave == 1
	    	        vo = vp2;
	    	    else
	    	    	vo = vs2;
	    	    end
	    	end % -------------------- block 1310 end
    	end

    	isGoto1110 = false;
    	isGoto1100 = false;
    	isGoto1200 = false;
    	% 1330 % -------------------- one-time cycle1330 begin
    	for cycle1330 = 1:1
	    	if refll(ircbnd) == -lstart
	    	    layer = lstart;
		        ircbnd = ircbnd + 1;
		        if iconvt == 0
		            a2 = a1;
		            isGoto1110 = true;
		            break; % go to 1110
		        end
		        at1 = (vi./vr(n,1)) .* sin(a1);
		        if abs(at1) < 1.0
		            isGoto1100 = true;
		            break; % go to 1100
		        end
		        if ir ~= 0
		        	% 35
		            fprintf(fID_11, '***  ray stopped - converted ray cannot reflect/refract  ***\n');
		        end
	            vr(n,2) = 0.0;
	            iflag = 1;
	            return;
	    	end
	        at2 = (vo./vr(n,1)) .* sin(a1);
	        if abs(at2) < 1.0
	        	isGoto1200 = true;
	            break; % go to 1200
	        end

	        % ray reflects off upper boundary

	        if istop > 0 | ir == 0
	            vr(n,2) = 0.0;
	            iflag = 1;
	            if ir ~= 0
	            	% 15
	                fprintf(fID_11, '***  ray stopped - illegal reflection  ***\n');
	            end
                return;
	        end
	        if iconvt == 0
	            a2 = a1;
	            isGoto1110 = true;
	            break; % go to 1110
	        end
	        at1 = (vi./vr(n,1)) .* sin(a1);
	        if abs(at1) >= 1.0
	            if ir ~= 0
	            	% 35
	                fprintf(fID_11, '***  ray stopped - converted ray cannot reflect/refract  ***\n');
	            end
	            vr(n,2) = 0.0;
	            iflag = 1;
	            return;
	        end
    	end % -------------------- one-time cycle1330 end

    	% 1100
    	if ~(isGoto1200 | isGoto1110)
    	    a2 = asin(at1);
    	end
    	% 1110
    	if ~isGoto1200
			arar(n,2) = fid .* a2 - alphaalpha;
			vr(n,2) = vi;
			vp(n,2) = vp(n,1);
			vs(n,2) = vs(n,1);
			if fid.*arar(n,2) > 0.0
			    id = -id;
			    fid = id; % fid = float(id)
			end
			if vm(layer,iblk,1) == 0.0
			    layer = lstart;
			    iblk = istart;
			end
			if ir~=0 & invr==1
			    [~,~,~,~,~,~,~,~,~] = fun_bndprt(lstart,istart,vr(n,1),vr(n,2),a1,a2,alphaalpha,n,-2);
			end
			return;
    	end

    	% ray refracts through upper boundary

    	% 1200
		layer = layer - 1;
		iblk = ib;
		a2 = asin(at2);
		arar(n,2) = fid .* (pi-a2) - alphaalpha;
		vr(n,2) = vo;
		vp(n,2) = vp2;
		vs(n,2) = vs2;
		if iwave == -1 & vr(n,2) <= 0.001
		    vr(n,2) = 0.0;
		    iflag = 1;
		    if ir ~= 0
		    	% 45
		        fprintf(fID_11, '***  ray stopped - s-wave cannot propagate  ***\n');
		    end
		    return;
		end
		if fid.*arar(n,2) > pi
			arar(n,2) = fid .* pit2 + arar(n,2);
			id = -id;
			fid = id; % fid = float(id);
		end
		if ir~=0 & invr==1
		    [~,~,~,~,~,~,~,~,~] = fun_bndprt(lstart,istart,vr(n,1),vr(n,2),a1,a2,alphaalpha,n,-1);
		end
        return;
    end % -------------------- block 1000 end

    % ray intersects lower boundary

    % 3000 % -------------------- block 3000 begin
    if ~(icase == 2 | icase == 4)
    	if layer == nlayer
    	    vr(n,2) = 0.0;
    	    iflag = 1;
    	    return;
    	end
    	if ibsmth == 0
    	    alphaalpha = atan(s(layer,iblk,2));
    	else
			npl = fix((xr(n)-xmin-0.001)./xsinc) + 1; % ifix -> fix
			npr = npl + 1;
			xpl = xmin + (npl-1) .* xsinc;
			alphaalpha = (cosmth(layer+1,npr)-cosmth(layer+1,npl)) .* (xr(n)-xpl) ./ xsinc + cosmth(layer+1,npl);
    	end
    	a1 = fid .* (arar(n,1)+alphaalpha);
    	if abs(a1)>=pi2 & n3<=nstepr & dstepf< 1.0e6
    	    [n3,n,nbnd,nptbnd,~,dstepf] = fun_goto999(n3,n,nbnd,nptbnd,npbndm,dstepf);
    	    return; % go to 999
    	end
    	n3 = 0;
    	dstepf = 1.0;
    	nccbnd = nccbnd + 1;
    	if icbnd(iccbnd) == nccbnd
    	    iconvt = 1;
	        iwave = -iwave;
	        iccbnd = iccbnd + 1;
    	end
    	vi = fun_vel(xr(n),zr(n));
    	if iwave == -1
    	    vi = vi .* vsvp(layer,iblk);
    	end

    	% 3020 % -------------------- cycle3020 begin
    	cycle3020 = true;
    	while cycle3020
	    	i1 = layer + 1;
	    	[~,~,ib] = fun_block(xn,i1,ib);
	    	if ivg(i1,ib) ~= -1
	    	    break; % go to 3010
	    	end
	    	layer = layer + 1;
	    	if refll(ircbnd) == layer
	    	    if ir ~= 0
	    	    	% 55
	    	        fprintf(fID_11, '***  ray stopped - reflected from pinchout  ***\n');
	    	        vr(n,2) = 0.0;
	    	    end
	    	    if idray(1) < layer, idray(1)=layer; end
	    	    idray(2) = 2;
	    	    iflag = 1;
	    	    return;
	    	end
	    	if layer == nlayer
	    	    vr(n,2) = 0.0;
	    	    iflag = 1;
	    	    return;
	    	end
	    	continue; % go to 3020
	    	break; % go to nothing
	    end % -------------------- cycle3020 end

	    isGoto3110 = false;
	    isGoto3100 = false;
	    isGoto3200 = false;
	    isGoto3300 = false;
	    % 3010 % -------------------- one-time cycle3010 begin
	    for cycle3010 = 1:1
		    vp2 = (c(i1,ib,1).*xn + c(i1,ib,2).*xn.^2 + c(i1,ib,3).*zn + c(i1,ib,4).*xn.*zn + c(i1,ib,5)) ./ (c(i1,ib,6).*xn + c(i1,ib,7));
		    vs2 = vp2 .* vsvp(i1,ib);
		    if iwave == 1
		        vo = vp2;
		    else
		    	vo = vs2;
		    end
		    if refll(ircbnd) == lstart
		        layer = lstart;
		        ircbnd = ircbnd + 1;
		        if iconvt == 0
		            a2 = a1;
		            isGoto3110 = true;
		            break; % go to 3110
		        end
		        at1 = (vi./vr(n,1)) .* sin(a1);
		        if abs(at1) < 1.0
		            isGoto3100 = true;
		            break; % go to 3100
		        end
		        if ir ~= 0
		        	% 35
		            fprintf(fID_11, '***  ray stopped - converted ray cannot reflect/refract  ***\n');
		        end
		        vr(n,2) = 0.0;
		        iflag = 1;
		        return;
		    end
		    if iheadf(layer) == 1 & idifff == 1
		        isGoto3300 = true;
		        break; % go to 3300
		    end
		    if iheadf(layer) == 1 & vr(n,1) < vo
		        crita = asin(vr(n,1)./vo);
		        diff = abs(abs(a1)-crita);
		        if fid ~= fid1
		            fid = fid1;
		            id = -id;
		        end
		        if diff <= crit
		            isGoto3300 = true;
		            break; % go to 3300
		        end
		    end
	        at2 = (vo./vr(n,1)) .* sin(a1);
	        if abs(at2) < 1.0
	            isGoto3200 = true;
	            break; % go to 3200
	        end

	        % ray reflects off lower boundary

	        if istop > 0 | ir == 0
	            vr(n,2) = 0.0;
	            iflag = 1;
	            if ir ~= 0
	            	% 15
	                fprintf(fID_11, '***  ray stopped - illegal reflection  ***\n');
	            end
	            idray(2) = 2;
	            return;
	        end
	        if iconvt == 0
	            a2 = a1;
	            isGoto3110 = true;
	            break; % go to 3110
	        end
	        at1 = (vi./vr(n,1)) .* sin(a1);
	        if abs(at1) >= 1.0
	            if ir ~= 0
	            	% 35
	                fprintf(fID_11, '***  ray stopped - converted ray cannot reflect/refract  ***\n');
	            end
	            vr(n,2) = 0.0;
	            iflag = 1;
	            return;
	        end
	    end % -------------------- one-time cycle3010 end

        % 3100 % -------------------- block 3100 begin
        if ~(isGoto3110 | isGoto3200 | isGoto3300)
            a2 = asin(at1);
        end % -------------------- block 3100 end

        % 3110 % -------------------- block 3110 begin
        if ~(isGoto3200 | isGoto3300)
			arar(n,2) = fid .* (pi-a2) - alphaalpha;
			vr(n,2) = vi;
			vp(n,2) = vp(n,1);
			vs(n,2) = vs(n,1);
			if fid.*arar(n,2) > pi
			    arar(n,2) = fid .* pit2 + arar(n,2);
		        id = -id;
		        fid = id; % fid = float(id);
			end
			if ir ~= 0 | idr ~= 1
			    idray(2) = 2;
			end
			if iturn == 1 & idr == 2
			    iflag = 1;
			end
			if vm(layer,iblk,1) == 0.0
			    layer = lstart;
			    iblk = istart;
			end
			if ir ~= 0 & invr == 1
			    [~,~,~,~,~,~,~,~,~] = fun_bndprt(lstart,istart,vr(n,1),vr(n,2),a1,a2,alphaalpha,n,2);
			end
			if ir > 0 & modout == 1
				% 155
			    fprintf(fID_32, '%10.3f%10.3f%10d\n', xr(n),zr(n),0);
			end
			return;
        end % -------------------- block 3110 end

        % ray refracts through lower boundary

        % 3200 % -------------------- block 3200 begin
        if ~isGoto3300
            if istop > 0 & idray(2) == 3
                vr(n,2) = 0.0;
                iflag = 1;
                if ir ~= 0
                	% 115
                    fprintf(fID_11, '***  ray stopped - illegal headwave refraction  ***\n');
                end
                return;
            end
            if ir ~= 0 & istop == 2 & (layer+1) > idl
                vr(n,2) = 0.0;
                iflag = 1;
                if ir ~= 0
                    % 125
                    fprintf(fID_11, '***  ray stopped - illegal refraction (istop=2)  ***\n');
                end
                return;
            end
            layer = layer + 1;
			iblk = ib;
			a2 = asin(at2);
			arar(n,2) = fid .* a2 - alphaalpha;
			vr(n,2) = vo;
			vp(n,2) = vp2;
			vs(n,2) = vs2;
			if iwave == -1 & vr(n,2) <= 0.001
			    vr(n,2) = 0.0;
			    iflag = 1;
			    % 45
		        fprintf(fID_11, '***  ray stopped - s-wave cannot propagate  ***\n');
		        return;
			end
			if fid.*arar(n,2) < 0.0
			    id = -id;
			    fid = id; % fid = float(id);
			end
			if idray(1)<layer, idray(1)=layer; end
			if ir ~= 0 & invr == 1
			    [~,~,~,~,~,~,~,~,~] = fun_bndprt(lstart,istart,vr(n,1),vr(n,2),a1,a2,alphaalpha,n,1);
			end
			return;
        end % -------------------- block 3200 end

        % head waves to be generated

        % 3300
        if idifff == 1
            at1 = (vi./vr(n,1)) .* sin(a1);
            if abs(at1) >= 1.0
                if ir ~= 0
                    % 35
		            fprintf(fID_11, '***  ray stopped - converted ray cannot reflect/refract  ***\n');
                end
                vr(n,2) = 0.0;
                iflag = 1;
                return;
            end
            a2 = asin(at1);
	        arar(n,2) = fid .* (pi-a2) - alphaalpha;
	    else
	    	arar(n,2) = fid .* pi2 - alphaalpha;
	        a2 = pi2;
        end
		vr(n,2) = vo;
		vp(n,2) = vp2;
		vs(n,2) = vs2;
		ihdw = 1;
		idray(1) = layer;
		if ir ~= 0 & invr == 1
		    [~,~,~,~,~,~,~,~,~] = fun_bndprt(lstart,istart,vr(n,1),vr(n,2),a1,a2,alphaalpha,n,1);
		end
		iflag = 2;
        return;
    end % -------------------- block 3000 end

    % ray intersects right boundary

    % 2000 % -------------------- block 2000 begin
    isGoto4010 = false;
    if ~(icase == 4)
        jt = nblk(layer);
        ja = 1;
        isGoto4010 = true; % go to 4010
    end % -------------------- block 2000 end

    % 4000 % -------------------- block 4000 begin
    % if icase == 4
    if ~isGoto4010
        jt = 1;
        ja = -1;
    end

    % 4010
    if iblk == jt
        vr(n,2) = 0.0;
        iflag = 1;
        return;
    end
	iblk = iblk + ja;
	vp(n,2) = fun_vel(xn,zn);
	vs(n,2) = vp(n,2) .* vsvp(layer,iblk);
	if iwave == 1
	    vr(n,2) = vp(n,2);
	else
		vr(n,2) = vs(n,2);
	end
	vo = vr(n,2);
	vp2 = vp(n,2);
	vs2 = vs(n,2);
	a1 = pi2 - fid .* arar(n,1);
	if abs(a1)>=pi2 & n3<=nstepr & dstepf<1.0e6
		% go to 999
	    [n3,n,nbnd,nptbnd,~,dstepf] = fun_goto999(n3,n,nbnd,nptbnd,npbndm,dstepf);
	    return;
	end
	n3 = 0;
	dstepf = 1.0;
	if fid.*arar(n,1) > pi2, a1 = -a1; end
	at = (vo./vr(n,1)) .* sin(a1);
	if abs(at) >= 1.0
	    % ray reflects off vertical boundary
	    if istop > 0 | ir == 0
	        vr(n,2) = 0.0;
	        iflag = 1;
	        if ir ~= 0
	            % 15
                fprintf(fID_11, '***  ray stopped - illegal reflection  ***\n');
	        end
	        return;
	    end
	    a2 = a1;
        iblk = iblk - ja;
        arar(n,2) = -arar(n,1);
        vr(n,2) = vr(n,1);
        vp(n,2) = vp(n,1);
        vs(n,2) = vs(n,1);
        id = -id;
        fid = id; % fid = float(id);
    else
    	% ray refracts through vertical boundary
    	a2 = asin(at);
    	if fid.*arar(n,1) <= pi2
    	    arar(n,2) = fid .* (pi2-a2);
    	else
    		arar(n,2) = fid .* (pi2+a2);
    	end
    	if iwave == -1 & vr(n,2) <= 0.001
    	    vr(n,2) = 0.0;
    	    iflag = 1;
    	    % 45
	        fprintf(fID_11, '***  ray stopped - s-wave cannot propagate  ***\n');
    	    return;
    	end
	end
	return;
    % end % -------------------- block 4000 end

end % fun_adjpt end

% ----------------------------------------------------------------------

% [n3,n,nbnd,nptbnd,~,dstepf]
function [n3,n,nbnd,nptbnd,npbndm,dstepf] = fun_goto999(n3,n,nbnd,nptbnd,npbndm,dstepf)
% ray has intersected a boundary with an angle of incidence
% beyond 90 degrees

	n3 = n3 + 1;
	n = n - 1;
	nbnd = nbnd - 1;
	nptbnd = npbndm;
	dstepf = dstepf .* 2.0;
	return;
end % fun_goto999 end
