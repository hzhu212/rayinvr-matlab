%% initialize all parameters in rayinvr.com.
%% use "global" variables to substitute the common blocks

%integer
refll = zeros(1,prefl+1);
nblk = zeros(1,player);
ivarz = zeros(player,ppcntr);
idray = zeros(1,2);
partyp = zeros(1,pnvar);
iheadf = zeros(1,player);
nzed = zeros(1,pncntr);
icbnd = zeros(1,pconv+1);
ivg = zeros(player,ptrap);
izv = zeros(player,ptrap,4);
ivv = zeros(player,ptrap,4);
ivray = zeros(1,prayf);
ipinv = zeros(1,prayi);
nvel = zeros(player,2);
ivarv = zeros(player,ppvel,2);
ldvmax = zeros(1,player);
ldsmax = zeros(1,pncntr);
ipf = zeros(1,prayi+pshot2+1);
ilshot = zeros(1,pshot2+1);
icalc = zeros(1,prayi);
npfref = zeros(1,pfrefl);
colour = zeros(1,pcol);
mcol = zeros(1,5);
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
ar = zeros(ppray,2);
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
range = zeros(1,pray);
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
title = '';

% common
 global layer iblk id fid fid1  %  blk1 
 global c ivg  %  blk2 
 global s b vm  %  blk3 
 global xbnd nblk nlayer  %  blk4 
 global xm zm vf nzed nvel xvel  %  blk5 
 global xr zr ar vr tr vp vs  %  blk6 
 global refll ircbnd  %  blk7 
 global irkc tol hdenom hmin idump isrkc ifast  %  blk8 
 global itx vred time timer  %  blk9 
 global step smin smax  %  blk10
 global range tt rayid xshtar fidarr idray ntt ray  %  blk11
 global xmin xmax xtmin xtmax xmm ndecix xscale ntickx xmint xmaxt xtmint ...
        xtmaxt xmmt ndecxt xscalt ntckxt zmin zmax ztmin ztmax zmm ndeciz ...
        zscale ntickz tmin tmax ttmin ttmax tmm ndecit tscale ntickt symht ...
        albht iplots orig sep title ititle xtitle ytitle ircol mcol irrcol ...
        itcol ncol colour  %  blk12
 global icasel dstepf n2 n3 istop nstepr  %  blk13
 global iwave nccbnd iccbnd icbnd vsvp  %  blk14
 global isrch tang  %  blk15
 global ntray ntpts  %  blk16
 global ibsmth nbsmth npbnd cosmth xsinc  %  blk17
 global nptbnd  %  blk18
 global ivarz ivarv ivarf ivv izv cz cv partyp nvar parorg  %  blk19
 global apart fpart tobs uobs tcalc xcalc xscalc ipinv ivray narinv icalc ...
        ircalc  %  blk20
 global ninv xfinv tfinv  %  blk21
 global iheadf hws crit dhw tdhw ihdwf ihdw nhskip idiff idifff  %  blk22
 global dvmax dsmax idvmax idsmax ldvmax ldsmax  %  blk23
 global xpf tpf upf ipf ilshot  %  blk24
 global nfrefl npfref xfrefl zfrefl ifcbnd  %  blk25
 global sample  %  blk26
 global nbnd nbnda npskip npskp  %  blk27
 global mtan btan mcotan bcotan factan  %  blktan
 global iplot isep iseg nseg xwndow ywndow ibcol ifcol sf  %  cplot
