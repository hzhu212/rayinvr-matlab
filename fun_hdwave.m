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

	isGoto10 = true;
	while isGoto10 % -------------------- cycle 10 begin
		isGoto10 = false;
		% 10
		l1 = layer + 1;
		[xr(n),l1,ib] = fun_block(xr(n),l1,ib);

		isGoto20 = false;
		if ivg(l1,ib)~=-1, isGoto20=true; end
		if ~isGoto20
			layer = layer + 1;
			if layer == nlayer
				fun_goto999(); return;
			end
			% go to 10
			isGoto10 = true;
		end
	end % -------------------- cycle 10 end

	% 20
	layer = l1;
	iblk = ib;
	idray(2) = 3;
	hwsl = hws;
	ilr = (id+3) ./ 2;
	irl = (3-id) ./ 2;
	alpha = atan(s(layer,iblk,1));

	% 1000
	if dhw >= (tdhw-0.001)
	    lstart = layer;
        istart = iblk;
        ihdw = 0;
        tdhw = tdhw + hws;
        if dhw == 0.0
            vh = vel(xr(n),zr(n));
            if iwave==-1, vh=vh.*vsvp(layer,iblk); end
        end
        isGoto30 = true;
        while isGoto30 % -------------------- cycle 30 begin
        	isGoto30 = false;
	        % 30
	        l1 = layer - 1;
	        [xr(n),l1,ib] = fun_block(xr(n),l1,ib);
	        isGoto40 = false;
	        if ivg(l1,ib)~=-1, isGoto40=true; end
	        if ~isGoto40
	            layer = layer - 1;
	            if layer == 1
	                % go to 999
	                fun_goto999(); return;
	            end
	            % go to 30
	            isGoto30 = true;
	        end
        end % -------------------- cycle 30 end

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
            alpha = atan(s(layer,iblk,2));
        else
			npl = ifix((xr(n)-xmin-0.001)./xsinc) + 1;
			npr = npl + 1;
			xpl = xmin + (npl-1) .* xsinc;
			alpha = (cosmth(layer+1,npr)-cosmth(layer+1,npl)) .* (xr(n)-xpl) ./ xsinc + cosmth(layer+1,npl);
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
        ar(n,2) = fid .* (pi-a2) - alpha;
        if invr==1 & ir>0
            [lstart,istart,vr(n,1),vr(n,2),pi2,a2,alpha,n,~] = fun_bndprt(lstart,istart,vr(n,1),vr(n,2),pi2,a2,alpha,n,-1);
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

	% ------------------------------------------------------------
	function fun_goto999()
		vr(n,2) = 0.0;
		iflag = 1;
		ihdwf = 0;
		return;
	end % fun_goto999 end
end % fun_hdwave end

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
	error('e:stop','\n***  block undetermined  ***\nlayer=%3d  x=%10.3f\n',layer1,x);
end