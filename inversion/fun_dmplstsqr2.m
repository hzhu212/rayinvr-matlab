function fun_dmplstsqr2
%% 1 parameter
%% 1.1 d.in parameter

% 变量采用cell（列的形式）来保存，依次为：1、属于哪个部分；2、类型（III：代表整数，例如开关switch和整型数组；FFF：代表浮点数）；3、英文说明；4、中文说明；
% 5、初始值/缺省值；6、导入值（如果导入时没有对应值，则保持NaN）；
% 7、输出值/当前值（初始为NaN或者为5的缺省值，视情况而定；当有导入的对应项时，设为导入值，可以后期更改，必要时可以重置reset为5的缺省值或者6的导入值）；
% 8、是否输出，为逻辑类型，常用项缺省为true，不常用项缺省为false，当有导入的对应项时，设为true，可以后期更改，必要时可以重置reset为导入对应项的情况；
% 9、特别的，对于开关类型，多出一个数组，用于保存开关的可供选择值

allnames={}; % 用于依次保存所有建立的dmplstsqr参数名

%iscrn
allnames=[allnames; 'iscrn'];
eng='iscrn?- a switch to plot the parameter adjustments and updated velocity model to the screen';
chi=' ';
iscrn={'&dmppar','III',eng,chi,1,NaN,1,false,[0 1]}'; % 加’转为列向量的形式

%dmpfct
allnames=[allnames; 'dmpfct'];
eng='dmpfct?- an overall damping factor to control the trade-off between resolution and variance';
chi='值越小，改变的程度越大';
dmpfct={'&dmppar','FFF',eng,chi,1.0,NaN,1.0,false,NaN}';

%velunc
allnames=[allnames; 'velunc'];
eng=['velunc?- an estimate of the uncertainty (square root of the variance) of the model velocity values (km/s)',char(13,10)'...
    '(default: 0.1; however, if velunc is equal to zero, the uncertainties listed in the file i.out are used)'];
chi=' ';
velunc={'&dmppar','FFF',eng,chi,0.1,NaN,0.1,false,NaN}';

%bndunc
allnames=[allnames; 'bndunc'];
eng=['bndunc?- an estimate of the uncertainty (square root of the variance) of the depth of model boundary values (km) ',char(13,10)'...
    '(default: 0.1; however, if bndunc is equal to zero, the uncertainties listed in the file i.out are used)'];
chi=' ';
bndunc={'&dmppar','FFF',eng,chi,0.1,NaN,0.1,false,NaN}';

%xmax
allnames=[allnames; 'xmax'];
eng='xmax?- maximum distance (km) of velocity model';
chi=' ';
xmax={'&dmppar','FFF',eng,chi,-99999.0,NaN,-99999.0,false,NaN}';

%zshift
allnames=[allnames; 'zshift'];
eng=' ';
chi=' ';
zshift={'&dmppar','FFF',eng,chi,0.6,NaN,0.6,false,NaN}';

%hnorm
allnames=[allnames; 'hnorm'];
eng=' ';
chi=' ';
hnorm={'&dmppar','FFF',eng,chi,0.0,NaN,0.0,false,NaN}';

%rnorm
allnames=[allnames; 'rnorm'];
eng=' ';
chi=' ';
rnorm={'&dmppar','FFF',eng,chi,0.0,NaN,0.0,false,NaN}';

%nker
allnames=[allnames; 'nker'];
eng=' ';
chi=' ';
nker={'&dmppar','III',eng,chi,0,NaN,0,false,NaN}';

%% 1.2 rayinvr.par
% Fortran定义变量时的隐式声明规则：在程序中，凡是变量名以字母I,J,K,L,M,N,i,j,k,l,m,n开头的变量被默认为整型变量，以其他字母开头的变量被默认为实型变量。
% 除非某变量名被明确声明为整型或者实型，或者用implicit none 取消定义变量时的隐式声明规则。

global player ppcntr ptrap pshot prayf ptrayf ppray pnrayf pray prefl preflt pconv pconvt pnsmth papois pnvar ...
       prayi ppvel pncntr picv pinvel prayt pshot2 pfrefl ppfref pn2pt pnobsf pr2pt pcol pxgrid pzgrid pitan pitan2 piray ...
       pi pi4 pi2 pi34 pi18 pit2;   %rayinvr.par

pi=3.141592654;
pi4=.785398163;
pi2=1.570796327;
pi34=2.35619449;
pi18=57.29577951;
pit2=-6.283185307;

player=42;      %model layers
ppcntr=300;     %points defining a single model layer(must be a multiple of 10)
ptrap=300;      %trapezoids within a layer
pshot=200;      %shot points
prayf=30;       %ray groups for a single shot
ptrayf=3000;    %ray groups for all shots
ppray=500;      %points defining a single ray
pnrayf=1000;    %rays in a single group
pray=100000;    %rays reaching the surface (not including the search mode)
prefl=20;       %reflecting boundaries for a single group
preflt=150;     %reflecting boundaries for all groups
pconv=10;       %converting boundaries for a single group
pconvt=100;     %converting boundaries for all groups
pnsmth=500;     %points defining smooth layer boundary
papois=50;      %blocks within which Poisson's ratio is altered
pnvar=400;      %model parameters varied in inversion
prayi=25000;    %travel times used in inversion
ppvel=300;      %points at which upper and lower layer velocities defined(must be a multiple of 10)
pfrefl=10;      %floating refectors
ppfref=10;      %points defining a single floating reflector
pn2pt=15;       %iterations in two-point ray tracing search
pnobsf=1200;    %travel times with the same integer code for a single shot
pcol=20;        %colours for ray groups and observed travel times
pxgrid=1000;    %number of grid points in x-direction for output of uniformly sampled velocity model
pzgrid=500;     %number of grid points in z-direction for output of uniformly sampled velocity model
pitan=1000;     %number of intervals at which tangent function is pre-evaluated and used for interpolation
piray=100;      %intersections with model boundaries for a single ray

pncntr=player+1;
picv=player*ptrap*20;
pinvel=player*2;
pshot2=pshot*2;
prayt=pshot2*prayf;
pitan2=pitan*2;
pr2pt=pnrayf+(pn2pt-1)*pnobsf;

%% 1.3 main function parameter
global nlayer ncont nzed nvel vmodel xm zm ivarz xvel vf ivarv;   %fun_load_vin
global narinv nvar parorg parunc partyp apart tres tunc;    %fun_load_iout
global var atadi ata atad att pvar;  %2.2 matrix processing
global nfrefl xfrefl zfrefl ivarf npfref fmodel;    %fun_load_fin
global mpinch zmb grad igrad;  %check part

%real
%apart=zeros(prayi,pnvar);
%tres=zeros(prayi,1);
%ata=zeros(pnvar,pnvar);
%att=zeros(pnvar,1);
%atad=zeros(pnvar,pnvar);
%atadi=zeros(pnvar,pnvar);      %在242行初始化，读入数据后再初始化，可以节省空间
dx=zeros(pnvar,1);      % 防止nvarw访问越界
%pvar=zeros(3,1);
res=zeros(pnvar,pnvar);     % 防止nvarw访问越界
%var=zeros(pnvar,1);       %在264行初始化，读入数据后再初始化，可以节省空间
%parorg=zeros(pnvar,1);
%vf=zeros(player,ppvel,2);
%xvel=zeros(player,ppvel,2);
%xm=zeros(pncntr,ppcntr);
%zm=zeros(pncntr,ppcntr);
%grad=zeros(player*ppvel,1);
%tunc=zeros(prayi,1);
%thick=zeros(player*ppcntr,1);
%parunc=zeros(pnvar,1);
%xfrefl=zeros(pfrefl,ppfref);
%zfrefl=zeros(pfrefl,ppfref);
%zmb=zeros(ppcntr,1);

%integer
%partyp=zeros(pnvar,1);
%nzed=zeros(pncntr,1);
%nvel=zeros(player,2);
%ivarz=zeros(player,ppcntr);ivarv=zeros(player,ppvel,2);
%mpinch=zeros(pncntr,ppcntr,2);
%igrad=zeros(player*ppvel,1);
%ivarf=zeros(pfrefl,ppfref);npfref=zeros(pfrefl,1);
%hit=zeros(pnvar,1);

%default parameter values
ifrbnd=0;

%% 2 main function
%% 2.1 load d.in & i.out
fun_load_din('./alternative/d.in');
%eval(['fun_load_din(''./file in/example',num2str(example),'/d.in'');']);
%fun_load_din2('./file in/example1/d.in');    % if there is need to read more than one section
if xmax{7}<-99998
        error='***  xmax not specified  ***';
        disp(error);
end

%read in matrix of partial derivatives and vector of traveltime residuals
fun_load_iout('./alternative/i.out');
%eval(['fun_load_iout(''./file in/example',num2str(example),'/i',num2str(iteration),'.out'');']);
%% 2.2 matrix processing & inversing

for j=1:nvar    %dmplstsqr.f不包含
    hit(j)=0;   %dmplstsqr.f不包含
    for i=1:narinv  %dmplstsqr.f不包含
        if apart(i,j)~=0    %dmplstsqr.f不包含
            hit(j)=hit(j)+1;    %dmplstsqr.f不包含
        end     %dmplstsqr.f不包含
    end     %dmplstsqr.f不包含
end     %dmplstsqr.f不包含

for i=1:nvar
    for j=1:i
        ata(i,j)=0;
        for k=1:narinv
            ata(i,j)=ata(i,j)+apart(k,i)*apart(k,j)/tunc(k)^2;
        end
        if i~=j
            ata(j,i)=ata(i,j);
        end
    end
end

for i=1:nvar
    att(i)=0;
    for j=1:narinv
        att(i)=att(i)+apart(j,i)*tres(j)/tunc(j)^2;
    end
end

pvar(1)=bndunc{7}^2;
pvar(2)=velunc{7}^2;
pvar(3)=bndunc{7}^2;

for i=1:nvar
    for j=1:nvar
        atad(i,j)=ata(i,j);
        if i==j
            if partyp(i)==1
                if bndunc{7} <= 0
                    parunc(i)=parunc(i)^2;
                else
                    parunc(i)=pvar(1);
                end
            end
            if partyp(i)==2
                if velunc{7} <= 0
                    parunc(i)=parunc(i)^2;
                else
                    parunc(i)=pvar(2);
                end
            end
            if partyp(i)==3
                if bndunc{7} <= 0
                    parunc(i)=parunc(i)^2;
                else
                    parunc(i)=pvar(1);
                end
                ifrbnd=1;
            end
            atad(i,j)=atad(i,j)+dmpfct{7}/parunc(i)
        end
    end
end

atadi=zeros(nvar);  %atadi需要初始化
[atad,atadi,nvar]=fun_matinv(atad,atadi,nvar);
%fun_matinv(atad,atadi,nvar);

%% 2.3 save the first part of d.out

for i=1:nvar
    dx(i)=0.0;
    for j=1:nvar
        dx(i)=dx(i)+atadi(i,j)*att(j);
    end
end

for i=1:nvar
    for j=1:nvar
        res(i,j)=0;
        for k=1:nvar
            res(i,j)=res(i,j)+atadi(i,k)*ata(k,j);
        end
    end
end

var=zeros(nvar,1);  %var需要初始化
for i=1:nvar
    var(i)=var(i)+(1.0-res(i,i))*parunc(i);
end

fun_save_dout(1,'./alternative/d.out');
%eval(['fun_save_dout(1,''./file out/example',num2str(example),'/d',num2str(iteration),'.out'');']);

%% 2.4 load v.in & save v.bak
ncont=0;    %layer boudary number
[ncont,xm,zm,ivarz,xvel,vf,ivarv,vmodel]=fun_load_vin(ncont,xm,zm,ivarz,xvel,vf,ivarv,vmodel,'./alternative/v.in');
%string='ncont,xm,zm,ivarz,xvel,vf,ivarv,vmodel';
%eval(['[',string,']=fun_load_vin(',string,',''./file in/example',num2str(example),'/v',num2str(iteration),'.in'');']);
%fun_load_vin('./file in/example1/v.in');
nlayer=ncont-1; %layer number
% nrzmax=ppcntr/10;
% nrvmax=ppvel/10;

nzed=ones(ncont,1);
nvel=ones(nlayer,2);
[ll,cc]=size(xm);
for i=1:ncont
    for j=1:cc
        if abs(xm(i,j)-xmax)<0.0001 %用于计数的nzed、nvel从1而非0开始累计，故不包括该行x最大值
            break;  % go to 180
        else
            nzed(i)=nzed(i)+1;  % 每层x值个数
        end
    end
%180
end

[ll,cc,ww]=size(xvel);
for i=1:nlayer
    for j=1:cc
        if abs(xvel(i,j,1)-xmax)<0.0001
            break;  % go to 212
        else
            nvel(i,1)=nvel(i,1)+1;  %每层x值个数
        end
    end
    %212
    if nvel(i,1)==1 && vf(i,1,1)==0.0   %不包括速度零点
        nvel(i,1)=0;
    end
end

for i=1:nlayer
    for j=1:cc
        if abs(xvel(i,j,2)-xmax)<0.0001
            break;  % go to 260
        else
            nvel(i,2)=nvel(i,2)+1;  %每层x值个数
        end
    end
    %260
    if nvel(i,2)==1 && vf(i,1,2)==0.0   %不包括速度零点
        nvel(i,2)=0;
    end
end

nlyr=0;
for i=2:ncont-1 %将源代码的ncont改为ncont-1，因为最后一层不含ivarz数据
    for j=1:nzed(i) %用每行节点个数nzed(i)控制访问的列数
        if ivarz(i,j)==-1
            nlyr=nlyr+1;
            thick(nlyr)=zm(i,j)-zm(i-1,j);
        end
    end
end

fun_save_vbak(vmodel,'./alternative/v.bak');
%eval(['fun_save_vbak(vmodel,''./file out/example',num2str(example),'/v.bak'');']);

%% 2.5 load f.in & save f.bak
%ifrbnd=1;
if ifrbnd==1
    [nfrefl,xfrefl,zfrefl,ivarf,npfref,fmodel]=fun_load_fin(nfrefl,xfrefl,zfrefl,ivarf,npfref,fmodel,'./alternative/f.in');
    %string='nfrefl,xfrefl,zfrefl,ivarf,npfref,fmodel';
    %eval(['[',string,']=fun_load_fin(',string,',''./file in/example',num2str(example),'/f.in'');']);
    fun_save_fbak(fmodel,'./alternative/f.bak');
    %eval(['fun_save_fbak(fmodel,''./file out/example',num2str(example),'/f.bak'');']);
end
%% 2.6 check for fixed velocity gradients

ngrad=0;
for i=1:nlayer
    iflagg=0;
    if nvel(i,2)>0
        for j=1:nvel(i,2)
            if ivarv(i,j,2)==-1
                ngrad=ngrad+1;
                xbndc=xvel(i,j,2);
                if nzed(i)>1
                    for k=1:nzed(i)-1
                        if xbndc >= xm(i,k) && xbndc <= xm(i,k+1)
                            zu=(zm(i,k+1)-zm(i,k))*(xbndc-xm(i,k))/(xm(i,k+1)-xm(i,k))+zm(i,k);
                            break;  % go to 400
                        end
                    end
                else
                    zu=zm(i,1);
                end
                %400
                if nvel(i,1)>0
                    vu=vf(i,j,1);
                else
                    for k=i-1:-1:1
                        if nvel(k,2)>0
                            vu=vf(k,j,2);
                            break;  % go to 402
                        end
                        if nvel(k,1)>0
                            vu=vf(k,j,1);
                            break;  % go to 402
                        end
                    end
                end
                %402
                if nzed(i+1)>1
                    for k=1:nzed(i+1)-1
                        if xbndc >= xm(i+1,k) && xbndc <= xm(i+1,k+1)
                            zl=(zm(i+1,k+1)-zm(i+1,k))*(xbndc-xm(i+1,k))/(xm(i+1,k+1)-xm(i+1,k))+zm(i+1,k);
                            break;  % go to 420
                        end
                    end
                else
                    zl=zm(i+1,1);
                end
                %420
                vl=vf(i,j,2);
                if abs(vu-vl)>0.001
                    if abs(zl-zu)>0.001
                        grad(ngrad)=(vl-vu)/(zl-zu);
                        igrad(ngrad)=1;
                    else
                        grad(ngrad)=vl-vu;
                        igrad(ngrad)=0;
                        iflagg=1;
                    end
                else
                    grad(ngrad)=0.0;
                    igrad(ngrad)=1;
                end
            end
        end
    end
%    iflagg=1;
    if iflagg==1
        fprintf('%s','***  check gradient in layer ');
        fprintf('%2i',i);
        fprintf('%s','  ***');
        fid=fopen('./alternative/d.out','a');
        %eval(['fid=fopen(''./file out/example',num2str(example),'/d',num2str(iteration),'.out'',''a'');']);
        fprintf(fid,'%s','***  check gradient in layer ');
        fprintf(fid,'%2i',i);
        fprintf(fid,'%s','  ***');
        fclose(fid);
    end
end
fid=fopen('./alternative/d.out','a');
%eval(['fid=fopen(''./file out/example',num2str(example),'/d',num2str(iteration),'.out'',''a'');']);
fprintf(fid,'%s','velocity model:');
fprintf(fid,'\n');
fprintf(fid,'\n');
if iscrn{7}==1
    fprintf('%s','velocity model:');
    fprintf('\n');
    fprintf('\n');
end

%% 2.7 check for pinchouts
flag=0;
if nlayer>1
    ipinch=0;
    for i=2:nlayer
        for j=1:nzed(i);
            mpinch(i,j,1)=0;
            for k=1:i-1
                for l=1:nzed(k)
                    if abs(xm(i,j)-xm(k,l))<0.005 && abs(zm(i,j)-zm(k,l))<0.005
                        ipinch=ipinch+1;
                        mpinch(i,j,1)=k;
                        mpinch(i,j,2)=l;
                        flag=1;
                        break;  % go to 282
                    end
                end
                if flag==1;
                    break;
                end
            end
        %282
        end
    end
end

%% 2.8 add the parameter adjustments
% hnorm{7}=1;
% rnorm{7}=1;
% nker{7}=1;

%if hnorm{7}>0.0
    fileh1='./alternative/z1.hit';   %63
    fileh2='./alternative/v.hit';   %64
    fileh3='./alternative/f.hit';   %65
    fileh4='./alternative/z2.hit';   %66
%end
%if rnorm{7}>0.0
    filer1='./alternative/z1.res';   %73
    filer2='./alternative/v.res';   %74
    filer3='./alternative/f.res';   %75
    filer4='./alternative/z2.res';   %76
%end
%if nker{7}>0
    filen1='./alternative/z1.ker';   %83
    filen2='./alternative/v.ker';   %84
    filen3='./alternative/f.ker';   %85
    filen4='./alternative/z2.ker';   %86
%end

nvarw=0;
nlyr=0;
for i=1:nlayer
    for k=1:nzed(i)    %dmplstsqr.f不包含
        zmb(k)=zm(i,k); %dmplstsqr.f不包含
    end     %dmplstsqr.f不包含
    for j=1:nzed(i)
        if ipinch==1 && i>1
            if mpinch(i,j,1)>0
                zm(i,j)=zm(mpinch(i,j,1),mpinch(i,j,2));
                continue;   % go to 280
            end
        end
        if ivarz(i,j)>0
            nvarw=nvarw+1;
            %??????以下dmplstsqr.f不包含
            if hnorm{7}>0.0
                fid=fopen(fileh1,'w');
                fprintf(fid,'%10.3f',[xm(i,j),-zm(i,j),hit(nvarw)/hnorm{7}]);
                fid=fopen(fileh4,'w');
                fprintf(fid,'%10.3f',[xm(i,j),-zm(i,j),1.3*hit(nvarw)/hnorm{7}]);
            end
            if rnorm{7}>0.0
                fid=fopen(filer1,'w');
                fprintf(fid,'%10.3f',[xm(i,j),-zm(i,j),res(nvarw,nvarw)/rnorm{7}]);
                fid=fopen(filer4,'w');
                fprintf(fid,'%10.3f',[xm(i,j),-zm(i,j),1.3*res(nvarw,nvarw)/rnorm{7}]);
            end
            if nker{7}>0.0
                fid=fopen(filen1,'w');
                fprintf(fid,'%10.3f',[xm(i,j),-zm(i,j),abs(res(nvarw,nker{7}))/rnorm{7}]);  %dmplstsqr_new2.f无abs
                fid=fopen(filen4,'w');
                fprintf(fid,'%10.3f',[xm(i,j),-zm(i,j),abs(1.3*res(nvarw,nker{7}))/rnorm{7}]);  %dmplstsqr_new2.f无abs
            end
            %??????以上dmplstsqr.f不包含
            zm(i,j)=zm(i,j)+dx(nvarw);
        end
        if ivarz(i,j)==-1
            nlyr=nlyr+1;
            zm(i,j)=zm(i-1,j)+thick(nlyr);
        end
    %280
    end

    if nvel(i,1)>0
        for j=1:nvel(i,1)
            if ivarv(i,j,1)>0
                nvarw=nvarw+1;
                %??????以下dmplstsqr.f不包含
                if nzed(i)==1
                    zhit=zmb(1);
                else
                    for k=1:nzed(i)-1
                        if xvel(i,j,1) >= xm(i,k) && xvel(i,j,1) <= xm(i,k+1)
                            zhit=(zmb(k+1)-zmb(k))/(xm(i,k+1)-xm(i,k))*(xvel(i,j,1)-xm(i,k))+zmb(k);
                            break;  % go to 3113
                        end
                    end
                end
                %3113
                if hnorm{7}>0.0
                    fid=fopen(fileh2,'w');
                    fprintf(fid,'%10.3f',[xvel(i,j,1),-zhit-zshift{7}]);
                    fprintf(fid,'%10i',hit(nvarw));
                end
                if rnorm{7}>0.0
                    fid=fopen(filer2,'w');
                    fprintf(fid,'%10.3f',[xvel(i,j,1),-zhit-zshift{7},res(nvarw,nvarw)]);
                end
                if nker{7}>0.0
                    fid=fopen(filen2,'w');
                    fprintf(fid,'%10.3f',[xvel(i,j,1),-zhit-zshift{7},abs(res(nvarw,nker{7}))]);    %dmplstsqr_new2.f无abs
                end
                %??????以上dmplstsqr.f不包含
                vf(i,j,1)=vf(i,j,1)+dx(nvarw);
            end
        end
    else
        nvel(i,1)=1;
        xvel(i,1,1)=xmax;
        vf(i,1,1)=0.;
    end

    if nvel(i,2)>0
        for j=1:nvel(i,2)
            if ivarv(i,j,2)>0
                nvarw=nvarw+1;
                %??????以下dmplstsqr.f不包含
                if nzed(i+1)==1
                    zhit=zm(i+1,1);
                else
                    for k=1:nzed(i+1)-1
                        if xvel(i,j,2) >= xm(i+1,k) && xvel(i,j,2) <= xm(i+1,k+1)
                            zhit=(zm(i+1,k+1)-zm(i+1,k))/(xm(i+1,k+1)-xm(i+1,k))*(xvel(i,j,2)-xm(i+1,k))+zm(i+1,k);
                            break;  % go to 3114
                        end
                    end
                end
                %3114
                if hnorm{7}>0.0
                    fid=fopen(fileh2,'a');
                    fprintf(fid,'%10.3f',[xvel(i,j,2),-zhit+zshift{7}]);
                    fprintf(fid,'%10i',hit(nvarw));
                end
                if rnorm{7}>0.0
                    fid=fopen(filer2,'a');
                    fprintf(fid,'%10.3f',[xvel(i,j,2),-zhit+zshift{7},res(nvarw,nvarw)]);
                end
                if nker{7}>0.0
                    fid=fopen(filen2,'a');
                    fprintf(fid,'%10.3f',[xvel(i,j,2),-zhit+zshift{7},abs(res(nvarw,nker{7}))]);    %dmplstsqr_new2.f无abs
                end
                %??????以上dmplstsqr.f不包含
                vf(i,j,2)=vf(i,j,2)+dx(nvarw);
            end
        end
    else
        nvel(i,2)=1;
        xvel(i,1,2)=xmax;
        vf(i,1,2)=0.;
    end
end

%ifrbnd=1;
if ifrbnd==1
    for j=1:nfrefl
        for i=1:npfref(j)
            if ivarf(j,i)==1
                nvarw=nvarw+1;
                %??????以下dmplstsqr.f不包含
                if hnorm{7}>0.0
                    fid=fopen(fileh3,'w');
                    fprintf(fid,'%10.3f',[xfrefl(j,i),-zfrefl(j,i),hit(nvarw)/hnorm{7}]);
                end
                if rnorm{7}>0.0
                    fid=fopen(filer3,'w');
                    fprintf(fid,'%10.3f',[xfrefl(j,i),-zfrefl(j,i),res(nvarw,nvarw)/rnorm{7}]);
                end
                if nker{7}>0.0
                    fid=fopen(filen3,'w');
                    fprintf(fid,'%10.3f',[xfrefl(j,i),-zfrefl(j,i),abs(res(nvarw,nker{7})/rnorm{7})]);  %dmplstsqr_new2.f无abs
                end
                %??????以上dmplstsqr.f不包含
                zfrefl(j,i)=zfrefl(j,i)+dx(nvarw);
            end
        end
    end
end

%% 2.9 maintain fixed velocity gradients

ngrad=0;
flag=0;
for i=1:nlayer
    for j=1:nvel(i,2)
        if ivarv(i,j,2)==-1
            ngrad=ngrad+1;
            xbndc=xvel(i,j,2);
            if nzed(i)>1
                for k=1:nzed(i)-1
                    if xbndc >= xm(i,k) && xbndc <= xm(i,k+1)
                        zu=(zm(i,k+1)-zm(i,k))*(xbndc-xm(i,k))/(xm(i,k+1)-xm(i,k))+zm(i,k);
                        break;  % go to 450
                    end
                end
            else
                zu=zm(i,1);
            end
            %450
            if nvel(i,1)>0 && vf(i,1,1)>0
                vu=vf(i,j,1);
            else
                for k=i-1:-1:1
                    if nvel(k,2)>0 && vf(k,1,2)>0
                        vu=vf(k,j,2);
                        flag=1;
                        break;  % go to 452
                    end
                    if nvel(k,1)>0 && vf(k,1,1)>0
                        vu=vf(k,j,1);
                        flag=1;
                        break;  % go to 452
                    end
                end
            end
            if igrad(ngrad)==1 || flag==1
                %452
                if nzed(i+1)>1
                    for k=1:nzed(i+1)-1
                        if xbndc >= xm(i+1,k) && xbndc <= xm(i+1,k+1)
                            zl=(zm(i+1,k+1)-zm(i+1,k))*(xbndc-xm(i+1,k))/(xm(i+1,k+1)-xm(i+1,k))+zm(i+1,k);
                            vf(i,j,2)=vu+grad(ngrad)*(zl-zu);
                            break;  % go to 272
                        end
                    end
                else
                    zl=zm(i+1,1);
                    vf(i,j,2)=vu+grad(ngrad)*(zl-zu);
                end
            else
                vf(i,j,2)=vu+grad(ngrad);
            end
        end
    %272
    end
end

%% 2.10 save v.in & the second part of d.out
fun_save_vin('./alternative/v.in');
%eval(['fun_save_vin(''./file out/example',num2str(example),'/v',num2str(iteration),'.in'');']);
fun_save_dout(2,'./alternative/d.out');
%eval(['fun_save_dout(2,''./file out/example',num2str(example),'/d',num2str(iteration),'.out'');']);
%% 2.11 write out floating reflectors
if ifrbnd==1
    fid1=fopen('./alternative/d.out','a');
    %eval(['fid1=fopen(''./file out/example',num2str(example),'/d',num2str(iteration),'.out'',''a'');']);
    fprintf(fid1,'\n');
    fprintf(fid1,'\n');
    fprintf(fid1,'%s','floating reflectors:');
    fprintf(fid1,'\n');
    fprintf(fid1,'\n');
    if iscrn{7}==1
        fprintf('\n');
        fprintf('\n');
        fprintf('%s','floating reflectors:');
        fprintf('\n');
        fprintf('\n');
    end
    fid2=fopen('./alternative/f.in','w');
    %eval(['fid2=fopen(''./file out/example',num2str(example),'/f',num2str(iteration),'.in'',''w'');']);
    for j=1:nfrefl
        fprintf(fid2,'%2i',npfref(j));
        fprintf(fid2,'\n');
        fprintf(fid1,'%2i',npfref(j));
        fprintf(fid1,'\n');
        fprintf(fid2,'%2i ',j);
        fprintf(fid2,'%7.2f',xfrefl(j,1:npfref(j)));
        fprintf(fid2,'\n');
        fprintf(fid1,'%2i ',j);
        fprintf(fid1,'%7.2f',xfrefl(j,1:npfref(j)));
        fprintf(fid1,'\n');
        fprintf(fid2,'%s',blanks(3));
        fprintf(fid2,'%7.2f',zfrefl(j,1:npfref(j)));
        fprintf(fid2,'\n');
        fprintf(fid1,'%s',blanks(3));
        fprintf(fid1,'%7.2f',zfrefl(j,1:npfref(j)));
        fprintf(fid1,'\n');
        fprintf(fid2,'%s',blanks(3));
        fprintf(fid2,'%7i',ivarf(j,1:npfref(j)));
        fprintf(fid2,'\n');
        fprintf(fid1,'%s',blanks(3));
        fprintf(fid1,'%7i',ivarf(j,1:npfref(j)));
        fprintf(fid1,'\n');
        if iscrn{7}==1
            fprintf('%2i',npfref(j));
            fprintf('\n');
            fprintf('%2i ',j);
            fprintf('%7.2f',xfrefl(j,1:npfref(j)));
            fprintf('\n');
            fprintf('%s',blanks(3));
            fprintf('%7.2f',zfrefl(j,1:npfref(j)));
            fprintf('\n');
            fprintf('%s',blanks(3));
            fprintf('%7i',ivarf(j,1:npfref(j)));
            fprintf('\n');
        end
    end
end

%% 3 tool function
function fun_save_vin(fileout)

%     switch precision
%   case 'high'
%         format_f='%8.3f';
%         format_d='%8i';
%   case 'low'
        format_f='%7.2f';
        format_d='%7i';
%     end
    fid=fopen(fileout,'w');
    for i=1:nlayer
        nstart=1;
        flag=0;
        while flag==0
            j1=nstart;  %590
            j2=j1+9;
            if j2>nzed(i)   %nzed(i)为该层boundary depth数据个数
                j2=nzed(i);
            end
            if j2<nzed(i)
                icnt=1; %是否未完待续
            else
                icnt=0;
            end
            fprintf(fid,'%2i ',i);
            fprintf(fid,format_f,xm(i,j1:j2));
            fprintf(fid,'\n');
            fprintf(fid,'%2i ',icnt);
            fprintf(fid,format_f,zm(i,j1:j2));
            fprintf(fid,'\n');
            fprintf(fid,'%s',blanks(3));
            fprintf(fid,format_d,ivarz(i,j1:j2));
            fprintf(fid,'\n');
            if j2==nzed(i)
                flag=1;     % go to 600
            end
            nstart=j2+1;
        end     % go to 590
        %600
        nstart=1;
        flag=0;
        while flag==0
            j1=nstart;  %620
            j2=j1+9;
            if j2>nvel(i,1)     %nvel(i,1)为该层top velocity数据个数
                j2=nvel(i,1);
            end
            if j2<nvel(i,1)
                icnt=1;
            else
                icnt=0;
            end
            fprintf(fid,'%2i ',i);
            fprintf(fid,format_f,xvel(i,j1:j2,1));
            fprintf(fid,'\n');
            fprintf(fid,'%2i ',icnt);
            fprintf(fid,format_f,vf(i,j1:j2,1));
            fprintf(fid,'\n');
            fprintf(fid,'%s',blanks(3));
            fprintf(fid,format_d,ivarv(i,j1:j2,1));
            fprintf(fid,'\n');
            if j2==nvel(i,1)
                flag=1;     % go to 630
            end
            nstart=j2+1;
        end     % go to 620
        %630
        nstart=1;
        flag=0;
        while flag==0
            j1=nstart;  %650
            j2=j1+9;
            if j2>nvel(i,2)     %nvel(i,2)为该层bottom velocity数据个数
                j2=nvel(i,2);
            end
            if j2<nvel(i,2)
                icnt=1;
            else
                icnt=0;
            end
            fprintf(fid,'%2i ',i);
            fprintf(fid,format_f,xvel(i,j1:j2,2));
            fprintf(fid,'\n');
            fprintf(fid,'%2i ',icnt);
            fprintf(fid,format_f,vf(i,j1:j2,2));
            fprintf(fid,'\n');
            fprintf(fid,'%s',blanks(3));
            fprintf(fid,format_d,ivarv(i,j1:j2,2));
            fprintf(fid,'\n');
            if j2==nvel(i,2)
                flag=1;     % go to 570
            end
            nstart=j2+1;
        end     % go to 650
    end     %570

    fprintf(fid,'%2i ',ncont);
    fprintf(fid,format_f,xm(ncont,1:nzed(ncont)));
    fprintf(fid,'\n');
    fprintf(fid,'%2i ',0);
    fprintf(fid,format_f,zm(ncont,1:nzed(ncont)));

end

function fun_save_fbak(fmodel,fileout)
%write out original floating reflectors

LN=length(fmodel);
fid=fopen(fileout,'w');
for i=1:LN
    fprintf(fid,'%2i',fmodel{i}(1,1));
    fprintf(fid,'\n');
    fprintf(fid,'%2i ',i);
    fprintf(fid,'%7.2f',fmodel{i}(2,:));
    fprintf(fid,'\n');
    fprintf(fid,'%s',blanks(3));
    fprintf(fid,'%7.2f',fmodel{i}(3,:));
    fprintf(fid,'\n');
    fprintf(fid,'%s',blanks(3));
    fprintf(fid,'%7i',fmodel{i}(4,:));
    fprintf(fid,'\n');
end
fclose(fid);
end

function [nfrefl,xfrefl,zfrefl,ivarf,npfref,fmodel]=fun_load_fin(nfrefl,xfrefl,zfrefl,ivarf,npfref,fmodel,filein)
%read in floating reflectors

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
        disp('***  error in f.in file  ***');
        return;
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

function fun_save_vbak(vmodel,fileout)
% write out original velocity model

% switch precision
%     case 'high'
%         format_f='%8.3f';
%         format_d='%8i';
%     case 'low'
        format_f='%7.2f';
        format_d='%7i';
% end
fn=fieldnames(vmodel);   %{'bd';'tv';'bv'}
LN=length(vmodel);
fid=fopen(fileout,'w');
for i=1:LN
    for j=1:length(fn)  %fieldnames的个数=3
        if (i==LN) && (j>1) %最后一层无第2、3fieldname
        else
            value=getfield(vmodel,{i},fn{j});    %第i层的第j个fieldname
            nodes=length(value(1,:));
            startnode=1:10:1000;    %由于每行最多10个数，故每行开始的节点编号为1、11、21……
            startnode=startnode(find(startnode<=nodes));
            linecount=length(startnode);    %需要输出多少行
            if linecount==1;
                endnode=nodes;
            else
                endnode=[startnode(2:end)-1 nodes]; %结束节点编号为下一行开头编号-1及最后一个节点
            end
            flag=1; %是否未完待续
            for k=1:linecount;
                if k==linecount;
                    flag=0;
                end
                fprintf(fid,'%2i ',i);
                fprintf(fid,format_f,value(1,startnode(k):endnode(k)));
                fprintf(fid,'\n');
                %                 if flag==0;
                %                     fprintf(fid,'%s',blanks(3));
                %                 else
                %                     fprintf(fid,'%2i ',flag);
                %                 end
                fprintf(fid,'%2i ',flag);  % use 0 instead of 3X
                fprintf(fid,format_f,value(2,startnode(k):endnode(k)));
                fprintf(fid,'\n');
                if i<LN;    %第LN层无第三行
                    fprintf(fid,'%s',blanks(3));
                    fprintf(fid,format_d,value(3,startnode(k):endnode(k)));
                    fprintf(fid,'\n');
                end
            end
        end
    end
end
fclose(fid);

end

function [ncont,xm,zm,ivarz,xvel,vf,ivarv,vmodel]=fun_load_vin(ncont,xm,zm,ivarz,xvel,vf,ivarv,vmodel,filein)
% function fun_load_vin(filein)
% global ncont xm zm ivarz xvel vf ivarv;

fid = fopen(filein,'r');
count=0;
imdata={};
line = fgetl(fid);
value=sscanf(line,'%f'); % read values of first boundary
xmin=value(2); % model left boundary

% index=strfind(line,'.'); % get the position of '.'
% value=index(2:end)-index(1:end-1); % get the interval of '.'
% switch mean(value) % recognize the precision by digits of interval
%     case 7
%         precision='low';
%     case 8
%         precision='high';
%     otherwise
%         precision=['unknown, the 1st line is: "',line,'"']; % cannot determine the format, something wrong
% end

while ischar(line)
    count=count+1;
    imdata{count,1}=line; % save every line in the file to the cell'imdata'
    line = fgetl(fid);
end
fclose(fid);
% imdata=importdata(filein,'D');  % use an INVALID delimiter to force the data is imported in as a string cell; each line is a cell element


% get layer number and value precision
line=imdata{length(imdata)-1}; % string of last boundary line
value=sscanf(line,'%f'); % read values of last boundary
LN=value(1); % layer number of the model
xmax=value(end); % model right boundary


% use structure to store model, bd=layer top boundary, tv=top velocity, bv=bottom velocity
% each cell is a 3xNodes matrix for (1) x, (2) z or v, and (3) partial derivative for each node
fieldname={'bd','tv','bv'};
fullfn={'top boundary depth','top velocity','bottom velocity'};
vmodel=struct(fieldname{1},{},fieldname{2},{},fieldname{3},{});
pp=1;  % first line of the v.in
% xx=xmin:(xmax-xmin)/100:xmax;   % use for interpolation
% ZZ=zeros(LN,length(xx));    % use for interpolation
error={};
errorcount=0;
for i=1:LN-1;
    for j=1:3; % bd=layer top boundary, tv=top velocity, bv=bottom velocity
        over10=1; % assume nodes number larger than 10
        final=[];
        while over10
            vv=cell(3,1);
            vl=zeros(3,1); %length
            for k=1:3; % x, z(v), partial derivative
                value=sscanf(imdata{pp},'%f'); % read values
                vl(k)=length(value);
                vv{k}=value'; % transverse to line vector
                pp=pp+1;
            end
            if vl(2)-vl(1)>2 || vl(3)~=vl(1)-1;
                errorcount=errorcount+1;
                error{errorcount}=['Layer ',num2str(i),', parameter ',num2str(j),': Node numbers do not equal!'];
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
%         if length(final(1,:))==1; % extend one node format to standard 2 or more nodes format
%             final(:,2)=final;
%             final(1,1)=xmin;
%         end
%         if final(1,1)~=xmin || final(1,end)~=xmax;
%             errorcount=errorcount+1;
%             error{errorcount}=['Layer ',num2str(i),', ',fullfn{j},': Node x coordinate is over model boundary! This problem has been fixed by reset first and last x coordinates.'];
%             final(1,1)=xmin; final(1,end)=xmax;
%         end
%         duplicate=find((final(1,2:end)-final(1,1:end-1))==0);
%         if ~isempty(duplicate);
%             errorcount=errorcount+1;
%             error{errorcount}=['Layer ',num2str(i),', ',fullfn{j},': Node x has same coordinate! This problem has been fixed by delete duplicated x coordinates.'];
%             final(:,duplicate)=[];
%         end
%         if ~isempty(find((final(1,2:end)-final(1,1:end-1))<0));
%             errorcount=errorcount+1;
%             error{errorcount}=['Layer ',num2str(i),', ',fullfn{j},': Node x coordinate is not monotonic increasing! This problem has been fixed by resort.'];
%             final=sortrows(final',1)';
%         end
%         if sum(final(3,:)==0)+sum(final(3,:)==1)+sum(final(3,:)==-1)~=length(final(3,:));
%             errorcount=errorcount+1;
%             error{errorcount}=['Layer ',num2str(i),', ',fullfn{j},': Node partial derivative has abnormal value! This problem has to be fixed MANULLY.'];
%         end
%         if j==1;    %'bd'
%             ZZ(i,:)=interp1(final(1,:),final(2,:),xx,'linear');  % for later depth check
%         end
        eval(['vmodel(',num2str(i),').',fieldname{j},'=final;']);
    end
end

% model bottom
value=sscanf(imdata{pp},'%f')';
pp=pp+1;
final=sscanf(imdata{pp},'%f')';
if length(value)>length(final);
    vmodel(LN).bd=[value(2:end); final];
else
    vmodel(LN).bd=[value(2:end); final(2:end)];
end

% final=vmodel(LN).bd;
% if length(final(1,:))==1; % extend one node format to standard 2 or more nodes format
%             final(:,2)=final;
%             final(1,1)=xmin;
% end
% vmodel(LN).bd=final;

% ZZ(LN,:)=interp1(vmodel(LN).bd(1,:),vmodel(LN).bd(2,:),xx,'linear');
% zmin=min(min(ZZ));
% zmax=max(max(ZZ));

% depth check
% for i=2:LN;
%     if ~isempty(find((ZZ(i,:)-ZZ(i-1,:))<0))
%         errorcount=errorcount+1;
%         error{errorcount}=['Layer ',num2str(i),': Top boundary depth less than above layer after linear interpolation! This problem has to be fixed MANULLY.'];
%     end
% end

% check if data match
dtmatch=1;
for i=1:LN-1
    laa=length(vmodel(i).bd(1,:));
    lab=length(vmodel(i).bd(2,:));
    lac=length(vmodel(i).bd(3,:));
    if laa~=lab||laa~=lac||lab~=lac
        dtmatch=0;
        break;
    end
    lba=length(vmodel(i).tv(1,:));
    lbb=length(vmodel(i).tv(2,:));
    lbc=length(vmodel(i).tv(3,:));
    if lba~=lbb||lba~=lbc||lbb~=lbc
        dtmatch=0;
        break;
    end
    lca=length(vmodel(i).bv(1,:));
    lcb=length(vmodel(i).bv(2,:));
    lcc=length(vmodel(i).bv(3,:));
    if lca~=lcb||lca~=lcc||lcb~=lcc
        dtmatch=0;
        break;
    end
end

if dtmatch==1
    ncont=LN;
    for i=1:LN-1
        [ll,cc]=size(vmodel(i).bd);
        for j=1:cc
            xm(i,j)=vmodel(i).bd(1,j);
            zm(i,j)=vmodel(i).bd(2,j);
            ivarz(i,j)=vmodel(i).bd(3,j);
        end
        [ll,cc]=size(vmodel(i).tv);
        for j=1:cc
            xvel(i,j,1)=vmodel(i).tv(1,j);
            vf(i,j,1)=vmodel(i).tv(2,j);
            ivarv(i,j,1)=vmodel(i).tv(3,j);
        end
        [ll,cc]=size(vmodel(i).bv);
        for j=1:cc
            xvel(i,j,2)=vmodel(i).bv(1,j);
            vf(i,j,2)=vmodel(i).bv(2,j);
            ivarv(i,j,2)=vmodel(i).bv(3,j);
        end
    end
    [ll,cc]=size(vmodel(LN).bd);
    for j=1:cc
        xm(LN,j)=vmodel(LN).bd(1,j);
        zm(LN,j)=vmodel(LN).bd(2,j);
    end
else
    disp('***  error in velocity model  ***');
    disp('the number of data does not match');
end

end

function fun_save_dout(temp,fileout)

if temp==1  % save the first part
    fid=fopen(fileout,'w');
    fprintf(fid,'\n');
    fprintf(fid,'%s','overall damping factor: ');
    fprintf(fid,'%10.5f',dmpfct{7});
    fprintf(fid,'\n');
    fprintf(fid,'\n');
    fprintf(fid,'%s','type  orig. val.  uncert.    adjust.   new val. resolution std. error');
    for i=1:nvar
        fprintf(fid,'\n');
        fprintf(fid,'%3i',partyp(i));
        fprintf(fid,'%11.4f',parorg(i));
        fprintf(fid,'%11.4f',parunc(i)^0.5);
        fprintf(fid,'%11.4f',dx(i));
        fprintf(fid,'%11.4f',parorg(i)+dx(i));
        fprintf(fid,'%11.4f',res(i,i));
        fprintf(fid,'%11.4f',sqrt(var(i)));
    end
    fprintf(fid,'\n');
    fprintf(fid,'\n');

    if iscrn{7}==1
        fprintf('\n');
        fprintf('%s','overall damping factor: ');
        fprintf('%10.5f',dmpfct{7});
        fprintf('\n');
        fprintf('\n');
        fprintf('%s','type  orig. val.  uncert.    adjust.   new val. resolution std. error');
        for i=1:nvar
            fprintf('\n');
            fprintf('%3i',partyp(i));
            fprintf('%11.4f',parorg(i));
            fprintf('%11.4f',parunc(i)^0.5);
            fprintf('%11.4f',dx(i));
            fprintf('%11.4f',parorg(i)+dx(i));
            fprintf('%11.4f',res(i,i));
            fprintf('%11.4f',sqrt(var(i)));
        end
        fprintf('\n');
        fprintf('\n');
    end
    fclose(fid);
end

if temp==2  %save the second part
%     switch precision
%   case 'high'
%         format_f='%8.3f';
%         format_d='%8i';
%   case 'low'
        format_f='%7.2f';
        format_d='%7i';
%     end
    fid=fopen(fileout,'a');
    for i=1:nlayer
        nstart=1;
        flag=0;
        while flag==0
            j1=nstart;  %590
            j2=j1+9;
            if j2>nzed(i)   %nzed(i)为该层boundary depth数据个数
                j2=nzed(i);
            end
            if j2<nzed(i)
                icnt=1; %是否未完待续
            else
                icnt=0;
            end
            fprintf(fid,'%2i ',i);
            fprintf(fid,format_f,xm(i,j1:j2));
            fprintf(fid,'\n');
            fprintf(fid,'%2i ',icnt);
            fprintf(fid,format_f,zm(i,j1:j2));
            fprintf(fid,'\n');
            fprintf(fid,'%s',blanks(3));
            fprintf(fid,format_d,ivarz(i,j1:j2));
            fprintf(fid,'\n');
            if iscrn{7}==1
                fprintf('%2i ',i);
                fprintf(format_f,xm(i,j1:j2));
                fprintf('\n');
                fprintf('%2i ',icnt);
                fprintf(format_f,zm(i,j1:j2));
                fprintf('\n');
                fprintf('%s',blanks(3));
                fprintf(format_d,ivarz(i,j1:j2));
                fprintf('\n');
            end
            if j2==nzed(i)
                flag=1;     % go to 600
            end
            nstart=j2+1;
        end     % go to 590
        %600
        nstart=1;
        flag=0;
        while flag==0
            j1=nstart;  %620
            j2=j1+9;
            if j2>nvel(i,1)     %nvel(i,1)为该层top velocity数据个数
                j2=nvel(i,1);
            end
            if j2<nvel(i,1)
                icnt=1;
            else
                icnt=0;
            end
            fprintf(fid,'%2i ',i);
            fprintf(fid,format_f,xvel(i,j1:j2,1));
            fprintf(fid,'\n');
            fprintf(fid,'%2i ',icnt);
            fprintf(fid,format_f,vf(i,j1:j2,1));
            fprintf(fid,'\n');
            fprintf(fid,'%s',blanks(3));
            fprintf(fid,format_d,ivarv(i,j1:j2,1));
            fprintf(fid,'\n');
            if iscrn{7}==1
                fprintf('%2i ',i);
                fprintf(format_f,xvel(i,j1:j2,1));
                fprintf('\n');
                fprintf('%2i ',icnt);
                fprintf(format_f,vf(i,j1:j2,1));
                fprintf('\n');
                fprintf('%s',blanks(3));
                fprintf(format_d,ivarv(i,j1:j2,1));
                fprintf('\n');
            end
            if j2==nvel(i,1)
                flag=1;     % go to 630
            end
            nstart=j2+1;
        end     % go to 620
        %630
        nstart=1;
        flag=0;
        while flag==0
            j1=nstart;  %650
            j2=j1+9;
            if j2>nvel(i,2)     %nvel(i,2)为该层bottom velocity数据个数
                j2=nvel(i,2);
            end
            if j2<nvel(i,2)
                icnt=1;
            else
                icnt=0;
            end
            fprintf(fid,'%2i ',i);
            fprintf(fid,format_f,xvel(i,j1:j2,2));
            fprintf(fid,'\n');
            fprintf(fid,'%2i ',icnt);
            fprintf(fid,format_f,vf(i,j1:j2,2));
            fprintf(fid,'\n');
            fprintf(fid,'%s',blanks(3));
            fprintf(fid,format_d,ivarv(i,j1:j2,2));
            fprintf(fid,'\n');
            if iscrn{7}==1
                fprintf('%2i ',i);
                fprintf(format_f,xvel(i,j1:j2,2));
                fprintf('\n');
                fprintf('%2i ',icnt);
                fprintf(format_f,vf(i,j1:j2,2));
                fprintf('\n');
                fprintf('%s',blanks(3));
                fprintf(format_d,ivarv(i,j1:j2,2));
                fprintf('\n');
            end
            if j2==nvel(i,2)
                flag=1;     % go to 570
            end
            nstart=j2+1;
        end     % go to 650
    end     %570

    fprintf(fid,'%2i ',ncont);
    fprintf(fid,format_f,xm(ncont,1:nzed(ncont)));
    fprintf(fid,'\n');
    fprintf(fid,'%2i ',0);
    fprintf(fid,format_f,zm(ncont,1:nzed(ncont)));
    if iscrn{7}==1
        fprintf('%2i ',ncont);
        fprintf(format_f,xm(ncont,1:nzed(ncont)));
        fprintf('\n');
        fprintf('%2i ',0);
        fprintf(format_f,zm(ncont,1:nzed(ncont)));
    end
end
end

function fun_load_din(filein)

    fid = fopen(filein,'r');
    currentline = fgetl(fid);
    %disp(currentline)
    index_and=findstr(currentline,'&');
    currentline=currentline(index_and+8:end); % 只留下"&dmppar"后的数据部分
    tline=fgetl(fid);
    %disp(tline)
    index_and=findstr(tline,'&');
    while isempty(index_and) % index_and为空，即未到&end
        currentline=[currentline tline]; % 将同一个section的有效部分整合成一个字符串
        tline=fgetl(fid);
        index_and=findstr(tline,'&');
    end

    % 开始进行拆分处理
    % currentline='  &pltpar  modout=2, dxmod=0.010, dzmod=0.010, modi=2,3,4*1,5,6,7,8,9*0,  ';  % 调试范例
    currentline=strrep(currentline,' ',''); % 删除所有的空格
    currentline=regexprep(currentline,'\t',''); % 删除所有的tab，由于tab是特殊符号，需要用regexprep
    %disp(currentline)
    index_comma=findstr(currentline,',');
    index_equal=findstr(currentline,'=');
    wordnumber=length(index_equal); % 该行包含的字段个数与=号个数相同
    for i=1:wordnumber;
        index=find(index_comma<index_equal(i)); % 找到比当前=号位置小的所有，号
        if isempty(index);  % 说明这是第一个word
            wordstart=1;
        else  % 其他普通的情况
            wordstart=index_comma(index(end))+1;
        end
        if  i==wordnumber; % 最后一个字段的情况
            wordend=length(currentline);
        else % 其他普通的情况
            index=find(index_comma<index_equal(i+1)); % 找到比下一个=号位置小的所有，号
            wordend=index_comma(index(end));
        end
        currentword=currentline(wordstart:wordend);
        position_equal=findstr(currentword,'=');
        wordname=currentword(1:position_equal-1);
        position_comma=findstr(currentword,',');
        wordvalue=currentword(position_equal+1:position_comma-1);
        eval([wordname,'{6}=',wordvalue,';']); % 给对应wordname的cell的导入值赋值;eval命令可以把字符串（符合命令形式）当作命令来执行
        eval([wordname,'{7}=',wordvalue,';']); % 给对应wordname的cell的输出值赋值；例如wordname='iplot'，则这句相当于 iplot{7}=vv;
        eval([wordname,'{8}=true;']); % 该wordname需要输出
    end  % 结束 for i=1:wordnumber;
    fclose(fid);
    %display (['Finish reading ',filein]);
end

function fun_load_iout(filein)
%FUN_LOAD_IOUT Summary of this function goes here
%   Detailed explanation goes here
fid = fopen(filein,'r');
fgetl(fid);
line = fgetl(fid);
temp = sscanf(line,'%i');
narinv = temp(1);
nvar = temp(2);
fgetl(fid);

for i=1:nvar
    line = fgetl(fid);
    temp = sscanf(line,'%i');
    partyp(i) = temp(1);
    temp = sscanf(line,'%f');
    parorg(i) = temp(2);
    parunc(i) = temp(3);
end

fgetl(fid);
temp = fscanf(fid,'%f');
for i=1:narinv
    for j=1:nvar
        apart(i, j) = temp((i - 1) * nvar + j);
    end
end

for i=1:narinv
    tres(i) = temp(narinv * nvar + i);
end

for i=1:narinv
    tunc(i) = temp(narinv * nvar + narinv + i);
end
fclose(fid);
end

function fun_load_din2(filein)  % if there is need to read more than one section
        fid = fopen(filein,'r');
        currentline = fgetl(fid);
        while ischar(currentline);  % 当最后一行读完后，fgetl返回-1，就不是char类型了，跳出while循环
            disp(currentline)
            % 开始进行块section的识别和整合
            index_and=findstr(currentline,'&');
            if ~isempty(index_and); % index_and非空，即存在&符号
                samesect=true;  % 进入了一个section
                sectname=currentline(index_and:index_and+6); % &参数部分的名字都是6个字符，例如pltpar
                currentline=currentline(index_and+8:end); % 只留下数据部分
                while samesect;
                    tline=fgetl(fid);
                    disp(tline)
                    index_and=findstr(tline,'&');
                    if ~isempty(index_and); % index_and非空，即存在&符号
                        if strcmp(tline(index_and+1:index_and+3),'end'); % 如果是&end，表明这个section结束了
                            samesect=false;
                        end
                    else
                        currentline=[currentline tline]; % 将同一个section的有效部分整合成一个字符串
                    end
                end
            end
            % 开始进行拆分处理
            % currentline='  &pltpar  modout=2, dxmod=0.010, dzmod=0.010, modi=2,3,4*1,5,6,7,8,9*0,  ';  % 调试范例
            currentline=strrep(currentline,' ',''); % 删除所有的空格
            currentline=regexprep(currentline,'\t',''); % 删除所有的tab，由于tab是特殊符号，需要用regexprep
            disp(currentline)
            index_comma=findstr(currentline,',');
            index_equal=findstr(currentline,'=');
            wordnumber=length(index_equal); % 该行包含的字段个数与=号个数相同
            for i=1:wordnumber;
                index=find(index_comma<index_equal(i)); % 找到比当前=号位置小的所有，号
                if isempty(index);  % 说明这是第一个word
                    wordstart=1;
                else  % 其他普通的情况
                    wordstart=index_comma(index(end))+1;
                end
                if  i==wordnumber; % 最后一个字段的情况
                    wordend=length(currentline);
                else % 其他普通的情况
                    index=find(index_comma<index_equal(i+1)); % 找到比下一个=号位置小的所有，号
                    wordend=index_comma(index(end));
                end
                currentword=currentline(wordstart:wordend);
                position_equal=findstr(currentword,'=');
                wordname=currentword(1:position_equal-1);
                position_comma=findstr(currentword,',');
                vv=[];
                for j=1:length(position_comma); % 有多少个逗号，就有多少个数据
                    if j==1;
                        vs=currentword(position_equal+1:position_comma(j)-1);
                    else
                        vs=currentword(position_comma(j-1)+1:position_comma(j)-1);
                    end
                    position_star=findstr(vs,'*');
                    if ~isempty(position_star); % index_star非空，即存在*，需要把重复的数字给展开
                        vv=[vv ones(1,str2num(vs(1:position_star-1))).*str2num(vs(position_star+1:end))]; % ones用来创建全是1的向量或者矩阵，点乘同一个数字，就得到全部重复的数据
                    else  % 没有重复的普通情况
                        vv=[vv sscanf(vs,'%f')];
                    end
                end
                eval([wordname '{6}=vv;']); % 给对应wordname的cell的导入值赋值;eval命令可以把字符串（符合命令形式）当作命令来执行
                eval([wordname '{7}=vv;']); % 给对应wordname的cell的输出值赋值；例如wordname='iplot'，则这句相当于 iplot{7}=vv;
                eval([wordname '{8}=true;']); % 该wordname需要输出
            end  % 结束 for i=1:wordnumber;
            currentline = fgetl(fid); % 处理完毕，读入下一行
        end % 结束 while ischar(currentline);
        fclose(fid);
        % display (['Finish reading ',filein]);
end

end




