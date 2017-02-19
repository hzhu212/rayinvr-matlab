% adjpt.f
function [n,top,bot,lef,rig,ifam,ir,iturn,lstart,istart,invr,iflag,idl,idr,xfr,zfr,ifrpt,iflagf,modout] = fun_adjpt(n,top,bot,lef,rig,ifam,ir,iturn,lstart,istart,invr,iflag,idl,idr,xfr,zfr,ifrpt,iflagf,modout)
% ray has intersected a model boundary so must determine correct
% (x,z) coordinates and angle at boundary

	global file_rayinvr_par file_rayinvr_com;
	run(file_rayinvr_par);
	% real lef
	% integer icasec(5)
	run(file_rayinvr_com);

	icasec = [3,4,1,2,5];

	iconvt = 0;
	if nbnd==piray, npskp=1; end
	npbndm = nptbnd;

	% make appropriate adjustment if point outside current model
	% block is above top boundary and below bottom boundary

	% 100
	while zr(n)<=top & zr(n)>bot % -------------------- cycle100 begin
	    xmmm = (xr(n)+xr(n-1)) ./ 2.0;
	    zmmm = (zr(n)+zr(n-1)) ./ 2.0;
	    am = (ar(n,1)+ar(n-1,2)) ./ 2.0;

	    cycle500 = true;
	    while cycle500 % -------------------- cycle500 begin
		    % 500
		    top = s(layer,iblk,1).*xmmm + b(layer,iblk,1);
		    bot = s(layer,iblk,2).*xmmm + b(layer,iblk,2);
		    if zmmm<=top | zmmm>bot | xmmm<=lef | xmmm>rig
				xr(n) = xmmm;
				zr(n) = zmmm;
				ar(n,1) = am;
				% go to 100
				break;
			else
				xmmm = (xr(n)+xmmm) ./ 2.0;
				zmmm = (zr(n)+zmmm) ./ 2.0;
				am = (ar(n,1)+am) ./ 2.0;
				% go to 500
				continue;
		    end
		end % -------------------- cycle500 end
	end % -------------------- cycle100 end

	% 为方便快速跳转到1001处，构造一个只执行一次的循环，通过break语句实现与goto类似的效果
	for cycle1001 = 1:1 % -------------------- cycle1001 begin
		if zr(n)<=top & xr(n)>lef & xr(n)<=rig
		    % ray intersects upper boundary
		    icase = 1;
		    [~,~,~,~,~,~,~,~,~,xn,zn,an] = fun_adhoc(xr(n-1),zr(n-1),ar(n-1,2),xr(n),zr(n),ar(n,1),s(layer,iblk,1),b(layer,iblk,1),0,xn,zn,an);
		    break; % go to 1001
		end
		if zr(n)<=top & xr(n)>rig
		    % ray intersects upper right corner
		    [~,~,~,~,~,~,~,~,~,xt,zt,at] = fun_adhoc(xr(n-1),zr(n-1),ar(n-1,2),xr(n),zr(n),ar(n,1),s(layer,iblk,1),b(layer,iblk,1),0,xt,zt,at);
		    [~,~,~,~,~,~,~,~,~,xri,zri,ari] = fun_adhoc(xr(n-1),zr(n-1),ar(n-1,2),xr(n),zr(n),ar(n,1),0.0,rig,1,xri,zri,ari);
		    [~,~,~,~,~,~,~,~,~,~,xn,zn,an,icase] = fun_corner(xr(n-1),zr(n-1),xt,zt,at,1,xri,zri,ari,2,xn,zn,an,icase);
		    if icase==2 & iblk<nblk(layer)
		        if ivg(layer,iblk+1)==-1, icase=1; end
		    end
		    break; % go to 1001
		end
		if zr(n)>bot & xr(n)>lef & xr(n)<=rig
		    % ray intersects lower boundary
		    icase = 3;
		    [~,~,~,~,~,~,~,~,~,xn,zn,an] = fun_adhoc(xr(n-1),zr(n-1),ar(n-1,2),xr(n),zr(n),ar(n,1),s(layer,iblk,2),b(layer,iblk,2),0,xn,zn,an);
		    break; % go to 1001
		end
		if zr(n)>bot & xr(n)>rig
		    % ray intersects lower right corner
		    [~,~,~,~,~,~,~,~,~,xb,zb,ab] = fun_adhoc(xr(n-1),zr(n-1),ar(n-1,2),xr(n),zr(n),ar(n,1),s(layer,iblk,2),b(layer,iblk,2),0,xb,zb,ab);
		    [~,~,~,~,~,~,~,~,~,xri,zri,ari] = fun_adhoc(xr(n-1),zr(n-1),ar(n-1,2),xr(n),zr(n),ar(n,1),0.0,rig,1,xri,zri,ari);
		    [~,~,~,~,~,~,~,~,~,~,xn,zn,an,icase] = fun_corner(xr(n-1),zr(n-1),xb,zb,ab,3,xri,zri,ari,2,xn,zn,an,icase);
		    if icase==2 & iblk<nblk(layer)
		        if ivg(layer,iblk+1)==-1, icase=3; end
		    end
		    break; % go to 1001
		end
		if xr(n)>rig & zr(n)>top & zr(n)<=bot
		    % ray intersects right boundary
		    icase = 2;
		    [~,~,~,~,~,~,~,~,~,xn,zn,an] = fun_adhoc(xr(n-1),zr(n-1),ar(n-1,2),xr(n),zr(n),ar(n,1),0.0,rig,1,xn,zn,an);
		    break; % go to 1001
		end
		if zr(n)<=top & xr(n)<=lef
		    % ray intersects upper left corner
		    [~,~,~,~,~,~,~,~,~,xt,zt,at] = fun_adhoc(xr(n-1),zr(n-1),ar(n-1,2),xr(n),zr(n),ar(n,1),s(layer,iblk,1),b(layer,iblk,1),0,xt,zt,at);
		    [~,~,~,~,~,~,~,~,~,xl,zl,al] = fun_adhoc(xr(n-1),zr(n-1),ar(n-1,2),xr(n),zr(n),ar(n,1),0.0,lef,1,xl,zl,al);
		    [~,~,~,~,~,~,~,~,~,~,xn,zn,an,icase] = fun_corner(xr(n-1),zr(n-1),xt,zt,at,1,xl,zl,al,4,xn,zn,an,icase);
		    if icase == 4 & iblk > 1
		        if ivg(layer,iblk-1)==-1, icase=1; end
		    end
		    break; % go to 1001
		end
		if xr(n)<=lef & zr(n)>top & zr(n)<=bot
		    % ray intersects left boundary
		    icase = 4;
		    [~,~,~,~,~,~,~,~,~,xn,zn,an] = fun_adhoc(xr(n-1),zr(n-1),ar(n-1,2),xr(n),zr(n),ar(n,1),0.0,lef,1,xn,zn,an);
		    break; % go to 1001
		end
		if zr(n)>bot & xr(n)<=lef
		    % ray intersects lower left corner
		    [~,~,~,~,~,~,~,~,~,xb,zb,ab] = fun_adhoc(xr(n-1),zr(n-1),ar(n-1,2),xr(n),zr(n),ar(n,1),s(layer,iblk,2),b(layer,iblk,2),0,xb,zb,ab);
		    [~,~,~,~,~,~,~,~,~,xl,zl,al] = fun_adhoc(xr(n-1),zr(n-1),ar(n-1,2),xr(n),zr(n),ar(n,1),0.0,lef,1,xl,zl,al);
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

	ar(n,1) = an;
	if fid .* ar(n,1) < 0.0
	    id = -id;
	    fid = id; % fid = float(id)
	end
	if fid .* ar(n,1) > pi
	    ar(n,1) = fid .* pit2 + ar(n,1);
        id = -id;
        fid = id; % fid = float(id)
	end
	xr(n) = xn;
	zr(n) = zn;
	vp(n,1) = vel(xn,zn);
	vs(n,1) = vp(n,1) .* vsvp(layer,iblk);
	if iwave == 1
	    vr(n,1) = vp(n,1);
	else
		vr(n,1) = vs(n,1);
	end

	lstart = layer;
	istart = iblk;

    % go to (1000,2000,3000,4000), icase

    % 1000 % -------------------- block 1000 begin
    if icase == 1
    	% ray intersects upper boundary
    	if ibsmth == 0
    	    alpha = atan(s(layer,iblk,1));
    	else
			npl = ifix((xr(n)-xmin-0.001)./xsinc) + 1;
			npr = npl + 1;
			xpl = xmin + (npl-1) .* xsinc;
			alpha = (cosmth(layer,npr)-cosmth(layer,npl)) .* (xr(n)-xpl) ./ xsinc + cosmth(layer,npl);
    	end
    	a1 = pi - fid .* (ar(n,1)+alpha);
    	if abs(a1)>=pi2 & n3<=nstepr & dstepf<1.0e6
    	    % go to 999
    	    fun_goto999(); return;
    	end
    	n3 = 0;
    	dstepf = 1.0;

    	% check to see if ray is at top of model

    	% if(layer.gt.1) go to 1300
    	if layer <= 1
    	    if refll(ircbnd) ~= -1
    	        vr(n,2) = 1.0;
                ar(n,2) = 0.0;
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
    	vi = vel(xr(n),zr(n));
    	if iwave == -1
    	    vi = vi .* vsvp(layer,iblk);
    	end
    	if layer > 1
    	    % 1320
    	    i1 = layer - 1;
    	    [xn,i1,ib] = fun_block(xn,i1,ib);
    	end

        return;
    end % -------------------- block 1000 end

    % 3000 % -------------------- block 3000 begin
    if icase == 3
        return;
    end % -------------------- block 3000 end

    % 2000
    if icase == 2
        ;
    end

    % 4000
    if icase == 4
        ;
    end

    % --------------------------------------------------
    function fun_goto999()
    	n3 = n3 + 1;
    	n = n - 1;
    	nbnd = nbnd - 1;
    	nptbnd = npbndm;
    	dstepf = dstepf .* 2.0;
    	return;
    end % fun_goto999 end

end % fun_adjpt end

% --------------------------------------------------------------------------------

% adjpt.f
function [ir,n,xfr,zfr,ifrpt,modout,invr] = fun_frefl(ir,n,xfr,zfr,ifrpt,modout,invr)
% calculate angles of incidence and reflection at floating reflector

    global file_rayinvr_par file_rayinvr_com;
    global fID_32;
    run(file_rayinvr_par);
    run(file_rayinvr_com);

    d1 = ((xr(n-1)-xfr).^2 + (zr(n-1)-zfr).^2).^0.5;
    d2 = ((xr(n)-xfr).^2 + (zr(n)-zfr).^2).^0.5;
    if (d1+d2) == 0.0
        ar(n,1) = (ar(n-1,2)+ar(n,1)) ./ 2.0;
    else
        ar(n,1) = (d1.*ar(n,1) + d2.*ar(n-1,2)) ./ (d1+d2);
    end
    xr(n) = xfr;
    zr(n) = zfr;
    if ir>0 & modout == 1
        % fprintf(fID_32,'%10.3f%10.3f%10d\n',xfr,zfr);
    end
    slope = (zfrefl(ifcbnd,ifrpt+1)-zfrefl(ifcbnd,ifrpt)) ./ (xfrefl(ifcbnd,ifrpt+1)-xfrefl(ifcbnd,ifrpt));
    alpha = atan(slope);
    a1 = fid .* (ar(n,1)+alpha);
    a2 = a1;
    ar(n,2) = fid .* (pi-a2) - alpha;
    vp(n,1) = vel(xr(n),zr(n));
    vs(n,1) = vp(n,1) .* vsvp(layer,iblk);
    vr(n,1) = vp(n,1);
    if iwave==-1, vr(n,1)=vs(n,1); end
    vr(n,2) = vr(n,1);
    vp(n,2) = vp(n,1);
    vs(n,2) = vs(n,1);
    if (fid .* ar(n,2) < 0.0)
        id = -id;
        fid = id; % fid = float(id)
    end
    if fid .* ar(n,2) > pi
        ar(n,2) = fid .* pit2 + ar(n,2);
        id = -id;
        fid = id; %fid = float(id)
    end
    idray(2) = 4;
    n2 = 0;
    n3 = 0;
    icasel = 5;
    dstepf = 1.0;
    nptbnd = n;
    nbnd = nbnd + 1;
    if npskp~=1, nbnda(nbnd)=n; end
    if ir ~= 0 & invr == 1
        [vr(n,1),a1,alpha,n,ifrpt] = fun_frprt(vr(n,1),a1,alpha,n,ifrpt);
    end
    return;
end % fun_frefl end

% --------------------------------------------------------------------------------

% inv.f
function [vfr,afr,alpha,npt,ifrpt] = fun_frprt(vfr,afr,alpha,npt,ifrpt)
% calculate partial derivatives for floating reflectors

    global file_rayinvr_par file_rayinvr_com;
    run(file_rayinvr_par);
    run(file_rayinvr_com);

    x1 = xfrefl(ifcbnd,ifrpt);
    x2 = xfrefl(ifcbnd,ifrpt+1);

    for ii = ifrpt:ifrpt+1 % 10
        if ivarf(ifcbnd,ii) > 0
            jv = ivarf(ifcbnd,ii);
            if x2-x1 ~= 0.0
                if ii == ifrpt
                    ind = ifrpt + 1;
                else
                    ind = ifrpt;
                end
                slptrm = cos(alpha) .* abs(xfrefl(ifcbnd,ind)-xr(npt)) ./ (x2-x1);
            else
                slptrm = 1.0;
            end
            fpart(ninv,jv) = fpart(ninv,jv) + 2.0.*(cos(afr)./vfr).*slptrm;
        end
    end % 10
    return;

end % fun_frprt end

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