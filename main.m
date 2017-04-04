% \bvar\b(\(.*\))*\s*=[^=]
% (\[.*)?\bvar\b(.*\])?(\(.*\))*\s*=[^=]
% rayinvr_par.m, rayinvr_com.m, main_par.m, blkdat.m, input/r.in, -old/*.*

% call: fun_auto; fun_calmod; fun_trace; fun_xzpt; fun_modwr; fun_vel;
% fun_ttime; fun_cells; fun_fxtinv; fun_sort3; fun_calprt; fun_fd;
% fun_load_vin; fun_trans_rin2m; fun_load_txin; fun_load_fin;

% fun_aldone; fun_pltmod; fun_plttx; fun_pltray; fun_empty; fun_plotnd;

function main(pathIn, pathOut)
	% main function for rayinvr, all variables are global
	%
	% <strong>main(pathIn, pathOut)</strong>
	%
	% pathIn: path of input files. You should put all of your ".in" files in this path. Default: 'data\examples\e1'.
	% pathOut: path of output files. Default: pathIn/'output'.

	if nargin < 2
		if nargin < 1
			pathIn = fullfile('data','examples','e3');
		end

		if ~exist(pathIn, 'dir')
		    error('e:IOError','Input path: "%s" not exist',pathIn);
		end

		pathOut = fullfile(pathIn,'output');
		if ~exist(pathOut,'dir')
		    mkdir(pathOut);
		end
	end

	addpath(genpath('./functions'));
	% addpath(genpath(fullfile(pwd(),'functions')));

	% global onDev;
	onDev = false;

	clear('global');
	global file_rayinvr_par file_rayinvr_com file_main_par;
	global fID_11 fID_12 fID_17 fID_19 fID_31 fID_32 fID_33 fID_35;
	global file_iout file_nout;

	% 控制绘图颜色
	global matlabColors currentColor;

	% 图像句柄，1-模型图像，2-走时图像
	global hFigure1 hFigure2;

	file_rayinvr_par = 'rayinvr_par.m';
	file_rayinvr_com = 'rayinvr_com.m';
	file_main_par = 'main_par.m';
	file_block_data = 'blkdat.m';

	file_rin = fullfile(pathIn,'r.in');
	file_vin = fullfile(pathIn,'v.in');
	file_txin = fullfile(pathIn,'tx.in');
	file_fin = fullfile(pathIn,'f.in');

	file_r1out = fullfile(pathOut,'r1.out');
	file_r2out = fullfile(pathOut,'r2.out');
	file_ra1out = fullfile(pathOut,'ra1.out');
	file_ra2out = fullfile(pathOut,'ra2.out');
	file_txout = fullfile(pathOut,'tx.out');
	file_fdout = fullfile(pathOut,'fd.out');
	file_iout = fullfile(pathOut,'i.out');
	file_nout = fullfile(pathOut,'n.out');
	file_tout = fullfile(pathOut,'t.out');
	file_pout = fullfile(pathOut,'p.out');
	file_vout = fullfile(pathOut,'v.out');


	% 1 variables
	% 1.1 声明rayinvr.par文件中的变量并赋值
	run(file_rayinvr_par);

	% 1.2 声明main函数中的变量并赋值
	run(file_main_par);

	% 1.3 声明rayinvr.com文件中的变量并赋值
	run(file_rayinvr_com);

	% 为全局变量赋初值
	run(file_block_data);

	% 1.4 为r.in中的所有变量赋值
	file_rin_m = fun_trans_rin2m(file_rin); % 将r.in文件转化为r_in.m脚本
	run(file_rin_m); % 载入脚本，为r.in中所有变量赋值

    % matlab colors，设定当前颜色为默认色（前景色）
    matlabColors = 'krgbcmyy';
    currentColor = matlabColors(ifcol);

	if onDev, disp('========================= tick 1 ========================='); end

	% 2 main
	% 如果未指定xmax，则程序结束
	if xmax < -99998
		error('e:stop','\n***  xmax not specified  ***\n\n');
	end
	% 如果imodf不等于1，表面速度模型保存在r.in文件的最后部分；否则，有专门的v.in文件保存
	if imodf ~= 1
		% ?... iunit=10 read(10,1)
		error('e:stop','\n***  by HeZhu: model must be load from file v.in, not r.in  ***\n\n');
	end
	if mod(ppcntr,10) ~= 0 || mod(ppvel,10) ~= 0
		fprintf('\n***  array size error for number of model points  ***\n\n');
		fun_goto9999(); return; % go to 9999
	end

	% 2.1 读入v.in
	% [model,LN,xmin,xmax,zmin,zmax,precision,xx,ZZ,mError] = fun_load_vin(file_vin);
	[model,LN,xmin,xmax,zmin,zmax,~,~,~,mError] = fun_load_vin(file_vin);
	error(mError);
	for ii = 1:length(model)
		t_thisLayer = model(ii);
		[~,t_xlen] = size(t_thisLayer.bd);
		[~,t_tvlen] = size(t_thisLayer.tv);
		[~,t_bvlen] = size(t_thisLayer.bv);

		% 调整数组形式，与fortran代码中对应的数组一致
		if t_xlen == 2
		    t_thisLayer.bd = t_thisLayer.bd(:,2);
		    t_xlen = 1;
		end
		if t_tvlen == 2
		    t_thisLayer.tv = t_thisLayer.tv(:,2);
		    t_tvlen = 1;
		end
		if t_bvlen == 2
		    t_thisLayer.bv = t_thisLayer.bv(:,2);
		    t_bvlen = 1;
		end

		xm(ii,1:t_xlen) = t_thisLayer.bd(1,:);
		zm(ii,1:t_xlen) = t_thisLayer.bd(2,:);
		% the last layer has no bd(3), tv and bv, so jump out
		% if ii==length(model)-1, break; end
		if ii==length(model), break; end
		ivarz(ii,1:t_xlen) = t_thisLayer.bd(3,:);

		xvel(ii,1:t_tvlen,1) = t_thisLayer.tv(1,:);
		xvel(ii,1:t_bvlen,2) = t_thisLayer.bv(1,:);
		vf(ii,1:t_tvlen,1) = t_thisLayer.tv(2,:);
		vf(ii,1:t_bvlen,2) = t_thisLayer.bv(2,:);
		ivarv(ii,1:t_tvlen,1) = t_thisLayer.tv(3,:);
		ivarv(ii,1:t_bvlen,2) = t_thisLayer.bv(3,:);
	end

	ncont = LN;
	nlayer = ncont - 1; % 20

	if onDev, disp('========================= tick 2 ========================='); end

	% open I/O units

	% 2.2 开关控制
	if iplot == 0, iplot = -1; end
	if iplot == 2, iplot = 0; end

	fID_11 = fopen(file_r1out,'w');
	if idump == 1, fID_12 = fopen(file_r2out,'w'); end
	if itxout > 0, fID_17 = fopen(file_txout,'w'); end
	if iplot <= 0, fID_19 = fopen(file_pout,'w'); end
	if abs(modout) ~= 0, fID_31= fopen(file_vout,'w'); end
	if i2pt>0 && iray==2 && irays==0 && irayps==0 && iplot<=0
		fID_33 = fopen(file_ra1out,'w');
		fID_34 = fopen(file_ra2out,'w');
		i33 = 1;
	end
	if ifd > 0, fID_35 = fopen(file_fdout,'w'); end

	% read in observed data

	% 930
	% 2.3 读入tx.in文件
	[xpf,tpf,upf,ipf] = fun_load_txin(file_txin);

	if onDev, disp('========================= tick 3 ========================='); end

	% determine if plot parameters for distance axis of travel time plot are
	% same as model distance parameters

	% 设置一些绘图参数
	if xmint<-1000.0, xmint = xmin; end
	if xmaxt<-1000.0, xmaxt = xmax; end
	if xtmint<-1000.0, xtmint = xtmin; end
	if xtmaxt<-1000.0, xtmaxt = xtmax; end
	if xmmt<-1000.0, xmmt = xmm; end
	if ndecxt<-1, ndecxt = ndecix; end
	if ntckxt<0, ntckxt = ntickx; end

	% calculate scale of each plot axis

	% 确定坐标轴的绘图比例，即每mm代表多少km或s
	xscale = (xmax-xmin) ./ xmm;
	xscalt = (xmaxt-xmint) ./ xmmt;
	zscale = -(zmax-zmin) ./ zmm;
	tscale = (tmax-tmin) ./ tmm;

	if itrev==1, tscale = -tscale; end
	if iroute~=1, ibcol = 0; end
	if isep==2 && imod==0 && iray==0 && irays==0, isep = 3; end
	if n2pt>pn2pt, n2pt = pn2pt; end
	if i2pt==0, x2pt = 0; end
	if x2pt< 0.0, x2pt = (xmax-xmin) ./ 2000.0; end

	% 如果colour数组未赋值，则赋默认值
	ncol = 0;
	% 1020 cycle
	ncol = find(colour(1:pcol)>=0,1,'last');
	% 1030
	if isempty(ncol)
		colour = [2,3,4,5,6,8,17,27,22,7];
		ncol = 10;
	end
	% 1040 cycle
	mcol(mcol(1:5) < 0) = ifcol;

	% ngroup: 统计待追踪的射线组的总数
	for ii = 1:prayf % 40
		if ray(ii) < 1.0, break; end % go to 50
		ngroup = ngroup + 1;
	end % 40
	% 50
	if ngroup == 0
		% 55
		fprintf('\n***  no ray codes specified  ***\n\n');
		% go to 900
		fun_goto900(); return;
	end

	ifrbnd = 0;
	for ii = 1:ngroup % 540
		if frbnd(ii) < 0 || frbnd(ii) > pfrefl
			% 565
			error('e:stop','\n***  error in array frbnd  ***\n\n');
		end
		if frbnd(ii) > 0, ifrbnd=1; end
	end % 540

	% 读取f.in文件到xfrefl,zfrefl,ivarf三个二维数组中（类似v.in的结构）
	% 590 % 545 % 555 % 575 % 590 % 595
	if ifrbnd == 1
		[nfrefl,xfrefl,zfrefl,ivarf] = fun_load_fin(file_fin);

		if any( frbnd(1:ngroup) > nfrefl )
			% 585
			error('e:stop','\n***  error in f.in frbnd  ***\n\n');
		end
	end

	if onDev, disp('========================= tick 4 ========================='); end

	% calculate velocity model parameters

	iflagm = [];
	[~,~,poisb,poisl,~,invr,iflagm,~,xmin1d,xmax1d,~,~,~] ...
	= fun_calmod(ncont,pois,poisb,poisl,poisbl,invr,iflagm,ifrbnd,xmin1d,xmax1d,insmth,xminns,xmaxns);

	if abs(modout) ~= 0 || ifd > 1
		if xmmin < -999998, xmmin = xmin; end
		if xmmax < -999998, xmmax = xmax; end

		if dxmod == 0.0, dxmod = (xmmax-xmmin) ./ 20.0; end
		if dzmod == 0.0, dzmod = (zmax-zmin) ./ 10.0; end
		if dxzmod == 0.0, dxzmod = (zmax-zmin) ./ 10.0; end

		nx = round((xmmax-xmmin)./dxmod); % nint -> round
		nz = round((zmax-zmin)./dzmod); % nint -> round

		if abs(modout) >= 2
			% 4010 4020
			sample(1:nz,1:nx) = 0;
		end
	end

	if itx>=3 && invr==0, itx = 2; end
	if itxout==3 && invr==0, itxout = 2; end
	if invr==0 && abs(idata)==2, idata = 1 * sign(idata); end
	if iflagm == 1
		fun_goto9999(); return; % go to 9999
	end

	if idvmax > 0 || idsmax > 0
		% 895 write(' ')
		fprintf(' \n');
		fprintf(fID_11,' \n');
		if idvmax > 0
			% 865
			fprintf('large velocity gradient in layers: ');
			fprintf('%4d',ldvmax(1:idvmax));
			fprintf('\n');
			% 865
			fprintf(fID_11,'large velocity gradient in layers: ');
			fprintf(fID_11,'%4d',ldvmax(1:idvmax));
			fprintf(fID_11,'\n');
		end
		if idsmax > 0
			% 875
			fprintf('large slope change in boundaries:  ');
			fprintf('%4d',ldsmax(1:idsmax));
			fprintf('\n');
			% 875
			fprintf(fID_11,'large slope change in boundaries:  ');
			fprintf(fID_11,'%4d',ldsmax(1:idsmax));
			fprintf(fID_11,'\n');
		end
		% 895
		fprintf(' \n');
		fprintf(fID_11,' \n');
	end


	if onDev, disp('========================= tick 5 ========================='); end

	% assign values to the arrays xshota, zshota and idr
	% and determine nshot

	for ii = 1:pshot % 290
		if ishot(ii)==-1 || ishot(ii)==2
			nshot = nshot + 1;
			xshota(nshot) = xshot(ii);
			zshota(nshot) = zshot(ii);
			idr(nshot) = -1;
			ishotw(nshot) = -ii;
			ishotr(nshot) = 2 .* ii - 1;
		end
		if ishot(ii)==1 || ishot(ii)==2
			nshot = nshot + 1;
			xshota(nshot) = xshot(ii);
			zshota(nshot) = zshot(ii);
			idr(nshot) = 1;
			ishotw(nshot) = ii;
			ishotr(nshot) = 2 .* ii;
		end
	end % 290


	% calculate the z coordinate of shot points if not specified by the
	% user - assumed to be at the top of the first layer

	zshift = abs(zmax-zmin) ./ 10000.0;
	for ii = 1:nshot % 300
		if zshota(ii) < -1000.0
			if xshota(ii)<xbnd(1,1,1) || xshota(ii)>xbnd(1,nblk(1),2)
				continue; % go to 300
			end
			for jj = 1:nblk(1) % 310
				if xshota(ii)>=xbnd(1,jj,1) && xshota(ii)<=xbnd(1,jj,2)
					zshota(ii) = s(1,jj,1) .* xshota(ii) + b(1,jj,1) + zshift;
				end
			end % 310
		end
	end % 300

	% assign default value to nray if not specified or nray(1) if only
	% it is specified and also ensure that nray<=pnrayf

	if nray(1) < 0
		% 320 cycle
		nray(1:prayf) = 10;
	else
		if nray(2) < 0
			if nray(1) > pnrayf, nray(1) = pnrayf; end
			% 330 cycle
			nray(2:prayf) = nray(1);
		else
			% 340 cycle begin
			nray(nray(1:prayf)<0) = 10;
			nray(nray(1:prayf)>pnrayf) = pnrayf;
			% 340 cycle end
		end
	end


	% assign default value to stol if not specified by the user

	if stol < 0.0, stol = (xmax-xmin)./3500.0; end

	% check array ncbnd for array values greater than pconv

	if any(ncbnd(1:prayf)>pconv) % 470
		% 135
		fprintf('\n***  max converting boundaries exceeded  ***\n\n');
		fun_goto900(); return; % go to 900
	end % 470

	if onDev, disp('========================= tick 6 ========================='); end

	% plot velocity model

	if (imod==1 || iray>0 || irays==1) && isep<2
		fun_my_pltmod(ncont,ibnd,imod,iaxlab,ivel,velht,idash,ifrbnd,idata,iroute,i33);
		% fun_pltmod(ncont,ibnd,imod,iaxlab,ivel,velht,idash,ifrbnd,idata,iroute,i33);
	end

	% return;

	% calculation of smooth layer boundaries

	if ibsmth > 0
		for ii = 1:nlayer+1 % 680
			zsmth(1) = (cosmth(ii,2)-cosmth(ii,1)) ./ xsinc;
			% 660 cycle
			zsmth(2:npbnd-1) = (cosmth(ii,3:npbnd)-cosmth(ii,1:npbnd-2)) ./ (2.0.*xsinc);
			zsmth(npbnd) = (cosmth(ii,npbnd)-cosmth(ii,npbnd-1)) ./ xsinc;
			% 670 cycle
			cosmth(ii,1:npbnd) = atan(zsmth(1:npbnd));
		end % 680
	end
	if(isep>1 && ibsmth==2), ibsmth=1; end

	% 35
	fprintf(fID_11,'shot  ray i.angle  f.angle   dist     depth red.time  npts code\n');
	if idump == 1
		% 45
		fprintf(fID_12,'\ngr ray npt   x       z      ang1    ang2    v1     v2  lyr bk id iw\n');
	end

	if nrskip<1, nrskip=1; end
	if hws<0, hws=(xmax-xmin)./25.0; end
	hwsm = hws;
	crit = crit ./ pi18;

	if any(nrbnd(1:prayf)>prefl) % 260
		% 125
		fprintf('\n***  max reflecting boundaries exceeded  ***\n\n');
		fun_goto900(); return; % go to 900
	end % 260

	for ii = 1:preflt % 710
		if rbnd(ii) >= nlayer
			% 165
			fprintf('\n***  reflect boundary greater than # of layers  ***\n\n');
		end
	end % 710

	if nsmax(1) < 0
		% 350 cycle
		nsmax(1:ngroup) = 10;
	else
		if nsmax(2) < 0 && ngroup > 1
			% 360 cycle
			nsmax(2:ngroup) = nsmax(1);
		end
	end

	if nsmin(1) < 0
		% 351 cycle
		nsmin(1:ngroup) = 1000000.0;
	else
		if nsmin(2) < 0 && ngroup > 1
			% 361 cycle
			nsmin(ii) = nsmin(1);
		end
	end

	if onDev, disp('========================= tick 7 ========================='); end

	% assign default values to smin and smax if not specified

	if smin < 0.0, smin=(xmax-xmin)./4500.0; end
	if smax < 0.0, smax=(xmax-xmin)./15.0; end

	if ximax < 0.0, ximax=(xmax-xmin)./20.0; end
	ist = 0;
	iflagp = 0;

	if ifast == 1
		if ntan>pitan, ntan=pitan; end
		ntan = 2 .* ntan;
		ainc = pi ./ ntan; % float
		factan = ntan ./ pi; % float

		% 6010 cycle begin
		angtan(1:ntan) = (0:ntan-1) .* pi ./ ntan; % float
		tatan(1:ntan) = tan(angtan(1:ntan));
		% 6010 cycle end
		% 6020 cycle begin
		mtan(1:ntan-1) = (tatan(2:ntan) - tatan(1:ntan-1)) ./ ainc;
		btan(1:ntan-1) = tatan(1:ntan-1) - mtan(1:ntan-1) .* angtan(1:ntan-1);
		% 6020 cycle end

		% 6030 cycle
		tatan(2:ntan) = 1.0 ./ tan(angtan(2:ntan));
		% 6040 cycle begin
		mcotan(1:ntan-1) = (tatan(2:ntan) - tatan(1:ntan-1)) ./ ainc;
		bcotan(1:ntan-1) = tatan(1:ntan-1) - mcotan(1:ntan-1) .* angtan(1:ntan-1);
		% 6040 cycle end
	end

	isGoto1000 = false;
	if nshot==0, isGoto1000=true; end

	if ~isGoto1000 % -------------------- ~ go to 1000 block start

		if onDev, disp('========================= tick 8: entering cycle 60 ========================='); end

		for is = 1:nshot % 60
			ist = ist + 1;
			id = idr(is);
			fid = id; % float
			xshotr = xshota(is);
			zshotr = zshota(is);
			if ist == 1
				xsec = xshotr;
				zsec = zshotr;
				idsec = id;
				ics = 1;
				% 810 cycle
				tang(1:nlayer,1:4) = 999.0;
			else
				if abs(xshotr-xsec) < 0.001 && abs(zshotr-zsec) < 0.001
					if iflags == 1, continue; end % go to 60
					ics = 0;
					if id ~= idsec
						% 830 cycle
						tang(1:nlayer,1:4) = 999.0;
					end
				else
					xsec = xshotr;
					zsec = zshotr;
					idsec = id;
					ics = 1;
					% 820 cycle
					tang(1:nlayer,1:4) = 999.0;
				end
			end
			if ics == 1

				[layer1,iblk1,iflags] = deal([]);
				[~,~,layer1,iblk1,iflags] = fun_xzpt(xshotr,zshotr,layer1,iblk1,iflags);

				if iflags == 1
					fprintf(fID_11,'***  location of shot point outside model  ***\n');
					continue; % go to 60
				end

				if (imod==1 || iray > 0 || irays==1) && isep > 1
					if iflagp == 1
						fun_aldone();
					end
					iflagp = 1;
					fun_my_pltmod(ncont,ibnd,imod,iaxlab,ivel,velht,idash,ifrbnd,idata,iroute,i33);
					% fun_pltmod(ncont,ibnd,imod,iaxlab,ivel,velht,idash,ifrbnd,idata,iroute,i33);
				end
			end
			irbnd = 0;
			ictbnd = 0;

			if onDev, disp('========================= tick 9: entering cycle 70 ========================='); end

			for ii = 1:ngroup % 70
				if iraysl == 1
					irpos = (ishotr(is)-1) .* ngroup + ii;
					if irayt(irpos) == 0
						irbnd = irbnd + nrbnd(ii);
						ictbnd = ictbnd + ncbnd(ii);
						nrayr = 0;
						continue; % go to 70
					end
				end
				id = idr(is);
				fid = id; % float
				fid1 = fid;
				% 250 cycle
				refll(1:prefl+1) = 0;
				% 251 cycle
				icbnd(1:pconv+1) = -1;
				ifam = ifam + 1;
				nrayr = nray(ii);
				iflagl = 0;
				ibrka(ifam) = ibreak(ii);
				ivraya(ifam) = ivray(ii);
				% 870 cycle
				iheadf(1:nlayer) = ihead(1:nlayer);
				idl = fix(ray(ii)); % int -> fix
				idt = fix((ray(ii)-idl).*10.0+0.5); % int -> fix % float

				% -------------------- one time cycle 69 begin
				for one_time_cycle69 = 1:1
					if idt == 2
						if nrbnd(ii) > (prefl-1)
							% 125
							fprintf('\n***  max reflecting boundaries exceeded  ***\n\n');
							% 65
							fprintf(fID_11,'***  shot#%4d ray code%5.1f no rays traced  ***\n\n',ishotw(is),ray(ii));
							nrayr = 0;
							break; % go to 69
						end
						refll(1) = idl;
						if nrbnd(ii) > 0
							for jj = 1:nrbnd(ii) % 230
								irbnd = irbnd + 1;
								refll(jj+1) = rbnd(irbnd);
							end % 230
						end
					else
						if nrbnd(ii) > 0
							for jj = 1:nrbnd(ii) % 240
								irbnd = irbnd + 1;
								refll(jj) = rbnd(irbnd);
							end % 240
						end
					end
					if idt == 3
						iheadf(idl) = 1;
						ihdwf = 1;
						ihdwm = 1;
						hws = hwsm;
						tdhw = 0.0;
						if nhray < 0, nrayr = pnrayf;
						else nrayr = nhray; end
					else
						ihdwf = -1;
						ihdwm = -1;
					end
					if ncbnd(ii) > 0
						for jj = 1:ncbnd(ii) % 630
							ictbnd = ictbnd + 1;
							icbnd(jj) = cbnd(ictbnd);
						end % 630
					end
					idifff = 0;

					if ircol==1, irrcol=colour(mod(ivray(ii)-1,ncol)+1); end
					if ircol==2, irrcol=colour(mod(is-1,ncol)+1); end
					if ircol==3, irrcol=colour(mod(ii-1,ncol)+1); end
					if ircol< 0, irrcol=-ircol; end

					if nrayr <= 0, break; end % go to 69

					if i2pt > 0
						iflag2 = 0;
						nsfc = 1;
						isf = ilshot(nsfc);
						% disp(ilshot(1:10)); ok
						% 1110 % -------------------- cycle1110 begin
						cycle1110 = true;
						while cycle1110
							xf = xpf(isf);
							tf = tpf(isf);
							uf = upf(isf);
							irayf = ipf(isf);
							if irayf < 0, break; end % go to 1200
							if irayf == 0
								xshotf = xf;
								idf = sign(tf);
								if abs(xshotr-xshotf) < 0.001 && idr(is) == idf
									i2flag = 1;
									isf = isf + 1;
								else
									i2flag = 0;
									nsfc = nsfc + 1;
									isf = ilshot(nsfc);
								end
							else
								if i2flag==1 && ivray(ii)==irayf
									iflag2 = 1;
									break; % go to 1200
								end
								isf = isf + 1;
							end
							continue; % go to 1110
							break; % go to nothing
						end % -------------------- cycle1110 end
						% 1200
						if iflag2 == 0
							nrayr = 0;
							break; % go to 69
						end
					end

					if onDev, disp('========================= tick 10: before fun_auto ========================='); end

					if ~exist('aminr','var'), [aminr,amaxr,iflag] = deal([]); end % for fun_auto
					[~,~,~,~,~,~,aminr,amaxr,~,~,~,~,~,~,~,iflag,~,~,~,ia0,~,~,~,~,~,~,~,~] ...
					= fun_auto(xshotr,zshotr,ii,ifam,idl,idt,aminr,amaxr,aamin,aamax,...
						layer1,iblk1,aainc,aaimin,nsmax(ii),iflag,iturn(ii),amin(ia0),...
						amax(ia0),ia0,stol,irays,nskip,idot,irayps,xsmax,istep,nsmin(ii));

					if onDev, disp('========================= tick 11: after fun_auto ========================='); end

					if iflag ~= 0
						% 65
						fprintf(fID_11,'***  shot#%4d ray code%5.1f no rays traced  ***\n',ishotw(is),ray(ii));
						nrayr = 0;
						nrayl = nrayl + 1;
						iflagl = 1;
						break; % go to 69
					end
					if amaxr == aminr && ihdwf ~= 1
						if nrayr > 1
							% 665
							fprintf(fID_11,'***  shot#%4d ray code%5.1f 1 ray traced  ***\n',ishotw(is),ray(ii));
							nrayl = nrayl + 1;
							iflagl = 1;
						end
						nrayr = 1;
					end
					if nrayr > 1
						if idt == 2
							if amaxr<=aminr, amaxr=90.0; end
						end
						if space(ii) > 0
							pinc = space(ii);
						else
							if idt==2, pinc=2.0;
							else pinc=1.0; end
						end
						ainc = (amaxr-aminr) ./ (nrayr-1).^pinc; % float
					else
						pinc = 1.0; ainc = 0.0;
					end
					iend = 0;
					ninv = 0;
					ifcbnd = frbnd(ii);
					nc2pt = 0;

					if i2pt > 0 && nrayr > 1
						ii2pt = i2pt;
						ni2pt = 1; no2pt = 0; nco2pt = 0; ic2pt = 0;
						nsfc = 1;
						isf = ilshot(nsfc);
						% 1100 % -------------------- cycle1100 begin
						cycle1100 = true;
						while cycle1100
							xf = xpf(isf);
							tf = tpf(isf);
							uf = upf(isf);
							irayf = ipf(isf);
							if irayf < 0, break; end % go to 1199
							if irayf == 0
								xshotf = xf;
								idf = 1.0 .* sign(tf);
								if abs(xshotr-xshotf) < 0.001 && idr(is) == idf
									i2flag = 1;
									isf = isf + 1;
								else
									i2flag = 0;
									nsfc = nsfc + 1;
									isf = ilshot(nsfc);
								end
							else
								if i2flag==1 && ivray(ii)==irayf
									no2pt = no2pt + 1;
									if no2pt > min(pnrayf,pnobsf)
										% 896
										fprintf('***  pnrayf or pnobsf exceeded  ***\n');
										break; % go to 1199
									end
									xo2pt(no2pt) = xf;
									ifo2pt(no2pt) = 0;
								end
								isf = isf + 1;
							end
							continue; % go to 1100
							break; % go to nothing
						end % -------------------- cycle1100 end
						% 1199
						if no2pt==0, ni2pt=0; end
					else
						ni2pt = 0; ii2pt = 0;
					end

					if onDev, disp('========================= tick 12: entering cycle91 ========================='); end

					% 91 % -------------------- cycle91 begin
					cycle91 = true;
					while cycle91
						ir = 0; nrg = 0;
						ihdwf = ihdwm;
						tdhw = 0.0; dhw = 0.0;
						i1ray = 1;

						if onDev, disp('========================= tick 13: entering cycle90 ========================='); end

						% 90 % -------------------- cycle90 begin
						cycle90 = true;
						while cycle90
							ir = ir + 1;
						if onDev, fprintf('========================= in cycle90# %12d =========================\n',ir); end
							if ir>nrayr && ni2pt<=1, break; end % go to 890
							if i2pt==0 && iend==1, break; end % go to 890
							ircbnd = 1; iccbnd = 1;
							iwave = 1; ihdw = 0;
							if icbnd(1) == 0
								iwave = -iwave;
								iccbnd = 2;
							end
							nptbnd = 0; nbnd = 0;
							npskp = npskip;
							nccbnd = 0;
							id = idr(is);
							fid = id; % float
							fid1 = fid;
							iturnt = 0;
							if nc2pt <= 1
								angled = aminr + ainc .* (ir-1).^pinc;
								if amaxr > aminr
									if angled > amaxr
										angled = amaxr;
										iend = 1;
									end
								else
									if angled < amaxr
										angled = amaxr;
										iend = 1;
									end
								end
								if ir==nrayr && nrayr>1, angled=amaxr; end
							else
								isGoto890 = false;
								% 891 % -------------------- cycle891 begin
								cycle891 = true;
								while cycle891
									nco2pt = nco2pt + 1;
									if nco2pt>no2pt, isGoto890=true; break; end % go to 890 step1
									if ifo2pt(nco2pt)~=0 && ii2pt>0, continue; end % go to 891
									xobs = xo2pt(nco2pt);
									tt2min = 1.0e10;
									for jj = 1: nc2pt-1 % 892
										if (ra2pt(jj)>=xobs && ra2pt(jj+1)<=xobs) || (ra2pt(jj)<=xobs && ra2pt(jj+1)>=xobs)
											denom = ra2pt(jj+1) - ra2pt(jj);
											if denom ~= 0
												tpos = (tt2pt(jj+1)-tt2pt(jj)) ./ denom .* (xobs-ra2pt(jj)) + tt2pt(jj);
											else
												tpos = (tt2pt(jj+1)+tt2pt(jj)) ./ 2.0;
											end
											if tpos < tt2min
												tt2min = tpos;
												if denom ~= 0.0
													aort = (ta2pt(jj+1)-ta2pt(jj)) ./ denom .* (xobs-ra2pt(jj)) + ta2pt(jj);
												else
													aort = (ta2pt(jj+1)+ta2pt(jj)) ./ 2.0;
												end
												if ihdwf ~= 1
													angled = aort;
												else
													tdhw = aort;
													hws = tdhw;
												end
												xdiff = min(abs(xobs-ra2pt(jj)),abs(xobs-ra2pt(jj+1)));
												if xdiff<x2pt, ifo2pt(nco2pt)=1; end
											end
										end
									end % 892
									if tt2min > 1.0e9 || (ifo2pt(nco2pt)~=0 && ii2pt>0)
										continue; % go to 891
									end
									break; % go to nothing
								end % -------------------- cycle891 end
								if isGoto890, break; end % go to 890 step2
							end
							angle_angle = fid .* (90.0-angled) ./ pi18;
							if ir > 1 && ihdwf ~= 1
								if angle_angle == am, continue; end % go to 90
							end
							am = angle_angle;
							if fid1 .* angle_angle < 0.0
								id = -id; fid = id; % float
							end
							layer = layer1;
							iblk = iblk1;
							npt = 1;
							xr(1) = xshotr;
							zr(1) = zshotr;
							ar_(1,1) = 0.0;
							ar_(1,2) = angle_angle;
							vr(1,1) = 0.0;
							vp(1,1) = 0.0;
							vs(1,1) = 0.0;
							vp(1,2) = fun_vel(xshotr,zshotr);
							vs(1,2) = vp(1,2) .* vsvp(layer1,iblk1);
							if iwave == 1, vr(1,2) = vp(1,2);
							else vr(1,2) = vs(1,2); end
							idray(1) = layer1;
							idray(2) = 1;

							if ii2pt > 0, irs = 0;
							else irs = ir; end
							if invr==1 && irs>0
								ninv = ninv + 1;
								% 80 cycle
								fpart(ninv,1:nvar) = 0.0;
							end
							nrg = nrg + 1;
							nhskip = 0;

							[npt,~,~,~,~,~,iflag,~,~,~,~,i1ray,~] = fun_trace(npt,ifam,irs,iturnt,invr,xsmax,iflag,idl,idt,iray,ii2pt,i1ray,modout);
							if ~exist('uf','var'), uf = []; end
							if ~exist('irayf','var'), irayf = []; end
							[~,~,~,~,~,~,itt,~,~,~,~] = fun_ttime(ishotw(is),xshotr,npt,irs,angled,ifam,itt,iszero,iflag,uf,irayf);

							if irs == 0
								ic2pt = ic2pt + 1;
								if ihdwf ~= 1, ta2pt(ic2pt) = angled;
								else ta2pt(ic2pt) = tdhw-hws; end
								ra2pt(ic2pt) = xr(npt);
								tt2pt(ic2pt) = timertimer;
								if vr(npt,2)<=0.0, tt2pt(ic2pt)=1.0e20; end
							end

							if ((iray==1 || (iray==2 && vr(npt,2)>0.0)) && mod(ir-1,nrskip)==0 && irs>0) || (irays==1 && irs==0)
								fun_my_pltray(npt,max(nskip,nhskip),idot,irayps,istep,angled);
								% [~,~,~,~,istep,~] = fun_pltray(npt,max(nskip,nhskip),idot,irayps,istep,angled);
								if i33 == 1
									if iszero == 1, xwr=abs(xshtar(ntt-1)-xobs);
									else xwr = xobs; end
									% 335
									fprintf(fID_33,'%12.4f%4d%4d%12.4f%12.4f%12.4f',xshtar(ntt-1),ivraya(ifam),ii,xwr,tt(ntt-1)); % 335
								end
							end

							if vr(npt,2) > 0 && irs > 0 && abs(modout) >= 2
								[~,~,~,~] = fun_cells(npt,xmmin,dxmod,dzmod);
							end

							if invr==1 && irs>0
								[~] = fun_fxtinv(npt);
							end

							if ihdwf == 0, break; end % go to 890
							if ntt > pray
								% 995
								fprintf('\n***  max number of rays reaching surface exceeded  ***\n\n');
								break; % go to 890
							end
							continue; % go to 90
							break; % go to nothing
						end % -------------------- cycle90 end

						% 890
						if ii2pt > 0
							nc2pt = ic2pt;
							if ni2pt > 1
								% replace fun_sort3 with matlab built-in function 'sort'
								% [ta2pt,ipos,~] = fun_sort3(ta2pt,ipos,nc2pt);
								[ta2pt,ipos] = sort(ta2pt(1:nc2pt));
								% 893 cycle
								ho2pt(1:nc2pt) = ra2pt(1:nc2pt);
								% 894 cycle
								ra2pt(1:nc2pt) = ho2pt(ipos(1:nc2pt));
								% 897 cycle
								ho2pt(1:nc2pt) = tt2pt(1:nc2pt);
								% 898 cycle
								tt2pt(1:nc2pt) = ho2pt(ipos(1:nc2pt));
							end
							ni2pt = ni2pt + 1;
							if ni2pt > n2pt, ii2pt = 0; end
							nco2pt = 0;
							continue; % go to 91
						end
						break; % go to nothing
					end % -------------------- cycle91 end

					if ~exist('iflagw','var'), iflagw = []; end
					if ninv > 0
						[~,~,~,~,~,iflagw,~,~] = fun_calprt(xshotr,ii,ivraya(ifam),idr(is),ximax,iflagw,iszero,x2pt);
					end
					if iflagw == 1, iflagi = 1; end
					if iray > 0 || irays == 1
						fun_empty();
					end

					nrayr = nrg;
					break; % go to nothing
				end % -------------------- one time cycle 69 end

				if onDev, disp('========================= tick: out of one-time-cycle 69 ========================='); end

				% 69
				if iflagl == 1, flag = '*';
				else flag = ' '; end
				% 375
				fprintf('shot#%4d:   ray code%5.1f:   %3d rays traced %1s\n',ishotw(is),ray(ii),nrayr,flag);
				if ntt > pray
					isGoto1000 = true; break; % go to 1000 step1
				end
			end % 70
			if isGoto1000, break; end % go to 1000 step2
			if isep==2 && ((itx>0 && ntt>1) || idata~=0 || itxout>0)
				fun_my_plttx(ifam,itt,iszero,idata,iaxlab,xshota,idr,nshot,itxout,ibrka,ivraya,ttunc,itrev,xshotr,idr(is),itxbox,iroute,iline);
				% fun_plttx(ifam,itt,iszero,idata,iaxlab,xshota,idr,nshot,itxout,ibrka,ivraya,ttunc,itrev,xshotr,idr(is),itxbox,iroute,iline);
			end
		end % 60
	end % -------------------- ~ go to 1000 block end

	if onDev, disp('========================= tick 1000 ========================='); end

	% 1000
	if (isep<2 || isep==3) && ((itx>0 && ntt>1) || idata~=0 || itxout>0)
		if isep>0 && iplots==1
			fun_aldone();
		end
		fun_my_plttx(ifam,itt,iszero,idata,iaxlab,xshota,idr,nshot,itxout,ibrka,ivraya,ttunc,itrev,xshotr,1.0,itxbox,iroute,iline);
		% fun_plttx(ifam,itt,iszero,idata,iaxlab,xshota,idr,nshot,itxout,ibrka,ivraya,ttunc,itrev,xshotr,1.0,itxbox,iroute,iline);
	end

	if itxout > 0
		% 930
		fprintf(fID_17,'   %14f   %14f   %14f%12d',0.0,0.0,0.0,-1);
	end

	if irkc == 1
		% 75
		fprintf('\n***  possible inaccuracies in rngkta  ***\n');
		fprintf(fID_11,'\n***  possible inaccuracies in rngkta  ***\n');
	end

	if nrayl > 0
		% 785
		tempstr = sprintf('\n***  less than nray rays traced for %4d ray groups  ***\n',nrayl);
		fprintf(tempstr);
		fprintf(fID_11, tempstr);
	end

	if iflagi == 1
		% 775
		fprintf('\n***  attempt to interpolate over ximax  ***\n');
	end

	if i33 == 1
		for ii = 1:narinv % 1033
			% 335 % format(f12.4,2i4,3f12.4)
			fprintf(fID_34,'%12.4f%4d%4d%12.4f%12.4f%12.4f\n',xscalc(ii),abs(icalc(ii)),ircalc(ii),xcalc(ii),tcalc(ii));
		end % 1033
	end

	if abs(modout) ~= 0
		[~,~,~,~,~,frz,~,~]= fun_modwr(modout,dxmod,dzmod,modi,ifrbnd,frz,xmmin,xmmax);
	end

	if ifd > 0
		[~,~,~,~] = fun_fd(dxzmod,xmmin,xmmax,ifd);
	end

	fun_goto900();

	fclose('all');
end % main function end

% --------------------------------------------------------------------------------

function fun_goto9999()
	global file_nout;
	global pltpar axepar trapar invpar;
	fID_22 = fopen(file_nout,'w');
	fun__writeNamelist(fID_22,'PLTPAR',pltpar);
	fun__writeNamelist(fID_22,'AXEPAR',axepar);
	fun__writeNamelist(fID_22,'TRAPAR',trapar);
	fun__writeNamelist(fID_22,'INVPAR',invpar);
	fclose(fID_22);
end

function fun__writeNamelist(fid,name,namelist)
% 将一个namelist中的所有变量写入指定文件

	eval(['global ',namelist]);
	clist = strsplit(namelist);
	for h = 1:length(clist)
		if isempty(strtrim(clist{h})), clist(h)=[]; end
	end
	fprintf(fid, '&&%s\n', name);
	for h = 1:length(clist)
		parname = clist{h};
		par = eval(parname);
		tempLen = min(10,length(par));
		isFloat = any(par(1:tempLen) > floor(par(1:tempLen)));
		if isFloat, formatStr = ' %.2f';
		else formatStr = ' %d'; end
		fprintf(fid, '  %s =', parname);
		tempSize = size(par);
		for ii = 1:tempSize(1)
			fprintf(fid, formatStr, par(ii,:));
			if ii<tempSize(1), fprintf(fid, '\n'); end
		end
		if h<length(clist), fprintf(fid, ',\n'); end
	end
	fprintf(fid, '/\n');
end

% --------------------------------------------------------------------------------

function fun_goto900()
	global file_rayinvr_par file_rayinvr_com file_main_par;
	global fID_11;
	global file_iout;
	run(file_rayinvr_par);
	run(file_rayinvr_com);
	run(file_main_par);

	% 900 % 920 cycle
	ntblk = sum(nblk(1:nlayer));

	% 935
	tempstr = sprintf(['\n|------------------------------------------',...
		'----------------------|\n|%64s|\n'], '');
	if isum > 0, fprintf(tempstr); end
	fprintf(fID_11, tempstr);

	if ntpts > 0
		% 905
		tempstr = sprintf(['| total of %6d rays consisting of %8d points ',...
			'were traced |\n|%64s|\n'], ntray,ntpts,'');
	else
		% 915
		tempstr = sprintf('|%20s***  no rays traced  ***%20s|\n|%64s|\n','','','');
	end
	if isum > 0, fprintf(tempstr); end
	fprintf(fID_11, tempstr);

	% 925
	tempstr = sprintf(['|           model consists of %2d layers and %3d ',...
		'blocks           |\n|%64s|\n|----------------------------------',...
		'------------------------------|\n\n'], nlayer,ntblk,'');
	if isum > 0, fprintf(tempstr); end
	fprintf(fID_11, tempstr);

	if invr == 1
		fID_18 = fopen(file_iout,'w');
		parunc(1) = bndunc;
		parunc(2) = velunc;
		parunc(3) = bndunc;
		% 895 % 835 % 895
		fprintf(fID_18, ' \n%5d%5d\n\n', narinv,nvar);

		for ii = 1:nvar % 801
			% 805
			fprintf(fID_18,'%5d%15.5f%15.5f\n',partyp(ii),parorg(ii),parunc(partyp(ii)));
		end % 801
		% 895
		fprintf(fID_18, ' \n');

		for ii = 1:narinv % 840
			% 815
			fprintf(fID_18,'%12.5e%12.5e%12.5e%12.5e%12.5e\n',apart(ii,1:nvar));
		end % 840
		% 895 % 915
		fprintf(fID_18,' \n%12.5e%12.5e%12.5e%12.5e%12.5e\n',tobs(1:narinv)-tcalc(1:narinv));
		% 895 % 815
		fprintf(fID_18,' \n%12.5e%12.5e%12.5e%12.5e%12.5e\n',uobs(1:narinv));

		if narinv > 1
			% 850 cycle begin
			temp = tobs(1:narinv)-tcalc(1:narinv);
			ssum = sum(temp .^ 2);
			sumx = sum((temp./uobs(1:narinv)) .^ 2);
			% 850 cycle end
			trms = sqrt(ssum ./ narinv); % float
			chi = sumx ./ (narinv-1); % float

			% 895 % 825 % 895
			tempstr = sprintf([' \nNumber of data points used: %8d\n',...
				'RMS traveltime residual:    %8.3f\n',...
				'Normalized chi-squared:   %10.3f\n \n'], narinv,trms,chi);
			fprintf(fID_18, tempstr);
			fprintf(tempstr);
			fprintf(fID_11, tempstr);

			if isum > 1
				% 968
				tempstr = sprintf([' phase    npts   Trms   chi-squared\n',...
					'-----------------------------------\n']);
				fprintf(fID_11, tempstr);
				if isum==3, fprintf(tempstr); end
				nused = 0; jj = 0;
				% 951 % -------------------- cycle 951 begin
				cycle951 = true;
				while cycle951
					jj = jj + 1;
					sumsum = 0.0; sumx = 0.0; nars = 0;
					for ii = 1:narinv % 952
						if abs(icalc(ii)) == jj
							sumsum = sumsum + (tobs(ii)-tcalc(ii)) .^ 2;
							sumx = sumx + ((tobs(ii)-tcalc(ii))./uobs(ii)) .^ 2;
							nars = nars + 1;
							nused = nused + 1;
						end
					end % 952
					if nars > 0, trms = sqrt(sumsum ./ nars); end % float
					if nars > 1, chi = sumx ./ (nars-1); % float
					else chi = sumx; end
					if nars > 0
						% 969
						tempstr = sprintf('%6d%8d%8.3f%10.3f\n', jj,nars,trms,chi);
						fprintf(fID_11, tempstr);
						if isum==3, fprintf(tempstr); end
					end
					if nused>=narinv, break; end % go to 953
					continue; % go to 951
					break; % go to nothing
				end % -------------------- cycle 951 end

				% 953
				% 895 % 868
				tempstr = sprintf([' \n     shot  dir   npts   Trms   chi-squared',...
					'\n------------------------------------------\n']);
				fprintf(fID_11, tempstr);
				if isum==3, fprintf(tempstr); end

				xsn = xscalc(1);
				icn = 1 .* sign(icalc(1));
				for jj = 1:nshot % 851
					iflagn = 1;
					xsc = xsn;
					icc = icn;
					sumsum = 0.0; sumx = 0.0;
					nars = 0;
					for ii = 1:narinv % 852
						if xscalc(ii)==xsc && sign(icalc(ii))==icc && icalc(ii)~=0
							tdiff = abs(tobs(ii)-tcalc(ii));
							sumsum = sumsum + tdiff .^ 2;
							sumx = sumx + (tdiff./uobs(ii)) .^ 2;
							nars = nars + 1;
							icalc(ii) = 0;
						else
							if iflagn==1 && icalc(ii)~=0
								xsn = xscalc(ii);
								icn = sign(icalc(ii));
								iflagn = 0;
							end
						end
					end % 852
					if nars > 0, trms=sqrt(sumsum./nars); end % float
					if nars > 1, chi=sumx./(nars-1); % float
					else chi=sumx; end
					if nars > 0
						% 869
						tempstr = sprintf('%10.3f%3d%8d%8.3f%10.3f\n',xsc,icc,nars,trms,chi);
						fprintf(fID_11, tempstr);
						if isum==3, fprintf(tempstr); end
					end
				end % 851
				% 895
				fprintf(fID_11, ' \n');
				if isum==3, fprintf(' \n'); end
			end
		end
		fclose(fID_18);
	end
	if iplots == 1
		% ? call plotnd(1)
		fun_plotnd();
	end
	fun_goto9999(); return;
end