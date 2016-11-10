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

    file_rin = fullfile(filePathIn,'r.in');
    file_vin = fullfile(filePathIn,'v.in');
    file_txin = fullfile(filePathIn,'tx.in');
    file_fin = fullfile(filePathIn,'f.in');
    file_rayinvr_par = fullfile(filePathIn,'rayinvr.par');
    file_rayinvr_com = fullfile(filePathIn,'rayinvr.com');

    file_r1out = fullfile(filePathOut,'r1.out');
    file_r2out = fullfile(filePathOut,'r2.out');
    file_ra1out = fullfile(filePathOut,'ra1.out');
    file_ra2out = fullfile(filePathOut,'ra2.out');
    file_txout = fullfile(filePathOut,'tx.out');
    file_fdout = fullfile(filePathOut,'fd.out');
    file_nout = fullfile(filePathOut,'n.out');
    file_tout = fullfile(filePathOut,'t.out');
    file_pout = fullfile(filePathOut,'p.out');
    file_vout = fullfile(filePathOut,'v.out');


    %% 1 variables
    %% 1.1 声明rayinvr.par文件中的变量并赋值
    run(file_rayinvr_par);

    %% 1.2 声明main函数中的变量
    mainPar1 = [
        'amin amax xshot space zshot pois poisbl parunc zsmth xshota zshota ',...
        'ta2pt ra2pt tt2pt xo2pt ho2pt tatan angtan ',... % real
        'idr nray itt ibrka ishot ncbnd ivraya ishotr nrbnd rbnd nsmax ',...
        'ishotw iturn cbnd irayt ihead poisl poisb ibreak frbnd ifo2pt ipos ',...
        'modi nsmin insmth ',... % integer
        'flag ',... % character
    ];
    eval(['global ',mainPar1]);

    %% 1.3 声明rayinvr.com文件中的变量并赋值
    run(file_rayinvr_com);

    %% 1.4 声明namelist/r.in中的变量
    pltpar = [
        'iplot imod ibnd idash ivel iray irays irayps idot itx idata iszero ',...
        'itxout istep ibreak idump isum symht velht nskip nrskip vred dvmax ',...
        'dsmax isep iroute itcol ircol mcol itxbox iseg xwndow ywndow colour ',...
        'ibcol ifcol modout dxmod dzmod modi frz xmmin xmmax xmin1d xmax1d ',...
        'npskip ifd dxzmod title xtitle ytitle iline ',... % namelist /pltpar/
    ];
    axepar = [
        'iaxlab itrev albht orig sep xmin xmax xtmin xtmax xmm ntickx ',...
        'ndecix xmint xmaxt xtmint xtmaxt xmmt ntckxt ndecxt zmin zmax ',...
        'ztmin ztmax zmm ntickz ndeciz tmin tmax ttmin ttmax tmm ntickt ',...
        'ndecit ',... % namelist /axepar/
    ];
    trapar = [
        'ishot iraysl irayt iturn isrch istop ibsmth imodf xshot zshot ray ',...
        'nray space amin amax nsmax aamin aamax stol xsmax step smin smax ',...
        'nrbnd rbnd ncbnd cbnd pois poisb poisl poisbl crit hws npbnd nbsmth ',...
        'nhray frbnd nsmin i2pt n2pt x2pt ifast ntan idiff xminns xmaxns ',...
        'insmth aainc ',... % namelist /trapar/
    ];
    invpar = ['invr ivray ximax ttunc velunc bndunc']; % namelist /invpar/
    rinpar = strjoin({pltpar,axepar,trapar,invpar},' ');
    eval(['global ',rinpar]);

    % 1.5 声明main中剩余部分变量并为main中所有变量赋值
    mainPar2 = [
        'iline ititle xtitle ytitle ifd xminns xmaxns npskip idiff ntan ',...
        'ifast xmin1d xmax1d istep iroute xmmin xmmax frz dxmod dzmod ',...
        'dxzmod modout i2pt n2pt x2pt itxbox nhray ircol itcol isep velunc ',...
        'bndunc dvmax dsmax itrev xsmax ntray ntpts isrch istop nstepr ',...
        'narinv nrskip itxout idata isum idash ivel iaxlab idot iszero ibnd ',...
        'imod iray irayps nskip invr imodf irays iraysl ncont iflagi nrayl ',...
        'ifam ictbnd irbnd nshot ngroup ia0 ttunc stol velht aamin aamax ',...
        'aainc aaimin ximax i33 ',... % other
    ];
    mainPar = strjoin({mainPar1,mainPar2},' ');
    eval(['global ',mainPar]);
    init_main(strjoin({mainPar,rayinvrPar},' '));

    % 1.6 为r.in中的所有变量赋值
    % 将r.in文件转化为r_in.m脚本
    file_rin_m = fun_trans_rin2m(file_rin);
    run(file_rin_m); % 载入脚本，为r.in中所有变量赋值

    %% 2 main
    % 如果未指定xmax，则程序结束
    if xmax < -99998
        error(sprintf('\n***  xmax not specified  ***\n'));
    end
    % 如果imodf不等于1，表面速度模型保存在r.in文件的最后部分；否则，有专门的v.in文件保存
    if imodf ~= 1
        error(sprintf('\n***  此选项废弃，请使用单独的v.in文件  ***\n'));
    end
    if mod(ppcntr,10) ~= 0 | mod(ppvel,10) ~= 0
        % ?...将4个namelist中的所有变量保存到n.out文件
        error(sprintf('\n***  array size error for number of model points  ***\n'));
    end

    % 2.1 读入v.in
    % [model,LN,xmin,xmax,zmin,zmax,precision,xx,ZZ,mError]=fun_load_vin(file_vin);
    [model,ncont,~,~,~,~,~,~,~,mError]=fun_load_vin(file_vin);
    error(mError);
    % 将得到的模型（model）转为源程序中的形式：xm,zm,ivarz；xvel,vf,ivarv
    % 由于模型每层存储的数组是不等长的，所以通过cell来保存，而不是二维矩阵。
    xm = arrayfun(@(x) x.bd(1,:),model,'UniformOutput',false);
    zm = arrayfun(@(x) x.bd(2,:),model,'UniformOutput',false);
    ivarz = arrayfun(@(x) x.bd(3,:),model(1:end-1),'UniformOutput',false);

    xvel = arrayfun(@(x) [x.tv(1,:);x.bv(1,:)],model(1:end-1),'UniformOutput',false);
    vf = arrayfun(@(x) [x.tv(2,:);x.bv(2,:)],model(1:end-1),'UniformOutput',false);
    ivarv = arrayfun(@(x) [x.tv(3,:);x.bv(3,:)],model(1:end-1),'UniformOutput',false);
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
    xscale = (xmax-xmin) / xmm;
    xscalt = (xmaxt-xmint) / xmmt;
    zscale = -(zmax-zmin) / zmm;
    tscale = (tmax-tmin) / tmm;

    if itrev==1, tscale = -tscale; end
    if iroute~=1, ibcol = 0; end
    if isep==2 & imod==0 & iray==0 & irays==0, isep = 3; end
    if n2pt>pn2pt, n2pt = pn2pt; end
    if i2pt==0, x2pt = 0; end
    if x2pt<0, x2pt = (xmax-xmin) / 2000; end

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
        error(sprintf('\n***  no ray codes specified  ***\n'));
        % ?... go to 900
    end

    ifrbnd = 0;
    if any( frbnd(1:ngroup)<0 ) | any( frbnd(1:ngroup)>pfrefl )
        error(sprintf('\n***  error in array frbnd  ***\n'));
    end
    if any( frbnd(1:ngroup)>0 )
        ifrbnd = 1;
    end

    % 读取f.in文件到xfrefl,zfrefl,ivarf三个二维数组中（类似v.in的结构）
    if ifrbnd == 1
        [nfrefl,xfrefl,zfrefl,ivarf] = fun_load_fin(file_fin);

        if any( frbnd(1:ngroup)>nfrefl )
            error(sprintf('\n***  error in array frbnd  ***\n'));
        end
    end


    % calculate velocity model parameters
    % ?...
    calmodPar = strjoin({rayinvrPar,rayinvrCom,rayinvrCom_common},' ');
    [ncont,pois,poisb,poisl,poisbl,invr,iflagm,ifrbnd,...
        xmin1d,xmax1d,insmth,xminns,xmaxns] = fun_calmod(calmodPar);

    if abs(modout) ~= 0 | ifd > 1
        if xmmin < -999998, xmmin = xmin; end
        if xmmax < -999998, xmmax = xmax; end

        if dxmod == 0, dxmod = (xmmax-xmmin) / 20.0; end
        if dzmod == 0, dzmod = (zmax-zmin) / 10.0; end
        if dxzmod == 0, dxzmod = (zmax-zmin) / 10.0; end

        nx = round((xmmax-xmmin)/dxmod);
        nz = round((zmax-zmin)/dzmod);

        if abs(modout) >= 2
            sample(1:nz,1:nx) = 0;
        end
    end

    if itx>=3 & invr==0, itx = 2; end
    if itxout==3 & invr==0, itxout = 2; end
    if invr==0 & abs(idata)==2, idata = 1 * sign(idata); end
    if iflagm==1
        % ?... go to 9999
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
    zshift = abs(zmax-zmin) / 10000.0;
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
    if stol < 0, stol = (xmax-xmin)/3500.0; end


    % check array ncbnd for array values greater than pconv
    if any(ncbnd(1:prayf)>pconv)
        % ?... go to 900
        error(sprintf('\n***  max converting boundaries exceeded  ***\n'));
    end
    % 470


    % plot velocity model
    if (imod==1 | iray>0 | irays==1) & isep<2
        fun_pltmod();
    end


    % calculation of smooth layer boundaries
    size(cosmth),size(xsinc),size(zsmth)
    if ibsmth > 0 
        for ii = 1:nlayer+1
            zsmth(1) = (cosmth(ii,2)-cosmth(ii,1)) / xsinc;
            zsmth(2:npbnd-1) = (cosmth(ii,3:npbnd)-cosmth(ii,0:npbnd-2)) / (2.0*xsinc);
            zsmth(npbnd) = (cosmth(ii,npbnd)-cosmth(ii,npbnd-1)) / xsinc;
            cosmth(ii,1:npbnd) = atan(zsmth(1:npbnd));
        end % 680
    end
    if(isep>1 & ibsmth==2), ibsmth=1; end

    disp('shot  ray i.angle  f.angle   dist     depth red.time  npts code');
    if idump == 1
        fprintf('\ngr ray npt   x       z      ang1    ang2    v1     v2  lyr bk id iw\n');
    end

    if nrskip<1, nrskip=1; end
    if hws<0, hws=(xmax-xmin)/25; end
    hwsm = hws;
    crit = crit / pi18;

    if any(nrbnd(1:prayf)>prefl)
        % ?... go to 900
        error(sprintf('\n***  max reflecting boundaries exceeded  ***\n'));
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
    if smin<0, smin=(xmax-xmin)/4500.0; end
    if smax<0, smax=(xmax-xmin)/15.0; end

    if ximax<0, ximax=(xmax-xmin)/20.0; end
    ist = 0;
    iflagp = 0;

    if ifast == 1
        if ntan>pitan, ntan=pitan; end
        ntan = 2 * ntan;
        ainc = pi / ntan; % ?... ainc=pi/float(ntan)
        factan = ntan / pi; % ?... factan=float(ntan)/pi

        angtan(1:ntan) = (0:ntan-1) .* pi / ntan; % ?... float
        tatan(1:ntan) = tan(angtan(1:ntan)); % 6010
    end



    fclose('all');
% main function end
end


%% fun_pltmod: plot model
function [outputs] = fun_pltmod(ncont,ibnd,imod,iaxlab,ivel,velht,idash,...
    ifrbnd,idata,iroute,i33)
    outputs = 0;
end

%% fun_calmod: function description
function [ncont,pois,poisb,poisl,poisbl,invr,iflagm,ifrbnd,xmin1d,xmax1d,insmth,xminns,xmaxns] = fun_calmod(globalParams)

    % temp = num2cell(zeros(1,13));
    % [ncont,pois,poisb,poisl,poisbl,invr,iflagm,ifrbnd,...
    %     xmin1d,xmax1d,insmth,xminns,xmaxns] = deal(temp{:});
    eval(['global ',globalParams]);
    global pois poisbl poisb poisl insmth

    xa = zeros(1,2*(ppcntr+ppvel));
    zsmth = zeros(1,pnsmth);
    % pois = zeros(1,player);
    % poisbl = zeros(1,papois);
    % zsmth = zeros(pnsmth);

end

%% fun_load_fin: read in floating reflectors
%% f.in文件结构与v.in类似，只不过每个小节前面增加了一个描述本层节点数目的整数
function [nfrefl,xfrefl,zfrefl,ivarf,npfref,fmodel]=fun_load_fin(file_fin)
    % read in floating reflectors

    fid = fopen(filein,'r');
    count=0;
    imdata={};
    line = fgetl(fid);
    while ischar(line)
        count=count+1;
        imdata{count,1}=line;
        line = fgetl(fid);
    end
    fclose(fid);

    line=imdata{2};
    value=sscanf(line,'%i');
    startnum=value(1);  %the start number of floating reflector
    line=imdata{length(imdata)-2};
    value=sscanf(line,'%i');
    endnum=value(1);  %the end number of floating reflector

    fmodel={};
    pp=1;  % first line of the v.in
    error={};
    errorcount=0;
    for i=startnum:endnum
        line=imdata{(i-1)*4+1};
        value=sscanf(line,'%i');
        nn=value;   %the number of nodes
        if nn<2 || nn>ppfref
            error(sprintf('\n***  error in f.in file  ***\n'));
        end
        over10=1; % assume nodes number larger than 10
        final=[];
        while over10
            vv=cell(3,1);
            vl=zeros(3,1); %length
            for j=1:3; % x, z, partial derivative
                pp=pp+1;
                value=sscanf(imdata{pp},'%f'); % read values
                vv{j}=value'; % transverse to line vector
                vl(j)=length(value);
            end
            if vl(2)-vl(1)>2 || vl(3)~=vl(1)-1;
                errorcount=errorcount+1;
                error{errorcount}=['Number ',num2str(i),', parameter ',num2str(j),': Node numbers do not equal!'];
            elseif vl(2)==vl(1)-1;
                over10=0;
            elseif vl(2)==vl(1);
                if vv{2}(1)==0,
                    over10=0;
                end
            end
            [ll,cc]=size(final);
            final(:,cc+1:cc+vl(3))=[vv{1}(2:end); vv{2}(end-vl(3)+1:end); vv{3}];
        end
        [ll,cc]=size(final);
        temp(1,1:cc)=[nn, zeros(1,cc-1)];
        final=[temp; final];
        fmodel{i}=final;
        pp=pp+1;
        xfrefl(i,1:nn)=final(2,:);
        zfrefl(i,1:nn)=final(3,:);
        ivarf(i,1:nn)=final(4,:);
        npfref(i,1)=nn;
    end
    nfrefl=endnum;  %total number of nodes
end


function [col1,col2,col3,col4] = fun_load_txin(file_txin)
    %tx.in文件可以看作n行×4列的矩阵

    txData = load(file_txin,'-ascii');
    % tx.in的结束行为 0 0 0 -1
    endLine = find(txData(:,2)==0 & txData(:,4)==-1);
    txData = txData(1:endLine-1,:);
    [col1,col2,col3,col4] = deal(txData(:,1),txData(:,2),txData(:,3),txData(:,4));
end

function init_main(globalParams)
    %声明main函数中的参数
    eval(['global ',globalParams]);

    %real
    amin = ones(1,prayt) * 181.;
    amax = ones(1,prayt) * 181.;
    xshot = zeros(1,pshot);
    space = zeros(1,prayf);
    zshot = ones(1,pshot) * -9999.;
    pois = ones(1,player) * -99.;
    poisbl = ones(1,papois) * -99.;
    parunc = zeros(1,3);
    zsmth = zeros(1,pnsmth);
    xshota = zeros(1,pshot2);
    zshota = zeros(1,pshot2);
    ta2pt = zeros(1,pr2pt);
    ra2pt = zeros(1,pr2pt);
    tt2pt = zeros(1,pr2pt);
    xo2pt = zeros(1,pnobsf);
    ho2pt = zeros(1,pr2pt);
    tatan = zeros(1,pitan2);
    angtan = zeros(1,pitan2);

    %integer
    idr = zeros(1,pshot2);
    nray = ones(1,prayf) * -1;
    itt = zeros(1,ptrayf);
    ibrka = zeros(1,ptrayf);
    ishot = zeros(1,pshot);
    ncbnd = ones(1,prayf) * -1;
    ivraya = zeros(1,ptrayf);
    ishotr = zeros(1,pshot2);
    nrbnd = zeros(1,prayf);
    rbnd = zeros(1,preflt);
    nsmax = ones(1,prayf) * -1;
    ishotw = zeros(1,pshot2);
    iturn = ones(1,prayf) * 1;
    cbnd = ones(1,pconvt) * -99;
    irayt = ones(1,prayt) * 1;
    ihead = zeros(1,player);
    poisl = zeros(1,papois);
    poisb = zeros(1,papois);
    ibreak = ones(1,prayf) * 1;
    frbnd = zeros(1,prayf);
    ifo2pt = zeros(1,pnobsf);
    ipos = zeros(1,pr2pt);
    modi = zeros(1,player);
    nsmin = ones(1,prayf) * -1;
    insmth = zeros(1,pncntr);

    %character
    flag = '';
    %other
    iline=0;
    ititle=0;
    xtitle=-9999999.;
    ytitle=-9999999.;
    title=' ';
    ifd=0;
    xminns=-999999.;
    xmaxns=-999999.;
    npskip=1;
    idiff=0;
    ntan=90;
    ifast=1;
    xmin1d=-999999.;
    xmax1d=-999999.;
    istep=0;
    iroute=1;
    xmmin=-999999.;
    xmmax=-999999.;
    frz=0.;
    dxmod=0.;
    dzmod=0.;
    dxzmod=0.;
    modout=0;
    i2pt=0;
    n2pt=5;
    x2pt=-1.;
    itxbox=0;
    nhray=-1;
    ircol=0;
    itcol=0;
    isep=0;
    velunc=0.1;
    bndunc=0.1;
    dvmax=1.e10;
    dsmax=1.e10;
    itrev=0;
    xsmax=0.;
    ntray=0;
    ntpts=0;
    isrch=0;
    istop=1;
    nstepr=15;
    narinv=0;
    nrskip=1;
    itxout=0;
    idata=0;
    isum=1;
    idash=1;
    ivel=0;
    iaxlab=1;
    idot=0;
    iszero=0;
    ibnd=1;
    imod=1;
    iray=1;
    irayps=0;
    nskip=0;
    invr=0;
    imodf=0;
    irays=0;
    iraysl=0;
    ncont=1;
    iflagi=0;
    nrayl=0;
    ifam=0;
    ictbnd=0;
    irbnd=0;
    nshot=0;
    ngroup=0;
    ia0=1;
    ttunc=.01;
    stol=-1.;
    velht=.7;
    aamin=5.;
    aamax=85.;
    aainc=.1;
    aaimin=1.;
    ximax=-1.;
    i33=0;
end
