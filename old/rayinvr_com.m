
%% initialize all parameters in rayinvr.com.

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

% %% initialize all parameters in rayinvr.com.

% %integer
% if ~exist('refll','var') || isempty(refll), refll = zeros(1,prefl+1); end
% if ~exist('nblk','var') || isempty(nblk), nblk = zeros(1,player); end
% if ~exist('ivarz','var') || isempty(ivarz), ivarz = zeros(player,ppcntr); end
% if ~exist('idray','var') || isempty(idray), idray = zeros(1,2); end
% if ~exist('partyp','var') || isempty(partyp), partyp = zeros(1,pnvar); end
% if ~exist('iheadf','var') || isempty(iheadf), iheadf = zeros(1,player); end
% if ~exist('nzed','var') || isempty(nzed), nzed = ones(1,pncntr); end
% if ~exist('icbnd','var') || isempty(icbnd), icbnd = zeros(1,pconv+1); end
% if ~exist('ivg','var') || isempty(ivg), ivg = zeros(player,ptrap); end
% if ~exist('izv','var') || isempty(izv), izv = zeros(player,ptrap,4); end
% if ~exist('ivv','var') || isempty(ivv), ivv = zeros(player,ptrap,4); end
% if ~exist('ivray','var') || isempty(ivray), ivray = zeros(1,prayf); end
% if ~exist('ipinv','var') || isempty(ipinv), ipinv = zeros(1,prayi); end
% if ~exist('nvel','var') || isempty(nvel), nvel = ones(player,2); end
% if ~exist('ivarv','var') || isempty(ivarv), ivarv = zeros(player,ppvel,2); end
% if ~exist('ldvmax','var') || isempty(ldvmax), ldvmax = zeros(1,player); end
% if ~exist('ldsmax','var') || isempty(ldsmax), ldsmax = zeros(1,pncntr); end
% if ~exist('ipf','var') || isempty(ipf), ipf = zeros(1,prayi+pshot2+1); end
% if ~exist('ilshot','var') || isempty(ilshot), ilshot = zeros(1,pshot2+1); end
% if ~exist('icalc','var') || isempty(icalc), icalc = zeros(1,prayi); end
% if ~exist('npfref','var') || isempty(npfref), npfref = zeros(1,pfrefl); end
% if ~exist('colour','var') || isempty(colour), colour = zeros(1,pcol); end
% if ~exist('mcol','var') || isempty(mcol), mcol = zeros(1,5); end
% if ~exist('ivarf','var') || isempty(ivarf), ivarf = zeros(pfrefl,ppfref); end
% if ~exist('ircalc','var') || isempty(ircalc), ircalc = zeros(1,prayi); end
% if ~exist('nbnda','var') || isempty(nbnda), nbnda = zeros(1,piray); end
% if ~exist('sample','var') || isempty(sample), sample = zeros(pzgrid,pxgrid); end

% %real*4
% if ~exist('c','var') || isempty(c), c = zeros(player,ptrap,11); end
% if ~exist('s','var') || isempty(s), s = zeros(player,ptrap,2); end
% if ~exist('b','var') || isempty(b), b = zeros(player,ptrap,2); end
% if ~exist('vm','var') || isempty(vm), vm = zeros(player,ptrap,4); end
% if ~exist('xbnd','var') || isempty(xbnd), xbnd = zeros(player,ptrap,2); end
% if ~exist('xshtar','var') || isempty(xshtar), xshtar = zeros(1,pray); end
% if ~exist('xm','var') || isempty(xm), xm = zeros(pncntr,ppcntr); end
% if ~exist('zm','var') || isempty(zm), zm = zeros(pncntr,ppcntr); end
% if ~exist('fidarr','var') || isempty(fidarr), fidarr = zeros(1,pray); end
% if ~exist('vf','var') || isempty(vf), vf = zeros(player,ppvel,2); end
% if ~exist('xr','var') || isempty(xr), xr = zeros(1,ppray); end
% if ~exist('zr','var') || isempty(zr), zr = zeros(1,ppray); end
% if ~exist('parorg','var') || isempty(parorg), parorg = zeros(1,pnvar); end
% if ~exist('ar','var') || isempty(ar), ar = zeros(ppray,2); end
% if ~exist('vr','var') || isempty(vr), vr = zeros(ppray,2); end
% if ~exist('tr','var') || isempty(tr), tr = zeros(1,ppray); end
% if ~exist('tfinv','var') || isempty(tfinv), tfinv = zeros(1,pnrayf); end
% if ~exist('vp','var') || isempty(vp), vp = zeros(ppray,2); end
% if ~exist('vs','var') || isempty(vs), vs = zeros(ppray,2); end
% if ~exist('rayid','var') || isempty(rayid), rayid = zeros(1,pray); end
% if ~exist('xfinv','var') || isempty(xfinv), xfinv = zeros(1,pnrayf); end
% if ~exist('ray','var') || isempty(ray), ray = zeros(1,prayf); end
% if ~exist('vsvp','var') || isempty(vsvp), vsvp = zeros(player,ptrap); end
% if ~exist('cv','var') || isempty(cv), cv = zeros(player,ptrap,4,5); end
% if ~exist('tt','var') || isempty(tt), tt = zeros(1,pray); end
% if ~exist('cz','var') || isempty(cz), cz = zeros(player,ptrap,4,2); end
% if ~exist('tang','var') || isempty(tang), tang = zeros(player,4); end
% if ~exist('cosmth','var') || isempty(cosmth), cosmth = zeros(pncntr,pnsmth); end
% if ~exist('range','var') || isempty(range), range = zeros(1,pray); end
% if ~exist('apart','var') || isempty(apart), apart = zeros(prayi,pnvar); end
% if ~exist('fpart','var') || isempty(fpart), fpart = zeros(pnrayf,pnvar); end
% if ~exist('tobs','var') || isempty(tobs), tobs = zeros(1,prayi); end
% if ~exist('uobs','var') || isempty(uobs), uobs = zeros(1,prayi); end
% if ~exist('tcalc','var') || isempty(tcalc), tcalc = zeros(1,prayi); end
% if ~exist('xvel','var') || isempty(xvel), xvel = zeros(player,ppvel,2); end
% if ~exist('xpf','var') || isempty(xpf), xpf = zeros(1,prayi+pshot2+1); end
% if ~exist('tpf','var') || isempty(tpf), tpf = zeros(1,prayi+pshot2+1); end
% if ~exist('upf','var') || isempty(upf), upf = zeros(1,prayi+pshot2+1); end
% if ~exist('xcalc','var') || isempty(xcalc), xcalc = zeros(1,prayi); end
% if ~exist('xscalc','var') || isempty(xscalc), xscalc = zeros(1,prayi); end
% if ~exist('xfrefl','var') || isempty(xfrefl), xfrefl = zeros(pfrefl,ppfref); end
% if ~exist('zfrefl','var') || isempty(zfrefl), zfrefl = zeros(pfrefl,ppfref); end
% if ~exist('mtan','var') || isempty(mtan), mtan = zeros(1,pitan2); end
% if ~exist('btan','var') || isempty(btan), btan = zeros(1,pitan2); end
% if ~exist('mcotan','var') || isempty(mcotan), mcotan = zeros(1,pitan2); end
% if ~exist('bcotan','var') || isempty(bcotan), bcotan = zeros(1,pitan2); end

% % character
% if ~exist('title','var') || isempty(title), title = ''; end
