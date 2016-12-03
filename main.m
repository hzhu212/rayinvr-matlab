function main(filePathIn, filePathOut)
    % main function for rayinvr, all variables are global
    %
    % <strong>main(filePathIn, filePathOut)</strong>
    %
    % filePathIn: file path for all input files. That means you'd better put all of your ".in" files in the same path. Default: 'input'.

    if nargin < 2
        filePathOut = 'output';
        if nargin < 1
            filePathIn = 'input';
        end
    end

    clear('global');
    global file_rayinvr_par file_rayinvr_com;
    global fID_11, fID_12;

    file_rayinvr_par = 'rayinvr_par.m';
    file_rayinvr_com = 'rayinvr_com.m';
    file_main_par = 'main_par.m';

    file_rin = fullfile(filePathIn,'r.in');
    file_vin = fullfile(filePathIn,'v.in');
    file_txin = fullfile(filePathIn,'tx.in');
    file_fin = fullfile(filePathIn,'f.in');

    file_r1out = fullfile(filePathOut,'r1.out');
    file_r2out = fullfile(filePathOut,'r2.out');
    file_ra1out = fullfile(filePathOut,'ra1.out');
    file_ra2out = fullfile(filePathOut,'ra2.out');
    file_txout = fullfile(filePathOut,'tx.out');
    file_fdout = fullfile(filePathOut,'fd.out');
    file_iout = fullfile(filePathOut,'i.out');
    file_nout = fullfile(filePathOut,'n.out');
    file_tout = fullfile(filePathOut,'t.out');
    file_pout = fullfile(filePathOut,'p.out');
    file_vout = fullfile(filePathOut,'v.out');


    %% 1 variables
    %% 1.1 声明rayinvr.par文件中的变量并赋值
    run(file_rayinvr_par);

    %% 1.2 声明main函数中的变量并赋值
    run(file_main_par);

    %% 1.3 声明rayinvr.com文件中的变量并赋值
    run(file_rayinvr_com);

    %% 1.4 为r.in中的所有变量赋值
    file_rin_m = fun_trans_rin2m(file_rin); % 将r.in文件转化为r_in.m脚本
    run(file_rin_m); % 载入脚本，为r.in中所有变量赋值

    %% 2 main
    % 如果未指定xmax，则程序结束
    if xmax < -99998
        error('e:test','\n***  xmax not specified  ***\n');
    end
    % 如果imodf不等于1，表面速度模型保存在r.in文件的最后部分；否则，有专门的v.in文件保存
    if imodf ~= 1
        % ?... iunit=10 read(10,1)
        error('e:test','\n***  model must be load from file v.in, not r.in  ***\n');
    end
    if mod(ppcntr,10) ~= 0 | mod(ppvel,10) ~= 0
        % ?...将4个namelist中的所有变量保存到n.out文件
        error('e:test','\n***  array size error for number of model points  ***\n');
    end

    % 2.1 读入v.in
    % [model,LN,xmin,xmax,zmin,zmax,precision,xx,ZZ,mError] = fun_load_vin(file_vin);
    [model,LN,~,~,~,~,~,~,~,mError] = fun_load_vin(file_vin);
    error(mError);
    % 将得到的模型（model）转为源程序中的形式：xm,zm,ivarz；xvel,vf,ivarv
    % 由于模型每层存储的数组是不等长的，所以通过cell来保存，而不是二维矩阵。
    % xm = arrayfun(@(x) x.bd(1,:),model,'UniformOutput',false);
    % zm = arrayfun(@(x) x.bd(2,:),model,'UniformOutput',false);
    % ivarz = arrayfun(@(x) x.bd(3,:),model(1:end-1),'UniformOutput',false);

    % xvel = arrayfun(@(x) [x.tv(1,:);x.bv(1,:)],model(1:end-1),'UniformOutput',false);
    % vf = arrayfun(@(x) [x.tv(2,:);x.bv(2,:)],model(1:end-1),'UniformOutput',false);
    % ivarv = arrayfun(@(x) [x.tv(3,:);x.bv(3,:)],model(1:end-1),'UniformOutput',false);
    for ii = 1:length(model)-1
        thisLayer = model(ii);
        xlen = length(thisLayer.bd(1,:));
        tvlen = length(thisLayer.tv(1,:));
        bvlen = length(thisLayer.bv(1,:));

        xm(ii,1:xlen) = thisLayer.bd(1,:);
        zm(ii,1:xlen) = thisLayer.bd(2,:);
        ivarz(ii,1:xlen) = thisLayer.bd(3,:);

        xvel(ii,1:tvlen,1) = thisLayer.tv(1,:);
        xvel(ii,1:bvlen,2) = thisLayer.bv(1,:);
        vf(ii,1:tvlen,1) = thisLayer.tv(2,:);
        vf(ii,1:bvlen,2) = thisLayer.bv(2,:);
        ivarv(ii,1:tvlen,1) = thisLayer.tv(3,:);
        ivarv(ii,1:bvlen,2) = thisLayer.bv(3,:);
    end
    indexLast = length(model);
    xlen = length(model(end).bd(1,:));
    xm(indexLast,1:xlen) = model(end).bd(1,:);
    zm(indexLast,1:xlen) = model(end).bd(2,:);

    ncont = LN;
    nlayer = ncont - 1; % 20


    % 2.2 开关控制
    if iplot == 0, iplot = -1; end
    if iplot == 2, iplot = 0; end

    fID_11 = fopen(file_r1out,'w');
    if idump == 1, fID_12 = fopen(file_r2out,'w'); end
    if itxout > 0, fID_17 = fopen(file_txout,'w'); end
    if iplot <= 0, fID_19 = fopen(file_pout,'w'); end
    if abs(modout) ~= 0, fID_31= fopen(file_vout,'w'); end
    if i2pt>0 & iray==2 & irays==0 & irayps==0 & iplot<=0
        fID_33 = fopen(file_ra1out,'w');
        fID_34 = fopen(file_ra2out,'w');
        i33 = 1;
    end
    if ifd > 0, fID_35 = fopen(file_fdout,'w'); end

    % 2.3 读入tx.in文件
    [xpf,tpf,upf,ipf] = fun_load_txin(file_txin);

    % determine if plot parameters for distance axis of travel time plot are
    % same as model distance parameters
    % 设置一些绘图参数
    if xmint<-1000, xmint = xmin; end
    if xmaxt<-1000, xmaxt = xmax; end
    if xtmint<-1000, xtmint = xtmin; end
    if xtmaxt<-1000, xtmaxt = xtmax; end
    if xmmt<-1000, xmmt = xmm; end
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
    if isep==2 & imod==0 & iray==0 & irays==0, isep = 3; end
    if n2pt>pn2pt, n2pt = pn2pt; end
    if i2pt==0, x2pt = 0; end
    if x2pt<0, x2pt = (xmax-xmin) ./ 2000; end

    % 如果colour数组未赋值，则赋默认值
    if all(colour<0)
        colour = [2,3,4,5,6,8,17,27,22,7];
        ncol = 10;
    end
    mcol(mcol<0) = ifcol;

    % ngroup: 统计待追踪的射线组的总数
    negative = find(ray<1);
    if ~isempty(negative)
        ngroup = negative(1)-1;
    else
        ngroup = length(ray);
    end
    if ngroup == 0
        error('e:test','\n***  no ray codes specified  ***\n');
        % ?... go to 900
    end

    ifrbnd = 0;
    if any( frbnd(1:ngroup)<0 ) | any( frbnd(1:ngroup)>pfrefl )
        error('e:test','\n***  error in array frbnd  ***\n');
    end
    if any( frbnd(1:ngroup)>0 )
        ifrbnd = 1;
    end

    % 读取f.in文件到xfrefl,zfrefl,ivarf三个二维数组中（类似v.in的结构）
    if ifrbnd == 1
        [nfrefl,xfrefl,zfrefl,ivarf] = fun_load_fin(file_fin);

        if any( frbnd(1:ngroup)>nfrefl )
            error('e:test','\n***  error in array frbnd  ***\n');
        end
    end


    %% calculate velocity model parameters
    % 输入参数中，只有iflagm并未声明过
    iflagm = 0;
    [ncont,pois,poisb,poisl,poisbl,invr,iflagm,ifrbnd,xmin1d,xmax1d,insmth,xminns,xmaxns] ...
    = fun_calmod(ncont,pois,poisb,poisl,poisbl,invr,iflagm,ifrbnd,xmin1d,xmax1d,insmth,xminns,xmaxns);

    if abs(modout) ~= 0 | ifd > 1
        if xmmin < -999998, xmmin = xmin; end
        if xmmax < -999998, xmmax = xmax; end

        if dxmod == 0, dxmod = (xmmax-xmmin) ./ 20.0; end
        if dzmod == 0, dzmod = (zmax-zmin) ./ 10.0; end
        if dxzmod == 0, dxzmod = (zmax-zmin) ./ 10.0; end

        nx = round((xmmax-xmmin)./dxmod);
        nz = round((zmax-zmin)./dzmod);

        if abs(modout) >= 2
            sample(1:nz,1:nx) = 0;
        end
    end

    if itx>=3 & invr==0, itx = 2; end
    if itxout==3 & invr==0, itxout = 2; end
    if invr==0 & abs(idata)==2, idata = 1 * sign(idata); end
    if iflagm==1
        fun_goto9999(); return;
    end

    if idvmax > 0 | idsmax > 0
        disp(' ');
        fprintf(fID_11,' \n');
        if idvmax > 0
            disp(ldvmax(1:idvmax));
            fprintf(fID_11,'large velocity gradient in layers: \n');
            fprintf(fID_11,'%4d',ldvmax(1:idvmax));
            fprintf(fID_11,'\n');
        end
        if idsmax > 0
            disp(ldsmax(1:idsmax));
            fprintf(fID_11,'large slope change in boundaries:  \n');
            fprintf(fID_11,'%4d',ldsmax(1:idsmax));
            fprintf(fID_11,'\n');
        end
        disp(' ');
        fprintf(fID_11,' \n');
    end


    % assign values to the arrays xshota, zshota and idr and determine nshot
    for ii = 1:pshot
        if ishot(ii)==-1 | ishot(ii)==2
            nshot = nshot + 1;
            xshota(nshot) = xshot(ii);
            zshota(nshot) = zshot(ii);
            idr(nshot) = -1;
            ishotw(nshot) = -ii;
            ishotr(nshot) = 2 * ii - 1;
        end
        if ishot(ii)==1 | ishot(ii)==2
            nshot = nshot + 1;
            xshota(nshot) = xshot(ii);
            zshota(nshot) = zshot(ii);
            idr(nshot) = 1;
            ishotw(nshot) = ii;
            ishotr(nshot) = 2 * ii;
        end
    end


    % calculate the z coordinate of shot points if not specified by the
    % user - assumed to be at the top of the first layer
    zshift = abs(zmax-zmin) ./ 10000.0;
    for ii = 1:nshot
        if zshota(ii) < -1000.0
            if xshota(ii)<xbnd(1,1,1) | xshota(ii)>xbnd(1,nblk(1),2)
                break;
            end
            for jj = 1:nblk(1)
                if xshota(ii)>=xbnd(1,jj,1) & xshota(ii)<=xbnd(1,jj,2)
                    zshota(ii) = s(1,jj,1)*xshota(ii)+b(1,jj,1)+zshift;
                end
            end
        end
    end


    % assign default value to nray if not specified or nray(1) if only
    % it is specified and also ensure that nray<=pnrayf
    if nray(1) < 0
        nray(1:prayf) = 10;
    else
        if nray(2) < 0
            if nray(1) > pnrayf, nray(1) = pnrayf; end
            nray(2:prayf) = nray(1);
        else
            nray(nray(1:prayf)<0) = 10;
            nray(nray(1:prayf)>pnrayf) = pnrayf;
        end
    end


    % assign default value to stol if not specified by the user
    if stol < 0, stol = (xmax-xmin)./3500.0; end


    % check array ncbnd for array values greater than pconv
    if any(ncbnd(1:prayf)>pconv)
        % ?... go to 900
        error('e:test','\n***  max converting boundaries exceeded  ***\n');
    end
    % 470


    % plot velocity model
    if (imod==1 | iray>0 | irays==1) & isep<2
        fun_pltmod();
    end


    % calculation of smooth layer boundaries
    % size(cosmth),size(xsinc),size(zsmth)
    if ibsmth > 0
        for ii = 1:nlayer+1
            zsmth(1) = (cosmth(ii,2)-cosmth(ii,1)) ./ xsinc;
            zsmth(2:npbnd-1) = (cosmth(ii,3:npbnd)-cosmth(ii,0:npbnd-2)) ./ (2.0*xsinc);
            zsmth(npbnd) = (cosmth(ii,npbnd)-cosmth(ii,npbnd-1)) ./ xsinc;
            cosmth(ii,1:npbnd) = atan(zsmth(1:npbnd));
        end % 680
    end
    if(isep>1 & ibsmth==2), ibsmth=1; end

    disp('shot  ray i.angle  f.angle   dist     depth red.time  npts code');
    if idump == 1
        fprintf('\ngr ray npt   x       z      ang1    ang2    v1     v2  lyr bk id iw\n');
    end

    if nrskip<1, nrskip=1; end
    if hws<0, hws=(xmax-xmin)./25; end
    hwsm = hws;
    crit = crit ./ pi18;

    if any(nrbnd(1:prayf)>prefl)
        % ?... go to 900
        error('e:test','\n***  max reflecting boundaries exceeded  ***\n');
    end % 260

    if any(rbnd(1:preflt)>nlayer)
        disp(sprintf('\n***  reflect boundary greater than # of layers  ***\n'));
    end % 710

    if nsmax(1) < 0
        nsmax(1:ngroup) = 10; % 350
    else
        if nsmax(2)<0 & ngroup>1
            nsmax(2:ngroup) = nsmax(1); % 360
        end
    end

    if nsmin < 0
        nsmin(1:ngroup) = 1000000.0; % 351
    else
        if nsmin(2)<0 & ngroup>1
            nsmin(i) = nsmin(1); % 361
        end
    end


    % assign default values to smin and smax if not specified
    if smin<0, smin=(xmax-xmin)./4500.0; end
    if smax<0, smax=(xmax-xmin)./15.0; end

    if ximax<0, ximax=(xmax-xmin)./20.0; end
    ist = 0;
    iflagp = 0;

    if ifast == 1
        if ntan>pitan, ntan=pitan; end
        ntan = 2 * ntan;
        ainc = pi ./ ntan; % ?... ainc=pi/float(ntan)
        factan = ntan ./ pi; % ?... factan=float(ntan)/pi

        % 6010
        angtan(1:ntan) = (0:ntan-1) .* pi ./ ntan; % ?... float
        tatan(1:ntan) = tan(angtan(1:ntan));
        % 6020
        mtan(1:ntan-1) = (tatan(2:ntan)-tatan(1:ntan-1)) ./ ainc;
        btan(1:ntan-1) = tatan(1:ntan-1) - mtan(1:ntan-1).*angtan(1:ntan-1);
        % 6030
        tatan(2:ntan) = 1.0 ./ tan(angtan(2:ntan));
        % 6040
        mcotan(1:ntan-1) = (tatan(2:ntan)-tatan(1:ntan-1)) ./ ainc;
        bcotan(1:ntan-1) = tatan(1:ntan-1) - mcotan(1:ntan-1).*angtan(1:ntan-1);
    end

    isGoto1000 = false;
    if nshot==0, isGoto1000=true; end

    if ~isGoto1000
    for is = 1:nshot
        isGoto69 = false;
        ist = ist + 1;
        id = idr(is);
        fid = id;
        xshotr = xshota(is);
        zshotr = zshota(is);
        if ist == 1
            xsec = xshotr;
            zsec = zshotr;
            idsec = id;
            ics = 1;
            % 810
            tang(1:nlayer,1:4) = 999.0;
        else
            if abs(xshotr-xsec)<0.001 & abs(zshotr-zsec)<0.001
                if iflags == 1, continue; end
                ics = 0;
                if id ~= idsec
                    % 830
                    tang(1:nlayer,1:4) = 999.0;
                end
            else
                xsec = xshotr;
                zsec = zshotr;
                idsec = id;
                ics = 1;
                % 820
                tang(1:nlayer,1:4) = 999.0;
            end
        end
        if ics == 1
            [xpt,zpt,layers,iblks,iflag] = fun_xzpt(xpt,zpt,layers,iblks,iflag);
            if iflags == 1
                fprintf(fID_11,'***  location of shot point outside model  ***\n');
                continue;
            end

            if (imod==1 | iray>0 | irays==1) & isep>1
                if iflagp == 1
                    % ?... call aldone
                end
                iflagp = 1;
                % ?... call pltmod(ncont,ibnd,imod,iaxlab,ivel,velht,idash,ifrbnd,idata,iroute,i33)
            end
        end
        irbnd = 0;
        ictbnd = 0;

        for ii = 1:ngroup
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
            fid = id;
            fid1 = fid;
            % 250
            refll(1:prefl+1) = 0;
            % 251
            icbnd(1:pconv+1) = -1;
            ifam = ifam + 1;
            nrayr = nrayr(ii);
            iflagl = 0;
            ibrka(ifam) = ibreak(ii);
            ivraya(ifam) = ivray(ii);
            % 870
            iheadf(1:nlayer) = ihead(1:nlayer);
            idl = floor(ray(ii));
            idt = floor((ray(ii)-idl).*10.0+0.5);
            if idt == 2
                if nrbnd(ii) > (prefl-1)
                    fprintf('\n***  max reflecting boundaries exceeded  ***\n\n');
                    fprintf(fID_11,'***  shot#%4d ray code%5.1f no rays traced  ***\n',ishotw(is),ray(ii));
                    nrayr = 0;
                    isGoto69 = true;
                end
                if ~isGoto69 % --1
                refll(1) = idl;
                if nrbnd(ii) > 0
                    for jj = 1:nrbnd(ii)
                        irbnd = irbnd + 1;
                        refll(jj+1) = rbnd(irbnd);
                    end % 230
                end
                end % if ~isGoto69 --1
            else
                if nrbnd(ii) > 0
                    for jj = 1:nrbnd(ii)
                        irbnd = irbnd + 1;
                        refll(jj) = rbnd(irbnd);
                    end % 240
                end
            end
            if ~isGoto69 % --2
            if idt == 3
                iheadf(idl) = 1;
                ihdwf = 1; ihdwm = 1;
                hws = hwsm;
                tdhw = 0.0;
                if nhray < 0, nrayr = pnrayf;
                else nrayr = nhray; end
            else
                ihdwf = -1; ihdwm = -1;
            end
            if ncbnd(ii) > 0
                for jj = 1:ncbnd(ii)
                    ictbnd = ictbnd + 1;
                    icbnd(jj) = cbnd(ictbnd);
                end % 630
            end
            idifff = 0;

            if ircol==1, irrcol=colour(mod(ivray(ii)-1,ncol)+1); end
            if ircol==2, irrcol=colour(mod(is-1,ncol)+1); end
            if ircol==3, irrcol=colour(mod(ii-1,ncol)+1); end
            if ircol< 0, irrcol=-ircol; end

            if nrayr <= 0, isGoto69=true; end
            if ~isGoto69 % --2.1

            end % if ~isGoto69 --2.1
            end % if ~isGoto69 --2
            % 69
            if iflagl == 1, flag = '*';
            else flag = ' '; end
            fprintf('shot#%4d:   ray code%5.1f:   %3d rays traced %1s',ishotw(is),ray(ii),nrayr,flag);
            if ntt > pray
                isGoto1000 = true; break; % go to 1000
            end
        end % 70
        if isGoto1000, break; end
        if isep==2 & ((itx>0 & ntt>1) | idata~=0 | itxout>0)
            % ?... call plttx()
        end
    end % 60
    end % if ~isGoto1000

    % 1000

    fclose('all');
% main function end
end


%% fun_pltmod: plot model
function [outputs] = fun_pltmod(ncont,ibnd,imod,iaxlab,ivel,velht,idash,...
    ifrbnd,idata,iroute,i33)
    outputs = 0;
end

function [xpt,zpt,layers,iblks,iflag] = fun_xzpt(xpt,zpt,layers,iblks,iflag)
    global file_rayinvr_par file_rayinvr_com;
    run(file_rayinvr_par);
    run(file_rayinvr_com);

    iflag = 0;
    for ii = 1:nlayer
        for jj = 1:nblk(ii)
            top = s(ii,jj,1) .* xpt + b(ii,jj,1);
            bottom = s(ii,jj,2) .* xpt + b(ii,jj,2);
            left = xbnd(ii,jj,1);
            right = xbnd(ii,jj,2);
            if zpt+0.001<top | zpt-0.001>bottom | xpt+0.001<left | xpt-0.001>right | abs(top-bottom)<0.001
                continue; % go to 20
            end
            layers = ii;
            iblks = jj;
            return;
        end % 20
    end % 10
    iflag = 1;
    return;
end

function [col1,col2,col3,col4] = fun_load_txin(file_txin)
    %tx.in文件可以看作n行×4列的矩阵

    txData = load(file_txin,'-ascii');
    % tx.in的结束行为 0 0 0 -1
    endLine = find(txData(:,2)==0 & txData(:,4)==-1,1);
    txData = txData(1:endLine-1,:);
    [col1,col2,col3,col4] = deal(txData(:,1),txData(:,2),txData(:,3),txData(:,4));
end

function fun_goto9999()
    global file_nout;
    global pltpar axepar trapar invpar;
    fID_22 = fopen(file_nout,'w');
    fun_writeNamelist(fID_22,'PLTPAR',pltpar);
    fun_writeNamelist(fID_22,'AXEPAR',axepar);
    fun_writeNamelist(fID_22,'TRAPAR',trapar);
    fun_writeNamelist(fID_22,'INVPAR',invpar);
    fclose(fID_22);
end
%% _writeNamelist: 将一个namelist中的所有变量写入指定文件
function fun_writeNamelist(fid,name,namelist)
    eval(['global ',namelist]);
    clist = strsplit(namelist);
    if clist{end}=='', clist(end)=[]; end
    fprintf(fid, '&%s\n', name);
    for parname = clist
        fprintf(fid, '%s=', parname);
        par = eval(parname);
        ii = 1; count = 1;
        par = [par, -123454321]
        while ii < length(par)
            if par(ii) ~= par(ii+1)
                if count == 1
                    fprintf(fid, '  %10f    ,', par(ii));
                else
                    fprintf(fid, ' %d*%10f      ,', count,par(ii));
                end
                count = 1;
            else
                count = count + 1;
            end
            ii = ii + 1;
        end
        fprintf(fid, '\n');
    end
    fprintf(fid, ' /\n');
end

% 9000
function fun_goto900()
    global fID_11;
    ntblk = sum(nblk(1:nlayer)); % 920
    tempstr = sprintf(['\n|------------------------------------------',...
        '----------------------|\n|%64s|\n'], ''); % 935
    if isum>0, disp(tempstr); end
    fprintf(fID_11, tempstr);
    if ntpts > 0
        tempstr = sprintf(['| total of %6d rays consisting of %8d points ',...
            'were traced |\n|%64s|\n'], ntray,ntpts,''); % 905
    else
        tempstr = sprintf(['|                   ***  no rays traced  ***',...
            '%21s|\n|%64s|\n'], '',''); % 915
    end
    if isum>0, disp(tempstr); end
    fprintf(fID_11, tempstr);

    tempstr = sprintf(['|           model consists of %2d layers and %3d ',...
        'blocks           |\n|%64s|\n|----------------------------------',...
        '------------------------------|\n\n'], nlayer,ntblk,''); % 925
    if isum>0, disp(tempstr); end
    fprintf(fID_11, tempstr);

    if invr == 1
        fID_18 = fopen(file_iout,'w');
        parunc(1) = bndunc;
        parunc(2) = velunc;
        parunc(3) = bndunc;
        fprintf(fID_18, ' \n%5d\n', narinv,nvar); % 895 835
        for ii = 1:nvar
            fprintf(fID_18,'%5d%15.5f%15.5f\n',partyp(ii),parorg(ii),parunc(partyp(ii))); % 805
        end % 801
        fprintf(fID_18, ' \n');
        for ii = 1:narinv
            fprintf(fID_18,'%12.5e%12.5e%12.5e%12.5e%12.5e\n',apart(ii,1:nvar)); % 815
        end % 840
        fprintf(fID_18,' \n%12.5e%12.5e%12.5e%12.5e%12.5e\n',tobs(1:narinv)-tcalc(1:narinv));
        fprintf(fID_18,' \n%12.5e%12.5e%12.5e%12.5e%12.5e\n',uobs(1:narinv));

        if narinv > 1
            % 850
            temp = tobs(1:narinv)-tcalc(1:narinv);
            ssum = sum(temp .^ 2);
            sumx = sum((temp./uobs(1:narinv)) .^ 2);
            trms = sqrt(ssum ./ narinv);
            chi = sumx ./ (narinv-1);
            tempstr = sprintf([' \nNumber of data points used: %8d\n',...
                'RMS traveltime residual:    %8.3f\n',...
                'Normalized chi-squared:   %10.3f\n \n'], narinv,trms,chi); % 825
            fprintf(fID_18, tempstr);
            fprintf(tempstr);
            fprintf(fID_11, tempstr);

            if isum > 1
                tempstr = sprintf([' phase    npts   Trms   chi-squared\n',...
                    '-----------------------------------\n']); % 968
                fprintf(fID_11, tempstr);
                if isum==3, fprintf(tempstr); end
                nused = 0; jj = 0;
                while nused < narinv
                    jj = jj + 1;
                    % 952
                    tempindex = find(abs(icalc(1:narinv)==jj));
                    temp = tobs(tempindex) - tcalc(tempindex);
                    ssum = sum(temp .^ 2);
                    sumx = sum((temp./uobs(tempindex)) .^ 2);
                    nars = length(tempindex);
                    nused = nused + length(tempindex);
                    if nars > 0, trms = sqrt(ssum ./ nars); end
                    if nars > 1, chi = sumx ./ (nars-1);
                    else chi = sumx; end
                    if nars > 0
                        tempstr = sprintf('%6d%8d%8.3f%10.3f\n', jj,nars,trms,chi); % 969
                        fprintf(fID_11, tempstr);
                        if isum==3, fprintf(tempstr); end
                    end
                end % 951

                tempstr = sprintf([' \n     shot  dir   npts   Trms   chi-squared',...
                    '\n------------------------------------------\n']); % 868
                fprintf(fID_11, tempstr);
                if isum==3, fprintf(tempstr); end
                xsn = xscalc(1);
                icn = sign(1 .* icalc(1));
                for jj = 1:nshot
                    iflagn = 1;
                    xsc = xsn;
                    icc = icn;
                    ssum = 0.0; sumx = 0.0;
                    nars = 0;
                    for ii = 1:narinv
                        if xscalc(ii)==xsc & sign(icalc(ii))==icc & icalc(ii)~=0
                            tdiff = abs(tobs(ii)-tcalc(ii));
                            ssum = ssum + tdiff .^ 2;
                            sumx = sumx + (tdiff./uobs(ii)) .^ 2;
                            nars = nars + 1;
                            icalc(ii) = 0;
                        else
                            if iflagn==1 & icalc(ii)~=0
                                xsn = xscalc(ii);
                                icn = sign(icalc(ii));
                                iflagn = 0;
                            end
                        end
                    end % 852
                    if nars>0, trms=sqrt(ssum./nars); end
                    if nars>1, chi=sumx./(nars-1);
                    else chi=sumx; end
                    if nars > 0
                        tempstr = sprintf('%10.3f%3d%8d%8.3f%10.3f\n',xsc,icc,nars,trms,chi);
                        fprintf(fID_11, tempstr);
                        if isum==3, fprintf(tempstr); end
                    end
                end % 851
                fprintf(fID_11, ' \n');
                if isum==3, fprintf(' \n'); end
            end
        end
        fclose(fID_18);
    end
    if iplots == 1
        % ?... call plotnd(1)
    end
    fun_goto9999(); return;
end