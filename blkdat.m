% blkdat.f

% assign default and initial values to common block parameters

[irkc,tol,hdenom,hmin,idump] = deal(0,0.0005,64.0,0.01,0);
[itx,vred] = deal(1,8.0);
nzed = ones(1,pncntr);
% nvel = ones(1,pinvel);
nvel = ones(player,2);
[step_,smin,smax] = deal(0.05,-1.0,-1.0);
ntt = 1;
ray = zeros(1,prayf);
[xmin,xmax,xmm,ndecix,ntickx] = deal(0.0,-99999.0,250.0,-2,-1);
[xmint,xmaxt,xmmt,ndecxt,ntckxt] = deal(-9999.0,-9999.0,-9999.0,-2,-1);
[zmin,zmax,zmm,ndeciz,ntickz] = deal(0.0,50.0,75.0,-2,-1);
[tmin,tmax,tmm,ndecit,ntickt] = deal(0.0,10.0,75.0,-2,-1);
[xtmin,xtmax,xtmint,xtmaxt,ztmin,ztmax,ttmin,ttmax] = deal(-999999.0);
[symht,albht] = deal(0.5,2.5);
[ibsmth,nbsmth,npbnd] = deal(0,10,100);
% cv = zeros(1,picv);
cv = zeros(player,ptrap,4,5);
[crit,hws] = deal(1.0,-1.0);
[iplot,iplots,orig,sep,iseg,nseg] = deal(0,0,12.5,7.5,0,0);
[xwndow,ywndow] = deal(0.0);
colour = ones(1,pcol) .* (-1);
mcol = ones(1,5) .* (-1);
[sf,ibcol,ifcol] = deal(1.2,0,1);