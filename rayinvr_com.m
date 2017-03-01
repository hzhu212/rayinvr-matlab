%% initialize all parameters in rayinvr.com.

global has_rayinvr_com_init;

% changed 'ar' to 'ar_' to avoid name conflict.
% changed 'step' to 'step_'.
% changed 'range' to 'range_'.
% changed 'title' to 'title_'.

% common
global layer iblk id fid fid1;  %  blk1
global c ivg;  %  blk2
global s b vm;  %  blk3
global xbnd nblk nlayer;  %  blk4
global xm zm vf nzed nvel xvel;  %  blk5
global xr zr ar_ vr tr vp vs;  %  blk6
global refll ircbnd;  %  blk7
global irkc tol hdenom hmin idump isrkc ifast;  %  blk8
global itx vred time timertimer;  %  blk9
global step_ smin smax;  %  blk10
global range_ tt rayid xshtar fidarr idray ntt ray;  %  blk11
global xmin xmax xtmin xtmax xmm ndecix xscale ntickx xmint xmaxt xtmint ...
       xtmaxt xmmt ndecxt xscalt ntckxt zmin zmax ztmin ztmax zmm ndeciz ...
       zscale ntickz tmin tmax ttmin ttmax tmm ndecit tscale ntickt symht ...
       albht iplots orig sep title_ ititle xtitle ytitle ircol mcol irrcol ...
       itcol ncol colour;  %  blk12
global icasel dstepf n2 n3 istop nstepr;  %  blk13
global iwave nccbnd iccbnd icbnd vsvp;  %  blk14
global isrch tang;  %  blk15
global ntray ntpts;  %  blk16
global ibsmth nbsmth npbnd cosmth xsinc;  %  blk17
global nptbnd;  %  blk18
global ivarz ivarv ivarf ivv izv cz cv partyp nvar parorg;  %  blk19
global apart fpart tobs uobs tcalc xcalc xscalc ipinv ivray narinv icalc ...
       ircalc;  %  blk20
global ninv xfinv tfinv;  %  blk21
global iheadf hws crit dhw tdhw ihdwf ihdw nhskip idiff idifff;  %  blk22
global dvmax dsmax idvmax idsmax ldvmax ldsmax;  %  blk23
global xpf tpf upf ipf ilshot;  %  blk24
global nfrefl npfref xfrefl zfrefl ifcbnd;  %  blk25
global sample;  %  blk26
global nbnd nbnda npskip npskp;  %  blk27
global mtan btan mcotan bcotan factan;  %  blktan
global iplot isep iseg nseg xwndow ywndow ibcol ifcol sf;  %  cplot

% common /rkcs/ in rngkta, odex and odez
global ok;

% these varables come from blkdat.f
% fortran 中全局变量(common变量)不能直接使用 data 语句赋值，只能通过 block data 模块赋初值
% if isempty(has_rayinvr_com_init)
%     [irkc,tol,hdenom,hmin,idump] = deal(0,0.0005,64.0,0.01,0);
%     [itx,vred] = deal(1,8.0);
%     nzed = ones(1,pncntr);
%     % nvel = ones(1,pinvel);
%     nvel = ones(player,2);
%     [step_,smin,smax] = deal(0.05,-1.0,-1.0);
%     ntt = 1;
%     ray = zeros(1,prayf);
%     [xmin,xmax,xmm,ndecix,ntickx] = deal(0.0,-99999.0,250.0,-2,-1);
%     [xmint,xmaxt,xmmt,ndecxt,ntckxt] = deal(-9999.0,-9999.0,-9999.0,-2,-1);
%     [zmin,zmax,zmm,ndeciz,ntickz] = deal(0.0,50.0,75.0,-2,-1);
%     [tmin,tmax,tmm,ndecit,ntickt] = deal(0.0,10.0,75.0,-2,-1);
%     [xtmin,xtmax,xtmint,xtmaxt,ztmin,ztmax,ttmin,ttmax] = deal(-999999.0);
%     [symht,albht] = deal(0.5,2.5);
%     [ibsmth,nbsmth,npbnd] = deal(0,10,100);
%     % cv = zeros(1,picv);
%     cv = zeros(player,ptrap,4,5);
%     [crit,hws] = deal(1.0,-1.0);
%     [iplot,iplots,orig,sep,iseg,nseg] = deal(1,0,12.5,7.5,0,0);
%     [xwndow,ywndow] = deal(0.0);
%     colour = ones(1,pcol) .* (-1);
%     mcol = ones(1,5) .* (-1);
%     [sf,ibcol,ifcol] = deal(1.2,0,1);
% end

% 为数组赋初值
if isempty(has_rayinvr_com_init)
    %integer
    refll = zeros(1,prefl+1);
    nblk = zeros(1,player);
    ivarz = zeros(player,ppcntr);
    idray = zeros(1,2);
    partyp = zeros(1,pnvar);
    iheadf = zeros(1,player);
    nzed = ones(1,pncntr);
    icbnd = zeros(1,pconv+1);
    ivg = zeros(player,ptrap);
    izv = zeros(player,ptrap,4);
    ivv = zeros(player,ptrap,4);
    ivray = zeros(1,prayf);
    ipinv = zeros(1,prayi);
    nvel = ones(player,2);
    ivarv = zeros(player,ppvel,2);
    ldvmax = zeros(1,player);
    ldsmax = zeros(1,pncntr);
    ipf = zeros(1,prayi+pshot2+1);
    ilshot = zeros(1,pshot2+1);
    icalc = zeros(1,prayi);
    npfref = zeros(1,pfrefl);
    colour = zeros(1,pcol) .* (-1);
    mcol = ones(1,5) .* (-1);
    ivarf = zeros(pfrefl,ppfref);
    ircalc = zeros(1,prayi);
    nbnda = zeros(1,piray);
    sample = zeros(pzgrid,pxgrid);

    %real*4
    c = zeros(player,ptrap,11);
    s = zeros(player,ptrap,2);
    b = zeros(player,ptrap,2);
    vm = zeros(player,ptrap,4);
    xbnd = zeros(player,ptrap,2);
    xshtar = zeros(1,pray);
    xm = zeros(pncntr,ppcntr);
    zm = zeros(pncntr,ppcntr);
    fidarr = zeros(1,pray);
    vf = zeros(player,ppvel,2);
    xr = zeros(1,ppray);
    zr = zeros(1,ppray);
    parorg = zeros(1,pnvar);
    ar_ = zeros(ppray,2);
    vr = zeros(ppray,2);
    tr = zeros(1,ppray);
    tfinv = zeros(1,pnrayf);
    vp = zeros(ppray,2);
    vs = zeros(ppray,2);
    rayid = zeros(1,pray);
    xfinv = zeros(1,pnrayf);
    ray = zeros(1,prayf);
    vsvp = zeros(player,ptrap);
    cv = zeros(player,ptrap,4,5);
    tt = zeros(1,pray);
    cz = zeros(player,ptrap,4,2);
    tang = zeros(player,4);
    cosmth = zeros(pncntr,pnsmth);
    range_ = zeros(1,pray);
    apart = zeros(prayi,pnvar);
    fpart = zeros(pnrayf,pnvar);
    tobs = zeros(1,prayi);
    uobs = zeros(1,prayi);
    tcalc = zeros(1,prayi);
    xvel = zeros(player,ppvel,2);
    xpf = zeros(1,prayi+pshot2+1);
    tpf = zeros(1,prayi+pshot2+1);
    upf = zeros(1,prayi+pshot2+1);
    xcalc = zeros(1,prayi);
    xscalc = zeros(1,prayi);
    xfrefl = zeros(pfrefl,ppfref);
    zfrefl = zeros(pfrefl,ppfref);
    mtan = zeros(1,pitan2);
    btan = zeros(1,pitan2);
    mcotan = zeros(1,pitan2);
    bcotan = zeros(1,pitan2);

    % character
    title_ = '';
end

if isempty(has_rayinvr_com_init)
    has_rayinvr_com_init = 1;
end

