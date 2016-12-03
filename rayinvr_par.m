%% initialize all parameters in rayinvr.par


%% use "global" variables to substitute the common blocks
%% these variables should have been in rayinvr_com.m,
%% but global variables must initialize first in matlab.

% common
global layer iblk id fid fid1;  %  blk1
global c ivg;  %  blk2
global s b vm;  %  blk3
global xbnd nblk nlayer;  %  blk4
global xm zm vf nzed nvel xvel;  %  blk5
global xr zr ar vr tr vp vs;  %  blk6
global refll ircbnd;  %  blk7
global irkc tol hdenom hmin idump isrkc ifast;  %  blk8
global itx vred time timer;  %  blk9
global step smin smax;  %  blk10
global range tt rayid xshtar fidarr idray ntt ray;  %  blk11
global xmin xmax xtmin xtmax xmm ndecix xscale ntickx xmint xmaxt xtmint ...
       xtmaxt xmmt ndecxt xscalt ntckxt zmin zmax ztmin ztmax zmm ndeciz ...
       zscale ntickz tmin tmax ttmin ttmax tmm ndecit tscale ntickt symht ...
       albht iplots orig sep title ititle xtitle ytitle ircol mcol irrcol ...
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



%% these parameters are all constant.

% pi = 3.141592654;
% pi4 = 0.785398163;
% pi2 = 1.570796327;
% pi34 = 2.35619449;
% pi18 = 57.29577951;
% pit2 = -6.283185307;
pi4 = pi / 4;
pi2 = pi / 2;
pi34 = pi * 3 / 4;
pi18 = 57.29577951;
pit2 = - pi * 2;

player = 42;      % model layers
ppcntr = 300;     % points defining a single model layer(must be a multiple of 10)
ptrap = 300;      % trapezoids within a layer
pshot = 200;      % shot points
prayf = 30;       % ray groups for a single shot
ptrayf = 3000;    % ray groups for all shots
ppray = 500;      % points defining a single ray
pnrayf = 1000;    % rays in a single group
pray = 100000;    % rays reaching the surface (not including the search mode)
prefl = 20;       % reflecting boundaries for a single group
preflt = 150;     % reflecting boundaries for all groups
pconv = 10;       % converting boundaries for a single group
pconvt = 100;     % converting boundaries for all groups
pnsmth = 500;     % points defining smooth layer boundary
papois = 50;      % blocks within which Poisson's ratio is altered
pnvar = 400;      % model parameters varied in inversion
prayi = 25000;    % travel times used in inversion
ppvel = 300;      % points at which upper & lower layer velocities defined(must be a multiple of 10)
pfrefl = 10;      % floating refectors
ppfref = 10;      % points defining a single floating reflector
pn2pt = 15;       % iterations in two-point ray tracing search
pnobsf = 1200;    % travel times with the same integer code for a single shot
pcol = 20;        % colours for ray groups & observed travel times
pxgrid = 1000;    % number of grid points in x-direction for output of uniformly sampled velocity model
pzgrid = 500;     % number of grid points in z-direction for output of uniformly sampled velocity model
pitan = 1000;     % number of intervals at which tangent function is pre-evaluated & used for interpolation
piray = 100;      % intersections with model boundaries for a single ray

pncntr = player + 1;
picv = player * ptrap * 20;
pinvel = player * 2;
pshot2 = pshot * 2;
prayt = pshot2 * prayf;
pitan2 = pitan * 2;
pr2pt = pnrayf + (pn2pt-1) * pnobsf;
