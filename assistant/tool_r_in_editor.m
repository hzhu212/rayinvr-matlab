function tool_r_in_editor
% disp ('2: r.in editor');

%% 1 Variables
% 变量采用cell（列的形式）来保存，依次为：1、属于哪个部分；2、类型（III：代表整数，例如开关switch和整型数组；FFF：代表浮点数）；3、英文说明；4、中文说明；
% 5、初始值/缺省值；6、导入值（如果导入r.in时没有对应值，则保持NaN）；
% 7、输出值/当前值（初始为NaN或者为5的缺省值，视情况而定；当有导入的对应项时，设为导入值，可以后期更改，必要时可以重置reset为5的缺省值或者6的导入值）；
% 8、是否输出，为逻辑类型，常用项缺省为true，不常用项缺省为false，当有导入的对应项时，设为true，可以后期更改，必要时可以重置reset为导入对应项的情况；
% 9、特别的，对于开关类型，多出一个数组，用于保存开关的可供选择值

% Fortran定义变量时的隐式声明规则：在程序中，凡是变量名以字母I,J,K,L,M,N,i,j,k,l,m,n开头的变量被默认为整型变量，以其他字母开头的变量被默认为实型变量。
% 除非某变量名被明确声明为整型或者实型，或者用implicit none 取消定义变量时的隐式声明规则。

allnames={}; % 用于依次保存所有建立的r.in参数名

%% 1.1 define: Plot parameters (总体图形控制)
%% 1.1.1 switch part
% iroute
allnames=[allnames; 'iroute'];
eng=['iroute: equals 1 to plot to the screen, 2 to create a postscript file,',char(13,10)',...  % “...”用来续行，“char(13,10)'”用来对字符串内部换行
    '3 to create a plot file for the VERSATEC plotter, or 4 to create a colour postscript file;',char(13,10)',...
    'if iroute does not equal 1 there is no plotting to the screen (default: 1).'];
chi=['注意：iroute在Linux下无用，但还是解释如下',char(13,10)',...
    '1：直接画在显示器上；2：生成黑白色的postscript（PS）文件；',char(13,10)',...
    '3：生成VERSATEC绘图仪文件；4、生成彩色的postscript（PS）文件。'];
iroute={'&pltpar','III',eng,chi,1,NaN,1,false,[1 2 3 4]}'; % 加’转为列向量的形式

% iseg
allnames=[allnames; 'iseg'];
eng='iseg: create a Uniras segment(s) (default: 0).'; % 当不需要进行字符串连接时，取消方括号[]
chi=['注意：iseg这个参数在Linux上无用！但还是解释如下',char(13,10)',...
    '生成Uniras（一种类似于AutoCAD的制图系统？）的文件块 (缺省为0，不生成；需要生成时改为1)'];
iseg={'&pltpar','III',eng,chi,0,NaN,0,false,[0 1]}';

% iplot
allnames=[allnames; 'iplot'];
eng=['generate the plot during the run (1), or write all plot commands to the file p.out (0) ', 'or do both (2) (default: 1).'];
chi=['iplot开关控制画图方式： 当为0时，不出现在屏幕上，全部以命令的形式写入p.out文件（实际上是.ps文件）；当为1时，在屏幕上画图；',char(13,10)',...
    '当为2时，以上两者都执行。现在的缺省值为2（原始为1）。'];
iplot={'&pltpar','III',eng,chi,2,NaN,2,true,[0 1 2]}';

% imod
allnames=[allnames; 'imod'];
eng='plot model boundaries (default: 1).';
chi='imod开关控制是否把模型的层界面给画出来。';
imod={'&pltpar','III',eng,chi,1,NaN,1,true,[0 1]}';

% ibnd
allnames=[allnames; 'ibnd'];
eng='plot vertical model boundaries (default: 1).';
chi='ibnd开关控制是否把程序自动生成的模型四边形块的纵向边界给画出来。';
ibnd={'&pltpar','III',eng,chi,1,NaN,1,true,[0 1]}';

% idash
allnames=[allnames; 'idash'];
eng='plot model boundaries as dashed lines (default: 1).';
chi='idash开关控制是否把模型边界画成虚线的形式。缺省值为1，即画虚线。';
idash={'&pltpar','III',eng,chi,1,NaN,1,false,[0 1]}';

% ivel
allnames=[allnames; 'ivel'];
eng='plot the P-wave (1) or S-wave (-1) velocity values (km/s) within each trapezoid of the model (default: 0).';
chi='ivel开关控制是否在模型四边形块中标注纵波速度（为1时）或者横波速度（为-1时）；单位为km/s，缺省值为0。';
ivel={'&pltpar','III',eng,chi,0,NaN,0,false,[-1 0 1]}';

% iray
allnames=[allnames; 'iray'];
eng=['plot all rays traced (1), or only those which reach the surface (or reflect off the floating reflector ',char(13,10)',...
    'for ray groups for which frbnd>0) (2). Rays traced in the search mode are not plotted unless irays=1 (default: 1).'];
chi=['iray开关为缺省值1时画出所有追踪的射线，为2时仅画出到达表面的射线（或者从浮动界面反射的射线，',char(13,10)',...
    '当某组射线对应的浮动界面数frbnd大于0时）。注意：无论1还是2，搜索模式的射线都不画，除非irays=1。'];
iray={'&pltpar','III',eng,chi,1,NaN,1,true,[1 2]}';

% irays
allnames=[allnames; 'irays'];
eng='plot the rays traced in the search mode (default: 0).';
chi='irays控制是否画出在搜索模式下追踪过的所有射线，主要与istep配合用于debug调试目的。';
irays={'&pltpar','III',eng,chi,0,NaN,0,false,[0 1]}';

% irayps
allnames=[allnames; 'irayps'];
eng='plot the P-wave segments of ray paths as solid lines and the S-wave segments as dashed lines (default: 0).';
chi='irayps开关打开时，射线的纵波部分表现为实线，横波部分表现为虚线。现在缺省值改为1，原始为0。';
irayps={'&pltpar','III',eng,chi,1,NaN,1,true,[0 1]}';

% idot
allnames=[allnames; 'idot'];
eng='plot a symbol at each point (step length), defining each ray path (default: 0).';
chi='idot开关打开时会用圆点符号标识每条射线的步长点；缺省值为0，即不画出这些步长点。';
idot={'&pltpar','III',eng,chi,0,NaN,0,false,[0 1]}';

% itx
allnames=[allnames;'itx'];
eng=['plot the calculated travel time-distance values as lines (1), symbols of height symht (2), symbols of height "symht" interpolated at the observed receiver ',char(13,10)',...
    'locations contained in the file tx.in (invr=1 must be used, if not, itx=2 is used) (3); or as residuals measured from the oberved data in tx.in ',char(13,10)',...
    '(invr=1 must be used) (4); no calculated travel times are plotted if itx=0 (default: 1).'];
chi=['itx控制如何在travel time-distance窗口中把模型计算的理论走时画出来（用于跟实际拾取的走时idata进行比较）：当为缺省值1时，画成实线；当为2时，画成圆点符号',char(13,10)',...
    '（符号大小/高度为symht，单位mm）；当为3时，跟2相同也是圆点，但仅在接收点位置处插值画出，即仅画出实际走时与理论计算值两者的交集部份',char(13,10)',...
    '（要求invr=1，否则等同于itx=2；当为4时，画出实际走时与理论计算值的残差（要求invr=1）；当为0时，没有理论走时被画出。'];
itx={'&pltpar','III',eng,chi,1,NaN,1,true,[0 1 2 3 4]}';

% itxbox
allnames=[allnames; 'itxbox'];
eng='plot only those calculated and observed travel times that have distances between xmint and xmaxt and times between tmin and tmax (default: 0).';
chi='itxbox开关打开时将把要画的计算走时和观察走时限制在横坐标[xmint xmaxt]、纵坐标[tmin tmax]的范围内；缺省为0不限制。';
itxbox={'&pltpar','III',eng,chi,0,NaN,0,false,[0 1]}';

% idata
allnames=[allnames; 'idata'];
eng=['plot the observed travel time picks from the file tx.in (1 or -1), or plot only those picks used in the inversion if invr=1 (2 or -2). ',char(13,10)',...
    'The observed data are represented by vertical bars with a height of twice the corresponding uncertainty specified in the file tx.in if idata>0,',char(13,10)',...
    'or by symbols of height symht if idata<0 (default: 0).'];
chi=['idata控制是否画出实际走时：当为1或者-1时，画出列在tx.in文件中的全部走时；当为2或者-2时，仅画出要进行反演（invr=1）的走时（列在ivray中的phase编号）。',char(13,10)',...
    '注意：正值画两倍不确定值高度的短柱，负值画symht高度的圆点符号。现在的缺省值改为2，原始为0（不画出实际走时）。'];
idata={'&pltpar','III',eng,chi,2,NaN,2,true,[-2 -1 0 1 2]}';

% isep
allnames=[allnames; 'isep'];
eng=['plot the model and rays and travel times in the same plot frame (0), separate plot frames (1), plot the model and rays and travel times in a separate ',char(13,10)',...
    'plot frame for each shot (2), or plot the model and rays in separate plot frames for each shot followed by the travel times in separate plot frames for each shot (3) (default: 0). ',char(13,10)',...
    'Note: the value of isep may be changed during a program run with entry from the keyboard of the values 0, 1, 2 or 3 between plot frames ',char(13,10)',...
    'when "a" is needed to continue; entering "s" will terminate the program run.'];
chi=['isep控制射线图和走时图以及源（注意：OBS被当作炮点看待）是否画在同一个图框中：当为缺省值0时，全部在同一个图框中，上面为射线图，下面为走时图；',char(13,10)',...
    '当为1时，射线图和走时图分别用两幅图来画；当为2时，射线图和走时图虽然在同一个图框中，但每个源（OBS）分别画图；当为3时，每个源分别画，',char(13,10)',...
    '先是射线图，然后是走时图。注意：在程序运行时可以在画框间歇期从键盘输入0, 1, 2 or 3更改画图方式，然后输入“a”继续；输入“s”则程序终止。'];
isep={'&pltpar','III',eng,chi,0,NaN,0,true,[0 1 2 3]}';

% iszero
allnames=[allnames; 'iszero'];
eng='plot the calculated and observed travel times as if all shot points were at 0 km and the rays travelled left to right (default: 0).';
chi='iszero开关打开时，不管实际源的位置如何，计算的和实际的走时都假设源在0 km处从左往右画。调试用途，缺省值为0。';
iszero={'&pltpar','III',eng,chi,0,NaN,0,false,[0 1]}';

% itxout
allnames=[allnames; 'itxout'];
eng=['write the calculated travel time-distance pairs to the file tx.out. ',...
    'The integer code identifying each pick is determined by the array "ibreak" if itxout=1 or the array "ivray" if itxout=2 or 3; ',...
    'if itxout=3, the calculated travel times are interpolated to the observed receiver locations (invr=1 must be used if itxout=3, if not, itxout=2 is used) (default: 0).',...
    'Note: there appears to be a bug with itxout, itx=itxout may be necessary for correct results.'];
chi=['itxout控制是否将模型计算的走时-距离配对数据写入文件tx.out。原始缺省值为0（不输出），现在的缺省值改为2，使得tx.out中标识走时phase的整数与ivray中的相同；',char(13,10)',...
    '如果值为3，且invr=1，则输出的是计算走时在接收点的插值（如果itxout=3但invr=0，则实际用的是itxout=2）。如果itxout=1，则tx.out中标识走时phase的整数由ibreak决定。',char(13,10)',...
    '注意：itxout好像有bug，要想获取正确答案，可能需要令 itx=itxout。'];
itxout={'&pltpar','III',eng,chi,2,NaN,2,true,[0 1 2 3]}';

% idump
allnames=[allnames; 'idump'];
eng=['write detailed velocity model and ray tracing information to the file r2.out and the namelist parameter values to the file n.out; mainly for debugging (default: 0).',...
    'Note: using idump=1 will greatly slow down the run time!'];
chi='idump主要是用于出错调试，控制是否把速度模型的细节和射线追踪信息写入r2.out，并把参数列表和值写入n.out。建议idump保持为缺省值0，因为idump=1会极大降低计算速度。';
idump={'&pltpar','III',eng,chi,0,NaN,0,false,[0 1]}';

% isum
allnames=[allnames; 'isum'];
eng=['write a short summary about the rays traced and the velocity model to the screen (1), ',...
    'also write the travel time residuals and chi-squared values for each phase and shot to the file r1.out (2), ',...
    'and to the screen (3) (must use invr=1 for isum>1) (default: 1).'];
chi=['isum控制运行结果的总结信息：（isum=1）在屏幕上显示射线追踪和速度模型的简短信息；（isum=2）同时将每个事件和源的走时残差和chi-squared值写入r1.out；',char(13,10)',...
    '（isum=3）提供最全的信息，这些信息除了在屏幕上显示，还同时输出到r1.out中。注意：当isum=2 or 3时，要求invr=1，否则输出的结果跟isum=1一样。',char(13,10)',...
    '原始的缺省值为1，现在改为3。'];
isum={'&pltpar','III',eng,chi,3,NaN,3,true,[1 2 3]}';

% istep
allnames=[allnames; 'istep'];
eng=['pause after each ray is plotted writing its take-off angle to the screen and waiting until "a" is entered before plotting the next ray; ',...
    'this is mainly intended to be used in conjunction with irays=1 to determine the cause of the failure of the search mode for a particular ray group; ',...
    'entering "s" after any ray will terminate the program run (default: 0).'];
chi='istep开关控制是否每画一条射线就暂停等待人工干预；主要是跟irays=1配合，对某个特定的ray code进行分析，确定搜索模式失效的原因。';
istep={'&pltpar','III',eng,chi,0,NaN,0,false,[0 1]}';

%% 1.1.2 single number part
% symht
allnames=[allnames; 'symht'];
eng=['height of symbols (mm) used when plotting each point defining a ray path, single point travel time curves (if symht=0, single point ',char(13,10)',...
    'travel time curves will not be plotted), the calculated travel times if itx=2, or the observed travel times if idata<0 (default: 0.5).'];
chi=['symht定义圆点符号的高度（缺省值为0.5，单位mm）。圆点符号用在（1）射线的每个步进长度位置（如果idot=1）；（2）只有1个点的走时曲线',char(13,10)',...
    '（如果symht=0，则这种情况不会被画出）；（3）计算的走时（如果itx=2）；（4）实际走时（如果idata<0）。'];
symht={'&pltpar','FFF',eng,chi,0.5,NaN,0.5,false,NaN}';

% velht
allnames=[allnames; 'velht'];
eng='the maximum height of the velocity values (mm) when ivel=1 or -1 is equal to velht*albht (default: 0.7).';
chi='velht在ivel=1时，定义模型四边形块体速度标识的最大高度（缺省值0.7，单位mm）。注意：当ivel=-1时，速度标识的高度为velht*albht。';
velht={'&pltpar','FFF',eng,chi,0.7,NaN,0.7,false,NaN}';

% nskip
allnames=[allnames; 'nskip'];
eng='the first nskip points (step lengths) of all ray paths are not plotted (default: 0).';
chi=['nskip定义所有射线画图时要跳过的最开始的控制点（射线的每个步进长度位置）的数目，',char(13,10)',...
    '这可以使得震源附近的射线不那么密集（估计设为1就足够了；缺省值为0，即不跳过开始点）。'];
nskip={'&pltpar','III',eng,chi,0,NaN,0,false,NaN}';

% nrskip
allnames=[allnames; 'nrskip'];
eng='plot every nrskip ray traced (default: 1).';
chi=['nrskip定义每隔多少条射线才画一条，减少射线数目效果明显；缺省值为1。',char(13,10)',...
    '注意：实际画的射线条数是针对每个方向、每个炮点、每个ray code进行计算，比如 nrskip=10，对于',char(13,10)',...
    'shot#  -1:   ray code  2.3:    23 rays traced  画2条线',char(13,10)',...
    'shot#   5:   ray code  4.2:     1 rays traced  画1条线（只要不是 0 rays traced，则至少有1条线）。'];
nrskip={'&pltpar','III',eng,chi,1,NaN,1,false,NaN}';

% npskip
allnames=[allnames; 'npskip'];
eng='plot every npskip point of each ray traced (default: 1).';
chi=['npskip控制射线每隔多少个追踪点才画1个，从而控制射线画出的光滑程度：',char(13,10)',...
    '跳过的点数越多（npskip>1），则折线形态越明显；缺省值为1。'];
npskip={'&pltpar','III',eng,chi,1,NaN,1,false,NaN}';

% vred
allnames=[allnames; 'vred'];
eng=['reducing velocity (km/s) of travel time-distance plot; observed data in the file tx.in is assumed to be unreduced ',char(13,10)',...
    '(a value of zero is permitted for no reduction; vred must be less than 10) (default: 8).'];
chi=['vred定义换算速度（reduced velocity）（km/s），用于计算走时图的折合时间，从而压缩走时图的时间纵轴，看起来更舒服。现在的缺省值改为4，原始为8（最大为10）。',char(13,10)',...
    '当为0时，走时没有折减，即为实际走时。tx.in文件中的实际走时必须是原始、没有折减的走时！计算公式：折合时间=实际走时-收发水平偏移距/换算速度。',char(13,10)',...
    '例如：接收点在模型的0坐标（对于接收点，深度永远为0），发射点在5.94公里（发射点的深度可以大于0，但这里计算用不到），原始拾取的走时为4.108秒，',char(13,10)',...
    '如果vred=10，则画图时的折合到时为 4.108-(5.94-0)/10=3.514秒。'];
vred={'&pltpar','FFF',eng,chi,4,NaN,4,true,NaN}';

% xwndow
allnames=[allnames; 'xwndow'];
eng=['the horizontal size of the graphics window (mm) that will over-ride a window size specified in an "mx11.opt" ;',char(13,10)',...
    'or ".Xdefaults" file; the maximum allowable values (to use the entire screen) are 350 mm',char(13,10)',...
    '(defaults: if xwndow is less than or equal to zero, the size of the window specified in the "mx11.opt" ',char(13,10)',...
    'or ".Xdefaults" file is used). Note: the effect of this parameter will depend on the local graphics system and machine type.'];
chi=['[xwndow ywndow]定义画图窗口的大小（单位 mm，最大值为[350 265]时对应全部屏幕）。当设为缺省值0或者小于0的值时，',char(13,10)',...
    '将使用定义在“mx11.opt”或者“.Xdefaults”中的窗口大小。注意：这对参数的效果依赖于本地的图形和操作系统。'];
xwndow={'&pltpar','FFF',eng,chi,300,NaN,300,true,NaN}';

% ywndow
allnames=[allnames; 'ywndow'];
eng=['the vertical size of the graphics window (mm) that will over-ride a window size specified in an "mx11.opt" ;',char(13,10)',...
    'or ".Xdefaults" file; the maximum allowable values (to use the entire screen) are 265 mm',char(13,10)',...
    '(defaults: if ywndow is less than or equal to zero, the size of the window specified in the "mx11.opt" ',char(13,10)',...
    'or ".Xdefaults" file is used). Note: the effect of this parameter will depend on the local graphics system and machine type.'];
chi=['[xwndow ywndow]定义画图窗口的大小（单位 mm，最大值为[350 265]时对应全部屏幕）。当设为缺省值0或者小于0的值时，',char(13,10)',...
    '将使用定义在“mx11.opt”或者“.Xdefaults”中的窗口大小。注意：这对参数的效果依赖于本地的图形和操作系统。'];
ywndow={'&pltpar','FFF',eng,chi,215,NaN,215,true,NaN}';

% dvmax
allnames=[allnames; 'dvmax'];
eng=['a warning message is written to the screen and to the file r1.out indicating the layers, ',...
    'in which the magnitude of the velocity gradient vector is greater than dvmax (km/s/km)(defaults: infinite).'];
chi='dvmax定义模型速度梯度的警告限（缺省值为无限大，单位为km/s/km），当大于dvmax时，这些超限的层号会在屏幕上显示并写入r1.out。';
dvmax={'&pltpar','FFF',eng,chi,inf,NaN,inf,false,NaN}';

% dsmax
allnames=[allnames; 'dsmax'];
eng=['a warning message is written to the screen and to the file r1.out indicating the layer boundaries ',...
    'having a change in slope across three successive points of greater than dsmax (degrees)(defaults: infinite).'];
chi='dsmax定义模型界面倾角的警告限（缺省值为无限大，单位为degree），当发现界面坡度（由连续3个点构成）大于dsmax时，这些超限的层号会在屏幕上显示并写入r1.out。';
dsmax={'&pltpar','FFF',eng,chi,inf,NaN,inf,false,NaN}';

% ibcol
allnames=[allnames; 'ibcol'];
eng='background colour (defaults: 0).';
chi='ibcol定义模型的背景色；缺省值为0白色。';
ibcol={'&pltpar','III',eng,chi,0,NaN,0,false,NaN}';

% ifcol
allnames=[allnames; 'ifcol'];
eng='foreground colour (defaults: 1).';
chi='ifcol定义模型的前景色；缺省值为1黑色。';
ifcol={'&pltpar','III',eng,chi,1,NaN,1,false,NaN}';

% ircol
allnames=[allnames; 'ircol'];
eng=['colour the ray paths according to the value of ivray for that particular ray group (1),' ,char(13,10)',...
    'according to the shot number (2), or according to the ray group (3) (default: 0).'];
chi=['ircol控制射线的颜色方案：为0时，所有射线全是黑色；为1时，每个ray code的射线颜色由ivray中的对应值决定，',char(13,10)',...
    '例如，ray 2.2和2.3在ivray中都用的是phase 1，则这两组射线的颜色相同；为2时，根据shot number来着色；',char(13,10)',...
    '当为3时，则根据射线的ray code来着色。'];
ircol={'&pltpar','III',eng,chi,1,NaN,1,true,[0 1 2  3]}';

% itcol
allnames=[allnames; 'itcol'];
eng=['colour the observed travel times according to the integer code identifying each pick in the file tx.in (the 4th column) (1), or according to the ',char(13,10)',...
    'shot number (2); if itcol=3, the observed travel times are coloured as if itcol=1 and the calculated travel times are coloured according to ray group (invr=1 must be used) (default: 0).'];
chi=['itcol控制实际走时（tx.in）的着色方案：为0时，全为黑色；为1时，根据tx.in中第4列phase的编号进行着色；为2时，根据shot number着色；为3时，实际走时的着色方案',char(13,10)',...
    '与itcol=1相同，理论计算的走时则根据ray code上色（要求invr=1）。提示：经测试，3的结果跟0相同，即全为黑色，原因不明。'];
itcol={'&pltpar','III',eng,chi,1,NaN,1,true,[0 1 2 3]}';

% title
allnames=[allnames; 'title'];
eng='title for plot (up to 80 characters long) positioned using xtitle and ytitle (default: none). Not currently available on the UBC package.';
chi=' ';
title={'&pltpar','SSS',eng,chi,'','','',false,NaN}';

% xtitle
allnames=[allnames; 'xtitle'];
eng='x position (mm) of the plot title (default: 0). Not currently available on the UBC package.';
chi=' ';
xtitle={'&pltpar','FFF',eng,chi,0,NaN,0,false,NaN}';

% ytitle
allnames=[allnames; 'ytitle'];
eng='y position (mm) of the plot title (default: 0). Not currently available on the UBC package.';
chi=' ';
ytitle={'&pltpar','FFF',eng,chi,0,NaN,0,false,NaN}';

% modout
allnames=[allnames; 'modout'];
eng=['output discretised velocity model (ARG 8.8.99): When modout = 1, an output file named v.out is created, ',char(13,10)',...
    'which contains the velocity model on a uniform grid defined by dxmod, dzmod, xmmin and xmmax. ',char(13,10)',...
    'Also fort.35 is created, another representation of the discretised velocity model ',char(13,10)',...
    'which can then be used in a GMT script to produce a colour contoured version of the velocity model. ',char(13,10)',...
    'fort.35 is a simple x,z,v file where the first column is the x position, the second column is the z position, ',char(13,10)',...
    'and the third column is the velocity. When modout = 2, the same outputs as modout=1 are created plus fort.63. ',char(13,10)',...
    'fort.63 is a simple x,z,s file where the third column is the number of rays which pass through that cell, ',char(13,10)',...
    'and thus it can be used for plotting ray density on the same plot as the velocity model.'];
chi=['modout开关控制是否输出规则网格单元化的速度模型以方便后期绘制漂亮的彩色等值线图：缺省值为0，即不输出；',char(13,10)',...
    '当为1时，根据dxmod, dzmod, xmmin and xmmax创建规则网格的v.out模型文件，同时输出的fort.35采用x,z,v的文本格式，',char(13,10)',...
    '可用于GMT绘制彩色等值线图，其中x为距离横坐标，z为深度纵坐标，v为速度值；当为2时，再多输出一个fort.63文件，',char(13,10)',...
    '为x,z,s文本格式，其中s为穿过[x,z]单元的射线数目，故而可以用GMT来绘制射线密度的彩色等值线图。'];
modout={'&pltpar','III',eng,chi,0,NaN,0,false,[0 1 2]}';

% dxmod
allnames=[allnames; 'dxmod'];
eng='size of increment in x direction for discretised output model, v.out. (ARG 15.10.98).';
chi=['[dxmod dzmod]分别为离散化模型文件v.out中x和z方向的网格增量，以km为单位，两者共同决定了v.out，for.35和for.63文件的字节数。',char(13,10)',...
    '而且，程序对两者共同设定的网格数目有限制，如果太大，会造成内存分配失败，提示“segmentation fault”。',char(13,10)',...
    '一般来说，因为模型往往是在横向上延续很多公里，但深度相对不大，因此，dxmod值太小的话，更容易造成“segmentation fault”错误。',char(13,10)',...
    '比较而言，当dzmod=0.001即达到米级精度时，dxmod最小可能只能到0.025。例如，目前对Subbarao最终模型测试的结果是，',char(13,10)',...
    'dxmod最小只能到0.025，即使增大dzmod到10，也不能使dxmod到0.02。'];
dxmod={'&pltpar','FFF',eng,chi,0.05,NaN,0.05,false,NaN}';

% dzmod
allnames=[allnames; 'dzmod'];
eng='size of increment in z direction for discretised output model, v.out. (ARG 15.10.98).';
chi=['[dxmod dzmod]分别为离散化模型文件v.out中x和z方向的网格增量，以km为单位，两者共同决定了v.out，for.35和for.63文件的字节数。',char(13,10)',...
    '而且，程序对两者共同设定的网格数目有限制，如果太大，会造成内存分配失败，提示“segmentation fault”。',char(13,10)',...
    '一般来说，因为模型往往是在横向上延续很多公里，但深度相对不大，因此，dxmod值太小的话，更容易造成“segmentation fault”错误。',char(13,10)',...
    '比较而言，当dzmod=0.001即达到米级精度时，dxmod最小可能只能到0.025。例如，目前对Subbarao最终模型测试的结果是，',char(13,10)',...
    'dxmod最小只能到0.025，即使增大dzmod到10，也不能使dxmod到0.02。'];
dzmod={'&pltpar','FFF',eng,chi,0.01,NaN,0.01,false,NaN}';

% xmmin
allnames=[allnames; 'xmmin'];
eng='minimum x co-ordinates for the output model, v.out (defaults to xmin). Note: xmin and xmax determine limits in x direction. (ARG 6.8.99).';
chi='xmmin为离散化模型文件v.out中x坐标的最小值；缺省为xmin，同时xmin和xmax也是x坐标的极限。';
xmmin={'&pltpar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% xmmax
allnames=[allnames; 'xmmax'];
eng='maximum x co-ordinates for the output model, v.out (defaults to xmax). Note: xmin and xmax determine limits in x direction. (ARG 6.8.99).';
chi='xmmin为离散化模型文件v.out中x坐标的最大值；缺省为xmax，同时xmin和xmax也是x坐标的极限。';
xmmax={'&pltpar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% plotdev
allnames=[allnames; 'plotdev'];
eng=['used to plot output to screen or file. At UBC, there are two options:',char(13,10)',...
    'plotdev=''x11 -geometry 1000x800'' plots to the screen in a box that is 1000 pixels wide by 800 pixels high',char(13,10)',...
    'or plotdev=''postlandfile xxx.ps'' plots to a postscript file named xxx.ps. (ARG 16.9.98).'];
chi='plotdev控制图形的输出方式：缺省为“x11 -geometry 1000x800”，即1000x800的屏幕；或者为“postlandfile xxx.ps”，即横版形式的名为xxx的ps文件。';
plotdev={'&pltpar','SSS',eng,chi,'x11 -geometry 1000x800',NaN,'x11 -geometry 1000x800',false,NaN}';

% frz
allnames=[allnames; 'frz'];
eng=' ';
chi=' ';
frz={'&pltpar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% xmin1d
allnames=[allnames; 'xmin1d'];
eng=' ';
chi=' ';
xmin1d={'&pltpar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% xmax1d
allnames=[allnames; 'xmax1d'];
eng=' ';
chi=' ';
xmax1d={'&pltpar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% ifd
allnames=[allnames; 'ifd'];
eng=' ';
chi=' ';
ifd={'&pltpar','III',eng,chi,NaN,NaN,NaN,false,NaN}';

% dxzmod
allnames=[allnames; 'dxzmod'];
eng=' ';
chi=' ';
dxzmod={'&pltpar','FFF',eng,chi,0,NaN,0,false,NaN}';

%% 1.1.3 array part
% modi
allnames=[allnames; 'modi'];
eng='sample these layer boundaries (counting from the top) and output them (spaced at dxmod) after the model in the output file. (ARG 6.8.99)';
chi='modi这个数组指定了要进行网格化的层界面编号（从顶部往下数）。';
modi={'&pltpar','III',eng,chi,NaN,NaN,NaN,false,NaN}';

% ibreak
allnames=[allnames; 'ibreak'];
eng=['an array corresponding to the ray groups listed in the array "ray" to split travel time-distance curves into prograde and retrograde segments when ',char(13,10)',...
    'plotting with itx=1, and to increment the integer code by one in the file tx.out when changing from a prograde to retrograde segment or vice versa if itxout=1 (default: 1).'];
chi=['ibreak是一组跟ray code对应的开关，当ibreak为缺省值1且itx=1时，该组射线计算的走时曲线在绘制时会被拆分为两段，分别为从源发出的前进段（prograde）和回到接收点的',char(13,10)',...
    '返回段（retrograde）；如果同时定义了itxout=1，当从prograde前进段变为retrograde返回段，或者从返回段变为前进段时，在tx.out中的phase编号会自动加1。'];
ibreak={'&pltpar','III',eng,chi,1,NaN,1,false,[0 1]}';

% mcol
allnames=[allnames; 'mcol'];
eng=['an array specifying the colours of the model: the layer boundaries are mcol(1), the vertical boundaries are mcol(2),',char(13,10)',...
    'the floating reflectors are mcol(3), the smooth layer boundaries are mcol(4), and the velocity values are mcol(5) (default: 1, 1, 1, 1, 1).'];
chi=['mcol是个5个元素的数组，定义模型的颜色，依次为层界面、四边形块体垂直边界、浮动界面、平滑后的层界面、速度值标识。',char(13,10)',...
    '缺省值为（1, 1, 1, 1, 1），即全部是黑色。可以（根据colour数组预设的颜色值？）改变模型颜色。'];
mcol={'&pltpar','III',eng,chi,[1 1 1 1 1],NaN,[1 1 1 1 1],false,NaN}';

% colour
allnames=[allnames; 'colour'];
eng=['an array specifying the colours of the ray paths if ircol > 0 and the observed travel times if itcol > 0. ',char(13,10)',...
    '[default: 2(red), 3(green), 4(blue), 5(cyan), 6(magenta), 7(yellow), 8(orange)]'];
chi=['colour数组存放预设的颜色值（16色体系），当ircol>0时循环给射线着色，同理有itcol>0时给实际走时循环着色。预设的颜色经过验证的为：',char(13,10)',...
    '[1(black), 2(red), 3(green), 4(blue), 5(cyan), 6(magenta), 7(yellow), 8(orange), 9(深绿色), 10(淡蓝,比5的颜色稍深),',char(13,10)',...
    '11(蓝紫色), 12(比6颜色稍深), 13(紫色), 14(灰色), 15(介于5和10之间), 16(white,大于16之后全是白色)]。'];
colour={'&pltpar','III',eng,chi,[2 3 4 5 6 7 8],NaN,[2 3 4 5 6 7 8],true,NaN}';

%% 1.2 define: Axes parameters (图框坐标轴相关的控制)
%% 1.2.1 switch part
% iaxlab
allnames=[allnames; 'iaxlab'];
eng='plot axes labels (default: 1)';
chi='iaxlab开关控制是否画出坐标轴的标注：缺省值为1，即开关打开，要求画出轴标注；当设为0时为不画。 ';
iaxlab={'&axepar','III',eng,chi,1,NaN,1,false,[0 1]}';

% itrev
allnames=[allnames; 'itrev'];
eng='draw the time-distance plot with the time increasing downward: reverse time (default: 0)';
chi='以时间从上往下增加的方式绘制走时-距离图（现在的缺省值为1，开关打开；原始缺省值为0，即时间往上增加）。';
itrev={'&axepar','III',eng,chi,1,NaN,1,true,[0 1]}';

%% 1.2.2 single number part
% albht
allnames=[allnames; 'albht'];
eng='height of axes labels (mm) (default: 2.5)';
chi='albht控制坐标轴标注的字体高度，单位为mm；在屏幕上显示时，一般设为3.5较合适（缺省值为2.5适合打印）。';
albht={'&axepar','FFF',eng,chi,3.5,NaN,3.5,true,NaN}';

% xmin
allnames=[allnames; 'xmin'];
eng='minimum distance (km) of velocity model';
chi='速度模型（距离-深度坐标图）x轴（距离，Distance）的起始公里数（单位km）；根据程序运行实际情况，必须与v.in的左边界一致！';
xmin={'&axepar','FFF',eng,chi,0,NaN,0,false,NaN}';

% xmax
allnames=[allnames; 'xmax'];
eng='maximum distance (km) of velocity model';
chi='速度模型（距离-深度坐标图）x轴（距离，Distance）的结束公里数（单位km）；根据程序运行实际情况，必须与v.in的右边界一致！';
xmax={'&axepar','FFF',eng,chi,NaN,NaN,NaN,true,NaN}';

% xmm
allnames=[allnames; 'xmm'];
eng='length of distance axis (mm)';
chi='速度模型（距离-深度坐标图）x轴（距离，Distance）在图上的长度，以mm为单位。';
xmm={'&axepar','FFF',eng,chi,275,NaN,275,true,NaN}';

% xtmin
allnames=[allnames; 'xtmin'];
eng='minimum values (km) of tick marks';
chi='标注的距离最小值（单位km）。';
xtmin={'&axepar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% xtmax
allnames=[allnames; 'xtmax'];
eng='maximum values (km) of tick marks';
chi='标注的距离最大值（单位km）。';
xtmax={'&axepar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% ntickx
allnames=[allnames; 'ntickx'];
eng='number of intervals separated by tick marks along distance axis';
chi='标注的间隔数。例如：最小值1，最大值23，则ntickx=11可以实现1,3,5,...,23的标注。';
ntickx={'&axepar','III',eng,chi,1,NaN,1,false,NaN}';

% zmin
allnames=[allnames; 'zmin'];
eng='minimum depth (km) of velocity model';
chi='速度模型（距离-深度坐标图）z轴（深度坐标轴）的起始公里数（单位km；可以与v.in的顶界不一致）。';
zmin={'&axepar','FFF',eng,chi,0,NaN,0,false,NaN}';

% zmax
allnames=[allnames; 'zmax'];
eng='maximum depth (km) of velocity model';
chi='速度模型（距离-深度坐标图）z轴（深度坐标轴）的结束公里数（单位km；可以与v.in的底界不一致）。';
zmax={'&axepar','FFF',eng,chi,NaN,NaN,NaN,true,NaN}';

% zmm
allnames=[allnames; 'zmm'];
eng='length of depth axis (mm)';
chi='速度模型（距离-深度坐标图）z轴(深度坐标轴)在图上的长度，以mm为单位。';
zmm={'&axepar','FFF',eng,chi,70,NaN,70,true,NaN}';

% ztmin
allnames=[allnames; 'ztmin'];
eng='minimum values (km) of tick marks';
chi='标注的深度最小值（km）。';
ztmin={'&axepar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% ztmax
allnames=[allnames; 'ztmax'];
eng='maximum values (km) of tick marks';
chi='标注的深度最大值（km）。';
ztmax={'&axepar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% ntickz
allnames=[allnames; 'ntickz'];
eng='number of intervals separated by tick marks along depth axis';
chi='标注的深度个数。例如：最小值1.5，最大值5.5，则ntickz=4可以实现1.5, 2.5, 3.5, 4.5, 5.5的标注。';
ntickz={'&axepar','III',eng,chi,1,NaN,1,false,NaN}';

% xmint
allnames=[allnames; 'xmint'];
eng='minimum distance (km) of time-distance plot';
chi='走时-距离图上x轴（距离）的最小值（单位km；可以与v.in的左边界不一致）。';
xmint={'&axepar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% xmaxt
allnames=[allnames; 'xmaxt'];
eng='maximum distance (km) of time-distance plot';
chi='走时-距离图上x轴（距离）的最大值（单位km；可以与v.in的右边界不一致）。';
xmaxt={'&axepar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% xmmt
allnames=[allnames; 'xmmt'];
eng='length of distance axis (mm)';
chi='走时-距离图上x轴（距离）在图上的长度（单位mm）。';
xmmt={'&axepar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% xtmint
allnames=[allnames; 'xtmint'];
eng='minimum values (km) of tick marks';
chi='走时-距离图上x轴（距离）标注的最小值。';
xtmint={'&axepar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% xtmaxt
allnames=[allnames; 'xtmaxt'];
eng='maximum values (km) of tick marks';
chi='走时-距离图上x轴（距离）标注的最大值。';
xtmaxt={'&axepar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% ntckxt
allnames=[allnames; 'ntckxt'];
eng='number of intervals separated by tick marks along distance axis';
chi='走时-距离图上x轴（距离）标注的间隔数。例如：最小值1，最大值23，则ntickx=11可以实现1,3,5, ... ,23的标注。';
ntckxt={'&axepar','III',eng,chi,NaN,NaN,NaN,false,NaN}';

% tmin
allnames=[allnames; 'tmin'];
eng='minimum time (s) of time-distance plot';
chi='走时-距离图中要画出的最小时间（y轴；单位：秒s）。';
tmin={'&axepar','FFF',eng,chi,0,NaN,0,false,NaN}';

% tmax
allnames=[allnames; 'tmax'];
eng='maximum time (s) of time-distance plot';
chi='走时-距离图中要画出的最大时间（y轴）。';
tmax={'&axepar','FFF',eng,chi,NaN,NaN,NaN,true,NaN}';

% tmm
allnames=[allnames; 'tmm'];
eng='length of time axis (mm)';
chi='画出的走时-距离图中的t轴(走时坐标轴)在图上的长度，以mm为单位。';
tmm={'&axepar','FFF',eng,chi,100,NaN,100,true,NaN}';

% ttmin
allnames=[allnames; 'ttmin'];
eng='minimum values (s) of tick marks';
chi='标注的最小时间值（单位：秒s）。';
ttmin={'&axepar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% ttmax
allnames=[allnames; 'ttmax'];
eng='maximum values (s) of tick marks';
chi='标注的最大时间值（单位：秒s）。';
ttmax={'&axepar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% ntickt
allnames=[allnames; 'ntickt'];
eng='number of intervals separated by tick marks along time axis';
chi='标注的时间间隔数';
ntickt={'&axepar','III',eng,chi,1,NaN,1,false,NaN}';

% orig
allnames=[allnames; 'orig'];
eng='lower left origin of plot is (orig,orig) mm (default: 12.5)';
chi='orig为整图的左下角坐标(orig,orig)，单位为mm，现在的缺省值改为15（原始的缺省值为12.5）。';
orig={'&axepar','FFF',eng,chi,15,NaN,15,true,NaN}';

% sep
allnames=[allnames; 'sep'];
eng='separation (mm) between the model and travel time diagrams if isep=0 or 2 (default: 7.5)';
chi='sep为模型图和走时图画在一起时，两幅图上下间隔的距离（前提要求是参数isep=0 or 2），单位为mm，现在的缺省值改为10（原始的缺省值为7.5）。';
sep={'&axepar','FFF',eng,chi,10,NaN,10,true,NaN}';

%% 1.2.3 array part
% ndecix
allnames=[allnames; 'ndecix'];
eng=['number of digits after decimal in distance axis annotation; -1 for integer annotation ',char(13,10)',...
    '(defaults: 0, none, 250; values for xtmin, xtmax, ntickx and ndecix depend on values of xmin and xmax)'];
chi='速度模型（深度-距离图）上x轴（距离）标注时需要保留的小数点位数。目前不是非常清楚用法，保持缺省值就好，因此不提供修改功能，也不输出到r.in中！';
ndecix={'&axepar','III',eng,chi,[0 NaN 250],NaN,[0 NaN 250],false,NaN}';

% ndeciz
allnames=[allnames; 'ndeciz'];
eng=['number of digits after decimal in depth axis annotation; -1 for integer annotation',char(13,10)',...
    '(defaults: 0, 50, 75; values for ztmin, ztmax, ntickz and ndeciz depend on values of zmin and zmax)'];
chi='速度模型（深度-距离图）上z轴（深度）标注时需要保留的小数点位数。目前不是非常清楚用法，保持缺省值就好，因此不提供修改功能，也不输出到r.in中！';
ndeciz={'&axepar','III',eng,chi,[0 50 75],NaN,[0 50 75],false,NaN}';

% ndecxt
allnames=[allnames; 'ndecxt'];
eng=['number of digits after decimal in distance axis annotation; -1 for integer annotation ',char(13,10)',...
    '(defaults: xmin, xmax, xmm; values for xtmint, xtmaxt, ntckxt and ndecxt depend on values of xmint and xmaxt)'];
chi='走时-距离上x轴（距离）标注时需要保留的小数点位数。目前不是非常清楚用法，保持缺省值就好，因此不提供修改功能，也不输出到r.in中！';
ndecxt={'&axepar','III',eng,chi,[0 NaN 250],NaN,[0 NaN 250],false,NaN}';

% ndecit
allnames=[allnames; 'ndecit'];
eng=['number of digits after decimal in time axis annotation; -1 for integer annotation ',char(13,10)',...
    '(defaults: 0, 10, 75; values for ttmin, ttmax, ntickt and ndecit depend on values of tmin and tmax)'];
chi='走时-距离上y轴（时间）标注时需要保留的小数点位数。目前不是非常清楚用法，保持缺省值就好，因此不提供修改功能，也不输出到r.in中！';
ndecit={'&axepar','III',eng,chi,[0 10 75],NaN,[0 10 75],false,NaN}';

%% 1.3 define: Ray tracing parameters (射线追踪的控制)
%% 1.3.1 switch part
% iraysl
allnames=[allnames; 'iraysl'];
eng='use the array irayt to select which ray groups listed in the array ray are to be traced for a particular shot point (default: 0)';
chi='开关打开时（iraysl=1），使用数组irayt来选择哪些ray中的事件将要对某个特定的shot point进行射线追踪；缺省值为0（关闭）。';
iraysl={'&trapar','III',eng,chi,0,NaN,0,false,[0 1]}';

% ifast
allnames=[allnames; 'ifast'];
eng=['use a Runge-Kutta routine without error control to solve the ray tracing equations and a look-up/interpolation routine to evaluate certain trigonometric functions; ',char(13,10)',...
    'with ifast=0, a Runge-Kutta method with error control and the intrinsic trigonometric functions are used. ',char(13,10)',...
    'Using ifast=1 is about 30-40% faster and provides essentially the same accuracy as ifast=0 (default: 1)...',char(13,10)',...
    'Note: ifast=1 is intended to be used for all routine modelling and ifast=0 only to test a final model or if ifast=1 obviously fails'];
chi=' ';
ifast={'&trapar','III',eng,chi,1,NaN,1,false,[0 1]}';

% i2pt
allnames=[allnames; 'i2pt'];
eng=['perform two-point ray tracing, i.e., determine the ray take- off angles that connect sources and observed receiver locations within each ray group;',char(13,10)',...
    'the receiver locations are obtained from the file tx.in for those picks that have the same integer code as specified in the array ivray for the ray group; ',char(13,10)',...
    'if i2pt=2, only rays which reflect off the appropriate floating reflector specified in the array frbnd (if frbnd>0) are traced (default: 0)  '];
chi=['当为0时，射线完全由起飞角度决定，与接收器无关，因此，有效射线的数目=nray，即这是一种正演；当i2pt=1时，只有从震源出发、真正到达接收器的射线才是有效射线，',char(13,10)',...
    '因此，nray只要足够大即可（比如每个shot的有效射线数不再变化，或者总的搜索射线数不再变化），这是反演的方式，射线数目跟tx.in有关，不完全由nray决定',char(13,10)',...
    '控制是否采取含有sources and observed receiver 的two-point ray tracing表现方式。',char(13,10)',...
    'i. =0：不用 two-point ray tracing 的方式。',char(13,10)',...
    'ii. =1：用 two-point ray tracing 的方式。'];
i2pt={'&trapar','III',eng,chi,1,NaN,1,true,[0 1]}';

% isrch
allnames=[allnames; 'isrch'];
eng=['search again for the take-off angles of a ray group if the same ray code is listed more than once for the same shot in the array ray; ',char(13,10)',...
    'isrch=1 must be used if the take-off angles of two or more ray groups with the same ray code are different '...
    'because of multiple reflections and/or conversions specified by nrbnd, rbnd, ncbnd,and cbnd (default: 0)'];
chi=['此开关保证程序能够对重复的ray code再次进行起飞角度的搜索，当ray中有相同的ray code重复出现时，必须将它设为1'...
    '（例如在nrbnd, rbnd, ncbnd,and cbnd中指定了多次波和转换波的情况）；缺省值为0。 '];
isrch={'&trapar','III',eng,chi,0,NaN,0,false,[0 1]}';

% istop
allnames=[allnames; 'istop'];
eng=['stop tracing any ray which reflects off a boundary not specified in the arrays ray or rbnd; ',char(13,10)',...
    'if istop=2, rays are also stopped if they enter a layer deeper than that specified by the ray code in the array ray,',char(13,10)',...
    'i.e., the layer number is greater than L and the ray code is L.n, where n=0, 1, 2, or 3 (default: 1)'];
chi=' ';
istop={'&trapar','III',eng,chi,1,NaN,1,false,[1 2]}';

% idiff
allnames=[allnames; 'idiff'];
eng=['continue to trace headwaves along a boundary even if the velocity contrast across the interface is no longer positive, ',char(13,10)',...
    'in which case headwaves emerge parallel to the boundary (idiff=1); ',char(13,10)',...
    'if idiff=2, initiate a headwave ray group even if there is no critical point (or it is not found) ',char(13,10)',...
    'to model diffractions along the top of a low-velocity layer (default: 0)'];
chi=['idiff开关控制是否对下述两种特殊情况进行追踪：（1）idiff=1时会继续沿着界面追踪首波，即使界面下方的速度小于界面上方，',char(13,10)',...
    '此时首波是平行于界面发出来的；（2）idiff=2时会强制启动首波的射线组，即使全反射关键点不存在（或者没有找到），从而可以模拟',char(13,10)',...
    '沿着低速层顶面传播的折射。  idiff开关的缺省值为0，即不对情况（1）和（2）进行首波追踪。'];
idiff={'&trapar','III',eng,chi,0,NaN,0,false,[0 1 2]}';

% ibsmth
allnames=[allnames; 'ibsmth'];
eng=['apply a simulation of smooth layer boundaries (1) or apply the simulation and plot the smoothed boundaries (2);',char(13,10)',...
    'ibsmth=2 has no effect if isep>1 (default: 0)'];
chi=['ibsmth开关控制是否模拟光滑层界面以及方式：（1）缺省值目前设为1（原始缺省值为0）表示用模拟的光滑层界面进行射线追踪技术；',char(13,10)',...
    '（2）设为2时不但用光滑界面进行追踪，而且会把光滑后的界面给画出来，但要注意，当isep>1时，设为2并不会产生效果；',char(13,10)',...
    '（3）设为0时显然就不进行光滑模拟。'];
ibsmth={'&trapar','III',eng,chi,1,NaN,1,true,[0 1 2]}';

% imodf
allnames=[allnames; 'imodf'];
eng='use the velocity model in the file v.in instead of the model in part (5) of the file r.in (default: 0)';
chi=' ';
imodf={'&trapar','III',eng,chi,1,NaN,1,true,[0 1]}';

%% 1.3.2 single number part
% n2pt
allnames=[allnames; 'n2pt'];
eng=['maximum number of iterations during two-point ray tracing (i2pt>0); ',char(13,10)',...
    'this is the maximum number of rays traced for each receiver ',char(13,10)',...
    'to determine the take-off angle of the ray that connects the source and receiver (default: 5)'];
chi=' ';
n2pt={'&trapar','III',eng,chi,5,NaN,5,false,NaN}';

% x2pt
allnames=[allnames; 'x2pt'];
eng=['distance tolerance (km) for two-point ray tracing; ',char(13,10)',...
    'less than n2pt rays will be traced for a particular receiver ',char(13,10)',...
    'if a ray end point is within x2pt of the receiver location (default: (xmax-xmin)/2000)'];
chi=' ';
x2pt={'&trapar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% crit
allnames=[allnames; 'crit'];
eng=['head waves are generated if a down-going ray in the search mode has an angle of incidence at the bottom of the Lth layer',char(13,10)',...
    'within crit degrees of the critical angle when ray=L.3 (default: 1)'];
chi='crit定义了首波发生（ray=L.3）的关键角度：在搜索模式下，如果一条向下的射线在L层底界面的入射角在此关键角度以内，那么这条射线就会产生相应的首波。';
crit={'&trapar','FFF',eng,chi,1,NaN,1,false,NaN}';

% hws
allnames=[allnames; 'hws'];
eng='the spacing (km) of rays emerging upward from the bottom of the Lth layer when ray=L.3 (default: (xmax-xmin)/25)';
chi='hws定义了首波射线（ray code为L.3）在第L层的底界面上滑行结束、向上返回时这些射线的搜索宽度（单位km，缺省值为(xmax-xmin)/25）。';
hws={'&trapar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% nhary
allnames=[allnames; 'nhary'];
eng='maximum number of rays traced for a head wave ray group (default: pnrayf)';
chi='nhary定义了用来追踪一个首波的最大射线数，缺省值为pnrayf的值。';
nhary={'&trapar','III',eng,chi,NaN,NaN,NaN,false,NaN}';

% aamin
allnames=[allnames; 'aamin'];
eng='minimum take-off angle (degrees) for the refracted ray group in the first layer (default: 5)';
chi=' ';
aamin={'&trapar','FFF',eng,chi,0,NaN,0,true,NaN}';

% aamax
allnames=[allnames; 'aamax'];
eng='maximum take-off angle (degrees) for reflected ray groups specified as L.2 in the array ray (default: 85)';
chi=' ';
aamax={'&trapar','FFF',eng,chi,90,NaN,90,true,NaN}';

% stol
allnames=[allnames; 'stol'];
eng=['if a ray traced in the search mode is of the correct type and its end point is within stol (km) of the previous ray traced in the search mode, ',char(13,10)',...
    'then the search for that ray type is terminated;',char(13,10)',...
    'a value of stol=0 will ensure that nsmax rays are always traced in the search mode (default: (xmax-xmin)/3500)'];
chi=' ';
stol={'&trapar','FFF',eng,chi,NaN,NaN,NaN,true,NaN}';

% xsmax
allnames=[allnames; 'xsmax'];
eng=['for reflected ray groups specified as L.2 in the array ray, determine the minimum take-off angle using the search mode ',char(13,10)',...
    'so that the maximum range for this ray group is xsmax (km) if iturn=0 or the maximum offset of the reflection point is xsmax/2 (km) if iturn=1;',char(13,10)',...
    'for head wave ray groups specified as L.3 in the array ray, the maximum offset of the point of emergence from the head wave boundary is xsmax (km);',char(13,10)',...
    'xsmax=0 will ensure that the take-off angle of the reflected ray which grazes off the bottom of the Lth layer ',char(13,10)',...
    'is determined and head waves are traced along the Lth boundary until the edge of the model is reached (default: 0.0)'];
chi=' ';
xsmax={'&trapar','FFF',eng,chi,0.0,NaN,0.0,false,NaN}';

% npbnd
allnames=[allnames; 'npbnd'];
eng='number of points at which each layer boundary is uniformly sampled for smoothing if ibsmth=1 or 2 (default: 100)';
chi='npbnd定义对每一层的界面进行光滑时（ibsmth=1 or 2时）的均匀采样点数（缺省值现在设为250，原始缺省值为100）。';
npbnd={'&trapar','III',eng,chi,250,NaN,250,false,NaN}';

% nbsmth
allnames=[allnames; 'nbsmth'];
eng='number of applications of a three-point averaging filter to each layer boundary if ibsmth=1 or 2 (default: 10)';
chi='nbsmth定义对每一层的界面进行光滑时（ibsmth=1 or 2时）所实施的三点平均光滑的次数（缺省值现在设为100，原始缺省值为10）。';
nbsmth={'&trapar','III',eng,chi,100,NaN,100,false,NaN}';

% xminns
allnames=[allnames; 'xminns'];
eng=['minimum model distance over which the layer boundaries listed in the array insmth are not to be smoothed using ibsmth=1 or 2 ',char(13,10)',...
    '(defaults: smooth boundaries between xmin and xmax)'];
chi='xminns定义某层的界面不进行光滑处理的最小距离，缺省值即是模型的左端xmin。';
xminns={'&trapar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% xmaxns
allnames=[allnames; 'xmaxns'];
eng=['maximum model distance over which the layer boundaries listed in the array insmth are not to be smoothed using ibsmth=1 or 2 ',char(13,10)',...
    '(defaults: smooth boundaries between xmin and xmax)'];
chi='xmaxns定义某层的界面不进行光滑处理的最大距离，缺省值即是模型的右端xmax。';
xmaxns={'&trapar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% step
allnames=[allnames; 'step'];
eng=['controls the ray step length in the solution of the ray tracing equations according to the relationship',char(13,10)',...
    'step length (km) = step*v/(|vx|+|vz|)',char(13,10)',...
    'where v is velocity and vx and vz are its partial derivatives with respect to x and z (default: 0.05)'];
chi=' ';
step={'&trapar','FFF',eng,chi,0.05,NaN,0.05,false,NaN}';

% smin
allnames=[allnames; 'smin'];
eng='minimum allowable ray step length (km) (defaults: (xmax-xmin)/4500)';
chi=' ';
smin={'&trapar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% smax
allnames=[allnames; 'smax'];
eng='maximum allowable ray step length (km) (defaults: (xmax-xmin)/15)';
chi=' ';
smax={'&trapar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% nsmin
allnames=[allnames; 'nsmin'];
eng=' ';
chi=' ';
nsmin={'&trapar','III',eng,chi,NaN,NaN,NaN,false,NaN}';

% ntan
allnames=[allnames; 'ntan'];
eng=' ';
chi=' ';
ntan={'&trapar','III',eng,chi,NaN,NaN,NaN,false,NaN}';

%% 1.3.3 array part
% ishot
allnames=[allnames; 'ishot'];
eng=['an array specifying the directions rays are to be traced from the shot points listed in the arrays xshot and zshot; the following code is used:',char(13,10)',...
	'(1) 0 - no rays are traced,',char(13,10)',...
	'(2) -1 - rays are traced to the left only,',char(13,10)',...
	'(3) 1 - rays are traced to the right only,',char(13,10)',...
	'(4) 2 - rays are traced to the left and right,',char(13,10)',...
	'(default: 0)'];
chi=['地层内每一 shot points 的射线表现与否。',char(13,10)',...
    'i. =0：no。',char(13,10)',...
    'ii. = -1：仅表现左方。',char(13,10)',...
    'iii. =1：仅表现右方。',char(13,10)',...
    'iv. =2：从左方至右方均表现出来。',char(13,10)',...
    '缺省为0，即不追踪，因此，只有将对应的shot设为非0，才能对该shot进行追踪；',char(13,10)',...
    '这个可以用来指定xshot和zshot中哪些shot要进行追踪（可以只改变前面一部分，则后面剩余的就是0）'];
ishot={'&trapar','III',eng,chi,2,NaN,2,true,[-1 0 1 2]}';

% irayt
allnames=[allnames; 'irayt'];
eng=['an array selecting those ray groups listed in the array “ray” which are active for a particular shot point listed in the arrays “xshot”and “zshot”. ',char(13,10)',...
    'If there are n ray groups listed in the array ray, ',char(13,10)',...
    'then the jth ray group for the ith shot is referred to in the (2n(i-1)+j)th element of irayt for rays traced to the left , ',char(13,10)',...
    'and in the (2n(i-1)+n+j)th element of irayt for rays traced to the right. ',char(13,10)',...
    'You must specify values of irayt for each group and for each direction regardless of the values of ishot (default: 1) '];
chi=['对某个shot是否追踪某组ray的开关（缺省为1），排列顺序如下：首先循环shot，然后是该shot往左的ray，然后是往右的ray，然后开始下一个shot，即',char(13,10)',...
    'Shot 1往左的ray 1，往左的ray 2，…，往左的ray n，往右的ray 1，…，往右的ray n，shot 2往左的ray 1，…，shot j…',char(13,10)',...
    '一般说来，由于缺省是1，因此只需要把不需要追踪的部分设为0，注意：SCS部分也需要2个方向都追踪才能保证射线有效'];
irayt={'&trapar','III',eng,chi,1,NaN,1,false,[0 1]}';

% xshot
allnames=[allnames; 'xshot'];
eng='an array containing the x-coordinates (km) of the shot points (default: 0.0)';
chi=' ';
xshot={'&trapar','FFF',eng,chi,0.0,NaN,0.0,true,NaN}';

% zshot
allnames=[allnames; 'zshot'];
eng='an array containing the z-coordinates (km) of the shot points (default: a very small distance below the model surface)';
chi=['可以为负值，因为模型的顶可以高出海平面。我的理解，如果不定义zshot，',char(13,10)',...
    '那么实际上缺省的值应该是从第一个界面（即层1的顶）向下的一个很小的距离（比如0.02 km，极限为0.00051 km），而不是从代表画图范围的那个矩形框的顶部开始算'];
zshot={'&trapar','FFF',eng,chi,0.001,NaN,0.001,false,NaN}';

% ray
allnames=[allnames; 'ray'];
eng=['an array containing the ray groups to be traced; the following code is used: ',char(13,10)',...
    '(1) L.1 - rays which refract (turn) in the Lth layer ',char(13,10)',...
    '(2) L.2 - rays which reflect off the bottom of the Lth layer',char(13,10)',...
    '(3) L.3 - rays which travel as head waves along the bottom of the Lth layer ',char(13,10)',...
    '(4) L.0 - ray take-off angles supplied by the user in the arrays amin and amax'];
chi=['这个概念跟某层中的某种类型波相对应;ray group=ray code;phase=tx.in中每行最后的数字',char(13,10)',...
    '控制表现在地层(L layer)中折射或反射的射线轨迹。',char(13,10)',...
    'i. =L.1：在 L 地层中折射的射线轨迹。',char(13,10)',...
    'ii. =L.2：在 L 地层中反射的射线轨迹。',char(13,10)',...
    'iii. =L.3：在 L 地层中首波的射线轨迹。',char(13,10)',...
    '1.1→ no，1.2→在速度均为1.5km/sec 的水层中的反射轨迹 (即直达波)，2.1→在第二层中射线折射的运动轨迹，2.2→在第二层中射线折射的运动轨迹……'];
ray={'&trapar','FFF',eng,chi,NaN,NaN,NaN,true,NaN}';

% iturn
allnames=[allnames; 'iturn'];
eng=['an array corresponding to the ray groups listed in the array "ray" to trace rays only to their turning or reflection point in the search mode; '...
    'if a refracted or head wave ray group is to contain a reflection(s) before it turns (specified using nrbnd and rbnd), then iturn=0 must be used (default: 1)'];
chi='与ray code（数组“ray”）一一对应的开关，控制是否需要考虑多次波。当为缺省值1时，仅搜索最简单的primary wave（初至波）；当需要考虑包括层间反射等多次波的情况时，必须设为0 。';
iturn={'&trapar','III',eng,chi,1,NaN,1,false,[0 1]}';

% insmth
allnames=[allnames; 'insmth'];
eng=['an array listing the layer boundaries for which the smooth layer boundary simulation is not to be applied, ',char(13,10)',...
    'or only applied outside the model distances xminns and xmaxns, when ibsmth=1 or 2, (default: 0)'];
chi='insmth是个整型数组，用来存放不进行光滑模拟的层界面编号，或者配合xminns和xmaxns，使得光滑仅在这些层的[xminns,xmaxns]之外的部分才进行。缺省值为0，即表示所有的层都会被光滑（当ibsmth=1 or 2时）。';
insmth={'&trapar','III',eng,chi,0,NaN,0,false,[0 1 2]}';

% nray
allnames=[allnames; 'nray'];
eng=['an array containing the number of rays to be traced for each ray group in the array ray (default: 10; ',char(13,10)',...
    'however, the default is the first element of nray for all ray groups if only one value is specified)'];
chi=' ';
nray={'&trapar','III',eng,chi,100,NaN,100,true,NaN}';

% space
allnames=[allnames; 'space'];
eng=['an array which determines the spacing of take-off angles between the minimum and maximum values for each ray group in the array ray. ',char(13,10)',...
    'For space=1, the take-off angles will be equally spaced; for space > 1, the take-off angles will be concentrated near the minimum value;',char(13,10)',...
    'for 0 < space < 1, the take-off angles will be concentrated near the maximum value ',char(13,10)',...
    '(default: 1; however, space=2 for a reflected ray group if specified as L.2 in the array ray)'];
chi='测试应该是 0 < space < 1适合海面到海底的反射，数值越小，越集中';
space={'&trapar','FFF',eng,chi,1,NaN,NaN,true,NaN}';

% amin
allnames=[allnames; 'amin'];
eng=['arrays containing minimum take-off angles (degrees); measured from the horizontal, ',char(13,10)',...
    'positive downward and negative upward (for rays traveling left to right or right to left); used for ray groups specified by ray=1.0'];
chi=' ';
amin={'&trapar','FFF',eng,chi,0,NaN,0,false,NaN}';

% amax
allnames=[allnames; 'amax'];
eng=['arrays containing maximum take-off angles (degrees); measured from the horizontal, ',char(13,10)',...
    'positive downward and negative upward (for rays traveling left to right or right to left); used for ray groups specified by ray=1.0'];
chi=' ';
amax={'&trapar','FFF',eng,chi,-90,NaN,-90,false,NaN}';

% nsmax
allnames=[allnames; 'nsmax'];
eng=['an array containing the maximum number of rays traced when searching for the take-off angles of the ray groups in the array ray ',char(13,10)',...
    '(default: 10; however, the default is the first element of nsmax for all ray groups if only one value is specified)'];
chi=' ';
nsmax={'&trapar','III',eng,chi,50,NaN,50,true,NaN}';

% nrbnd
allnames=[allnames; 'nrbnd'];
eng='an array containing the number of reflecting boundaries for each ray group in the array "ray" (default: 0).';
chi='对应的ray code（ray group）所包含的多次波个数（反射界面个数）。缺省值为0，即没有多次波。 ';
nrbnd={'&trapar','III',eng,chi,0,NaN,0,false,NaN}';

% rbnd
allnames=[allnames; 'rbnd'];
eng=['an array containing the reflecting boundaries specified in the array "nrbnd"; the following code is used:',char(13,10)',...
    '(1) L - ray traveling downward is reflected upward off the bottom of the Lth layer;',char(13,10)',...
    '(2) -L - ray traveling upward is reflected downward off the top of the Lth layer.'];
chi=['当对应的nrbnd中所定义的多次波个数非0时，具体发生多次波反射的界面，例如nrbnd=0,0,1,2，rbnd=-1,2,4，则nrbnd前面的两个0表示没有多次反射，故而在rbnd中也没有对应的值，'...
    '而rbnd的-1对应nrbnd的1，rbnd的2和4对应nrbnd的2。注意：反射界面为正值L时，表示自上而下的射线在L层的底面被向上反射；反正，为负值-L时，则是向上的射线在L层的顶面被向下反射。'];
rbnd={'&trapar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% ncbnd
allnames=[allnames; 'ncbnd'];
eng='an array containing the number of converting (P to S or S to P) boundaries for each ray group in the array "ray" (default: 0).';
chi='与ray对应的数组，用于定义某个ray code包含的转换波个数。缺省值为0，即没有转换波；对于OBS的转换横波情况，需要把OBS当作源，因此从OBS出来就是横波，然后再转换为纵波回到水面，所以至少有2个转换波。 ';
ncbnd={'&trapar','III',eng,chi,0,NaN,0,false,NaN}';

% cbnd
allnames=[allnames; 'cbnd'];
eng=['an array containing the converting boundaries specified in the array "ncbnd"; the following code is used:',char(13,10)',...
    '(1) i - ray will convert from its present wave type (P or S) at the ith layer boundary （top or bottom) encountered;',char(13,10)',...
    '(2) 0 - ray will leave the source as an S-wave.'];
chi=['跟ncbnd中定义的转换波次数（非0值）对应的发生转换的层号；层号为0表示从源离开时就是横波。例如 ncbnd=0,0,1,2，cbnd=0,0,4 中，cbnd中的第一个0对应ncbnd的1,表示从源离开就是横波，'...
    '而cbnd中的第二个0和4对应ncbnd的2（适用于OBS的2次转换），表示从OBS离开就是横波，往下穿透，然后在层4（反射为层4的底界面，折射和首波在层4的顶界面）转换为纵波，因此最后能够通过海水回到海面的炮点。'];
cbnd={'&trapar','III',eng,chi,NaN,NaN,NaN,false,NaN}';

% frbnd
allnames=[allnames; 'frbnd'];
eng=['an array containing the floating reflecting boundaries for each ray group in the array ray;',char(13,10)',...
    'the values of frbnd correspond to the order in which the reflectors are listed in the file f.in (default: 0)'];
chi=' ';
frbnd={'&trapar','III',eng,chi,0,NaN,0,false,NaN}';

% pois
allnames=[allnames; 'pois'];
eng=['an array containing the value of Poisson''s ratio for each model layer; ',...
    'a value of 0.5 signifies a water layer with a corresponding S-wave velocity of zero ',...
    '(default: 0.25; however, the default is the first element of pois for all layers if only one value is specified).'];
chi=' 定义模型每层的泊松比；如果只有1个值，则这个泊松比会被用于所有层（缺省值为0.25）。如果泊松比设为0.5，则意味着该层为水，因此横波速度为0。';
pois={'&trapar','FFF',eng,chi,0.25,NaN,0.25,false,NaN}';

% poisl
allnames=[allnames; 'poisl'];
eng='arrays specifying the layers of model trapezoids within which Poisson''s ratio is modified over that given by "pois" using the array "poisbl".';
chi='对模型中自动划分出的四边形块（通过xrayinvr图形记录要调节的块的层号和从左到右的编号）进行泊松比改变：poisb指定块号，poisl指定该块对应的层号，poisbl为泊松比值';
poisl={'&trapar','III',eng,chi,NaN,NaN,NaN,false,NaN}';

% poisb
allnames=[allnames; 'poisb'];
eng=['arrays specifying the block numbers of model trapezoids within which Poisson''s ratio is modified over that given by "pois" using the array "poisbl"; ',...
    'for poisb, the trapezoids with a layer are numbered from left to right.'];
chi='对模型中自动划分出的四边形块（通过xrayinvr图形记录要调节的块的层号和从左到右的编号）进行泊松比改变：poisb指定块号，poisl指定该块对应的层号，poisbl为泊松比值';
poisb={'&trapar','III',eng,chi,NaN,NaN,NaN,false,NaN}';

% poisbl
allnames=[allnames; 'poisbl'];
eng='an array containing the value of Poisson''s ratio for the model trapezoids specified in the arrays "poisl" and "poisb" overriding the values assigned using the array "pois".';
chi=['对模型中自动划分出的四边形块（把&pltpar部分的ibnd设为1（缺省值），即可以在xrayinvr画出的模型中看到每层从左到右被竖线隔开的四边形块）进行指定泊松比的修改，从而取代pois定义的每层泊松比以达到微调的目的。',char(13,10)',...
    '使用时，[poisl poisb poisbl]这三个数组的值必须一一对应，即首先用poisl指定层号，然后是该层的某个块号poisb（从左到右数），最后是该块的泊松比值poisbl。'];
poisbl={'&trapar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

%% 1.4 define: Inversion parameters (射线反演的控制)
%% 1.4.1 switch part
% invr
allnames=[allnames; 'invr'];
eng='calculate partial derivatives of the selected model parameters and write these to the file i.out (default: 0)';
chi=['invr开关控制是否要为后续的dmplstsqr反演计算指定参数的偏微分（在v.in中设置哪些参数需要反演），这些偏微分值将输出到i.out文件中。',char(13,10)',...
    'invr必须设为1才能计算chi-squared值；但设为0时仍然可以计算射线，仍然可以同时将拾取的走时画出来进行两者的比较。',char(13,10)',...
    '现在缺省值已经改为1（原始缺省值为0）。'];
invr={'&invpar','III',eng,chi,1,NaN,1,true,[0 1]}';

%% 1.4.2 single number part
% ximax
allnames=[allnames; 'ximax'];
eng=['the maximum allowable distance (km) between the nearest ray end point and an observed seismogram location for one of the rays ',char(13,10)',...
    ' used to interpolate the partial derivatives and travel time at that observed seismogram location (default: (xmax-xmin)/20).'];
chi=['ximax是射线终点与观察到的地震图像位置（接收站）之间的最大允许距离（单位km，缺省值为模型长度的20分之一：(xmax-xmin)/20）。',char(13,10)',...
    '当使用一组射线对偏微分和在那个观察到的地震图像位置处的走时进行差值时，这些射线就会受到ximax的约束。'];
ximax={'&invpar','FFF',eng,chi,NaN,NaN,NaN,false,NaN}';

% ttunc
allnames=[allnames; 'ttunc'];
eng='uncertainty of the calculated travel times (s) written to the file tx.out if itxout>0 (default: 0.01).';
chi=['ttunc为指定的计算走时的不确定性幅度（单位为s，缺省值为0.01）；当itxout>0时，这个值会输出到tx.out文件中，',char(13,10)',...
    '这样就可以同样以竖条的形式在图上画出来。'];
ttunc={'&invpar','FFF',eng,chi,0.01,NaN,0.01,false,NaN}';

% bndunc
allnames=[allnames; 'bndunc'];
eng='estimated uncertainty of the depth of boundary nodes (km) written to the file i.out (defaults: 0.1).';
chi=['bndunc为反演时估计的界面节点的深度不确定性幅度（单位为km，缺省值为0.1），将写入i.out的开头部分；',char(13,10)',...
    '当d.in中对应的bndunc参数设为0时，就会调用i.out中的值。'];
bndunc={'&invpar','FFF',eng,chi,0.1,NaN,0.1,false,NaN}';

% velunc
allnames=[allnames; 'velunc'];
eng='estimated uncertainty of velocities (km/s) written to the file i.out (defaults: 0.1).';
chi=['velunc为反演时估计的速度不确定性幅度（单位为km/s，缺省值为0.1），将写入i.out的开头部分；',char(13,10)',...
    '当d.in中对应的velunc参数设为0时，就会调用i.out中的值。'];
velunc={'&invpar','FFF',eng,chi,0.1,NaN,0.1,false,NaN}';

%% 1.4.3 array part（第5项为array中每个元素的缺省值）
% ivray
allnames=[allnames; 'ivray'];
eng=['an array of non-zero integers corresponding to the ray groups listed in the array ray used to identify the type of arrival in the file tx.out if itxout=2 or 3, ',char(13,10)',...
    'and to allow for the appropriate comparison with the observed travel times in the file tx.in if invr=1 or i2pt>0.'];
chi=['ivray是一个整数数组，用来指定tx.in中哪些走时（phase）要用到，因此该整数数组的值必须是tx.in中每行最后的编号（部分或者全部）。',char(13,10)',...
    '当invr=0（不反演，只正演）且i2pt=0（不要求拾取时间与计算时间配对时），ivray的顺序可以是任意的；',char(13,10)',...
    '只要不是上述情况，就要求ivray跟ray一一配对（即某个走时（phase）是某个ray code的结果。',char(13,10)',...
    '比如，对于拾取的某组编号为1的走时，不清楚是否对应ray code的1.2还是2.2时，可以重复该组走时分别对应1.2和2.2，',char(13,10)',...
    '然后通过后续计算和画图进行分析判断，在r.in中的表现形式如下：',char(13,10)',...
    'ray=1.2, 2.2,',    'ivray=1, 1,'];
ivray={'&invpar','III',eng,chi,1,NaN,1,true,NaN}';

% default of nhary
pnrayf=1000;
if isnan(nhary{7});
    nhary([5,7])={pnrayf};
end

%% 2 initial static variables

[loadpath,loadname,savepath,savename,fullload,fullsave]=deal('');

% load last run information
if exist('history_rin.mat','file');
    s=load ('history_rin.mat');
    loadpath=s.loadpath;
    loadname=s.loadname;
    fullload=s.fullload;
    savepath=s.savepath;
    savename=s.savename;
    fullsave=s.fullsave;
end
if isempty(fullload);
    loadprevious='off';
else
    loadprevious='on';
end
if isempty(fullsave);
    saveprevious='off';
else
    saveprevious='on';
end

sectname='';
pbhgroup=[]; % 用于存放所有的pushbutton的句柄
[col_plt data_plt col_axe data_axe col_tra data_tra col_inv data_inv]=deal({}); % 用于存放表tbh
fun_make_table;
parameter_modified=false;
outlabel='\fontsize{12}\bf\color{red} 【输出到r.in】\rm\color{black}';


%% 3 --------------- UI ---------------------
if ishandle(2);
    reditorh = 2;
    set(reditorh,'Visible','on');
else
    reditorh = figure(2);
    set(reditorh,'Visible','off','Name','r.in editor','MenuBar','none',...
        'NumberTitle','on','Position',[100,10,1200,700]);
    %% 3.1 menu item
    menuh1 = uimenu(reditorh,'Label','File','position',1);
    ch11=uimenu(menuh1,'Label','Import r.in','Callback',@loadrin_callback);
    ch12=uimenu(menuh1,'Label','Load previous edit r.in','Callback',@loadrin_callback,'Enable',loadprevious);
    ch13=uimenu(menuh1,'Label','Save','Callback',@saverin_callback,'Enable','off');
    ch14=uimenu(menuh1,'Label','Save as','Callback',@saverinas_callback,'Enable','off');
    uimenu(menuh1,'Label','Quit','Callback',@my_closerequest,'Separator','on','Accelerator','Q');

    menuh2 = uimenu(reditorh,'Label','New','position',2);
    ch21=uimenu(menuh2,'Label','Create from zero','Callback',@createnew_callback,'Enable','on');
    ch22=uimenu(menuh2,'Label','Create by import Zelt''s example','Separator','on','Callback',@zelt_callback,'Enable','on');

    menuh3 = uimenu(reditorh,'Label','','position',3);
%     ch31=uimenu(menuh3,'Label','Create from zero','Callback',@createnew_callback,'Enable','on');
%     ch32=uimenu(menuh3,'Label','Create by import bathymetry','Callback','','Enable','off');
%     ch33=uimenu(menuh3,'Label','Edit layers','Separator','on','Enable','off','Callback',@editlayer_callback);
% %     ch34=uimenu(menuh3,'Label','Delete a layer!','Enable','off','Callback',@delete_callback);
% %     ch35=uimenu(menuh3,'Label','Modify a layer','Enable','off','Callback',@modify_callback);
%     ch36=uimenu(menuh3,'Label','Precision convertor (current model)','Separator','on','Callback',@precision_callback,'Enable','off');
%     uimenu(menuh3,'Label','Precision convertor (batch)','Callback',@precisionbatch_callback);

    menuh4 = uimenu(reditorh,'Label','Debug','position',4);
    ch41=uimenu(menuh4,'Label','Export all virables to base workspace','Callback',@debug_callback,'Enable','off');

    menuh5 = uimenu(reditorh,'Label','Help','position',5,'Enable','off');
    uimenu(menuh5,'Label','Read me','Callback','');

    %% 3.2 Panels
    %% control panel
    controlp = uipanel(reditorh,'Visible','on','Position',[.8 .0 .2 1],'FontSize',12);
    % Parameter Section switch
    bgh = uibuttongroup(controlp,'Title','Parameter Section','FontWeight','bold','FontSize',13,'Position',[.025 .8 .95 .2],'SelectionChangeFcn',@bgh_SelectionChangeFcn);
    rbh1 = uicontrol(bgh,'Style','radiobutton','String','Plot control','Tag','plt','Enable','on','Units','normalized','Position',[.1 .75 .8 .25],'FontWeight','bold','FontSize',12,'ForegroundColor','black');
    rbh2 = uicontrol(bgh,'Style','radiobutton','String','Axes control','Tag','axe','Enable','on','Units','normalized','Position',[.1 .5 .8 .25],'FontWeight','bold','FontSize',12,'ForegroundColor','blue');
    rbh3 = uicontrol(bgh,'Style','radiobutton','String','Ray tracing','Tag','tra','Enable','on','Units','normalized','Position',[.1 .25 .8 .25],'FontWeight','bold','FontSize',12,'ForegroundColor','red');
    rbh4 = uicontrol(bgh,'Style','radiobutton','String','Inverse control','Tag','inv','Enable','on','Units','normalized','Position',[.1 .0 .8 .25],'FontWeight','bold','FontSize',12,'ForegroundColor',[0 .5 .5]);
    % plot panel
    plth = uipanel(controlp,'Visible','on','Position',[.025 .01 .95 .77],'Title','Plot Parameters','FontWeight','bold','FontSize',13,'ForegroundColor','black');
    tts = sprintf('Parameters control screen/file output and figure pages, etc: \n  iplot, isum, isep, [xwndow, ywndow], [ibcol, ifcol], colour');
    pbhgroup(1)=uicontrol(plth,'Style','pushbutton','String','General control','TooltipString',tts,'Units','normalized','Position',[.05 .92 .9 .07],...
        'Tag','1','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters plot model boundaries: \n  imod, ibnd, idash, [ivel, velht], mcol');
    pbhgroup(2)=uicontrol(plth,'Style','pushbutton','String','Model boundaries','TooltipString',tts,'Units','normalized','Position',[.05 .83 .9 .07],...
        'Tag','2','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters control ray plot: \n  iray, irayps, ircol, idot, nskip, nrskip, npskip');
    pbhgroup(3)=uicontrol(plth,'Style','pushbutton','String','Rays in model window','TooltipString',tts,'Units','normalized','Position',[.05 .74 .9 .07],...
        'Tag','3','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters display data points: \n  vred, itx, itxbox, idata, itcol, ibreak, symht');
    pbhgroup(4)=uicontrol(plth,'Style','pushbutton','String','Time-distance window','TooltipString',tts,'Units','normalized','Position',[.05 .65 .9 .07],...
        'Tag','4','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters output discretised velocity model: \n  modout, modi, [xmmin, xmmax], [dxmod, dzmod]');
    pbhgroup(5)=uicontrol(plth,'Style','pushbutton','String','Output discretised model','TooltipString',tts,'Units','normalized','Position',[.05 .56 .9 .07],...
        'Tag','5','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters for debug purpose: \n  itxout, idump, dvmax, dsmax, irays, istep, iszero');
    pbhgroup(6)=uicontrol(plth,'Style','pushbutton','String','Debug purpose','TooltipString',tts,'Units','normalized','Position',[.05 .47 .9 .07],...
        'Tag','6','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters invalid or no longer used in Linux: \n  plotdev, irout, iseg, title, xtitle, ytitle, frz, xmin1d, xmax1d, ifd, dxzmod');
    pbhgroup(7)=uicontrol(plth,'Style','pushbutton','String','Invalid/No longer use','TooltipString',tts,'Units','normalized','Position',[.05 .38 .9 .07],...
        'Tag','7','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);

    % axes panel
    axeh = uipanel(controlp,'Visible','off','Position',[.025 .01 .95 .77],'Title','Axes Parameters','FontWeight','bold','FontSize',13,'ForegroundColor','blue');
    tts = sprintf('Parameters control label and direction of time axis: \n  orig, sep, iaxlab, albht');
    pbhgroup(21)=uicontrol(axeh,'Style','pushbutton','String','Set Origin & Label','TooltipString',tts,'Units','normalized','Position',[.05 .92 .9 .07],...
        'Tag','21','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters control depth-distance window: \n  [xmin, xmax, xmm, xtmin, xtmax, ntickx, ndecix], [zmin, zmax, zmm, ztmin, ztmax, ntickz, ndeciz]');
    pbhgroup(22)=uicontrol(axeh,'Style','pushbutton','String','Depth-Distance Axes','TooltipString',tts,'Units','normalized','Position',[.05 .83 .9 .07],...
        'Tag','22','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters control time-distance window: \n  itrev, [xmint, xmaxt, xmmt, xtmint, xtmaxt, ntckxt, ndecxt], [tmin, tmax, tmm, ttmin, ttmax, ntickt, ndecit]');
    pbhgroup(23)=uicontrol(axeh,'Style','pushbutton','String','Time-Distance Axes','TooltipString',tts,'Units','normalized','Position',[.05 .74 .9 .07],...
        'Tag','23','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);

    % ray panel
    trah = uipanel(controlp,'Visible','off','Position',[.025 .01 .95 .77],'Title','Ray Parameters','FontWeight','bold','FontSize',13,'ForegroundColor','red');
    tts = sprintf('Parameters control general performs of ray tracing: \n  ifast, [i2pt, n2pt, x2pt], isrch, imodf, aamin, aamax, xsmax, [istop, stol], [step, smin, smax]');
    pbhgroup(31)=uicontrol(trah,'Style','pushbutton','String','General control','TooltipString',tts,'Units','normalized','Position',[.05 .92 .9 .07],...
        'Tag','31','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters set source location and ray code (L.n) related: \n  [xshot, zshot, ishot], [ray, iturn, nray, nsmax, amin, amax, space]');
    pbhgroup(32)=uicontrol(trah,'Style','pushbutton','String','Source & Ray L.n','TooltipString',tts,'Units','normalized','Position',[.05 .83 .9 .07],...
        'Tag','32','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters control head wave tracing: \n  idiff, crit, hws, nhary');
    pbhgroup(33)=uicontrol(trah,'Style','pushbutton','String','Head wave specials','TooltipString',tts,'Units','normalized','Position',[.05 .74 .9 .07],...
        'Tag','33','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters control simulation of smooth layer boundaries: \n  [ibsmth, npbnd, nbsmth], [insmth, xminns, xmaxns]');
    pbhgroup(34)=uicontrol(trah,'Style','pushbutton','String','Smooth control','TooltipString',tts,'Units','normalized','Position',[.05 .65 .9 .07],...
        'Tag','34','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters control multiple consideration (考虑走时包含层间反射等多次波的情况）: \n  isrch, [ray, iturn, nrbnd, rbnd]');
    pbhgroup(35)=uicontrol(trah,'Style','pushbutton','String','Include multiples','TooltipString',tts,'Units','normalized','Position',[.05 .56 .9 .07],...
        'Tag','35','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters for P-S converting: \n  isrch, [ray, ncbnd, cbnd], pois, [poisb, poisl, poisbl]');
    pbhgroup(36)=uicontrol(trah,'Style','pushbutton','String','P wave <=> S wave','TooltipString',tts,'Units','normalized','Position',[.05 .47 .9 .07],...
        'Tag','36','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters to specify which ray code will be active for a particular shot point: \n  iraysl, [xshot, ishot, ray, irayt]');
    pbhgroup(37)=uicontrol(trah,'Style','pushbutton','String','Specify "irayt"','TooltipString',tts,'Units','normalized','Position',[.05 .38 .9 .07],...
        'Tag','37','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters for floating reflecting boundaries: \n  [ray, frbnd]');
    pbhgroup(38)=uicontrol(trah,'Style','pushbutton','String','Floating reflectors','TooltipString',tts,'Units','normalized','Position',[.05 .29 .9 .07],...
        'Tag','38','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters invalid or no longer used in Linux: \n  nsmin, ntan');
    pbhgroup(39)=uicontrol(trah,'Style','pushbutton','String','Invalid/No longer use','TooltipString',tts,'Units','normalized','Position',[.05 .2 .9 .07],...
        'Tag','39','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);

    % inverse panel
    invh = uipanel(controlp,'Visible','off','Position',[.025 .01 .95 .77],'Title','Inverse Parameters','FontWeight','bold','FontSize',13,'ForegroundColor',[0 .5 .5]);
    tts = sprintf('Parameters must be set: \n  invr, ivray');
    pbhgroup(41)=uicontrol(invh,'Style','pushbutton','String','Key parameters','TooltipString',tts,'Units','normalized','Position',[.05 .92 .9 .07],...
        'Tag','41','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);
    tts = sprintf('Parameters change other defaults: \n  ximax, ttunc, bndunc, velunc');
    pbhgroup(42)=uicontrol(invh,'Style','pushbutton','String','Others','TooltipString',tts,'Units','normalized','Position',[.05 .83 .9 .07],...
        'Tag','42','Callback',@pushbutton_callback,'FontWeight','bold','FontSize',12);

    %% general information
    generalp = uipanel(reditorh,'Visible','on','Position',[.0 .8 0.8 .2]);
    uicontrol(generalp,'Style','text','String','','HorizontalAlignment','left','FontWeight','bold','FontSize',11,'Units','normalized','Position',[.01 .85 .98 .125]);
    uicontrol(generalp,'Style','text','String','','HorizontalAlignment','left','FontWeight','bold','FontSize',11,'Units','normalized','Position',[.01 .55 .98 .25]);
    uicontrol(generalp,'Style','text','String','','HorizontalAlignment','left','FontWeight','bold','FontSize',11,'Units','normalized','Position',[.01 .375 .98 .125]);
    uicontrol(generalp,'Style','text','String','','HorizontalAlignment','left','FontWeight','bold','FontSize',11,'Units','normalized','Position',[.01 .075 .98 .25]);
    update_generalp;

    %% Output list table
    tablep=uipanel(reditorh,'Visible','on','Position',[.0 .0 0.8 .8],'BorderType','none','TitlePosition','centertop','FontWeight','bold','FontSize',13,'ForegroundColor','black');
    uicontrol(tablep,'Style','text','String','Parameters to output','HorizontalAlignment','center','FontWeight','bold','FontSize',13,'Units','normalized','Position',[.01 .892 0.98 0.1]);
    tbh=uitable(tablep,'Units','normalized','Position',[.01 .015 0.98 0.94],'ColumnName',col_plt,'data',data_plt);

    %% 3.3 Behavor
    set(reditorh,'CloseRequestFcn',@my_closerequest);
    % Initialize some button group properties.
    set(bgh,'SelectedObject',rbh1);  % No selection
    % make the window visable
    set(reditorh,'Visible','on');

end


%% ----- Callback Functions ------%
    function my_closerequest(hObject, eventdata)
        selection = questdlg('Do you want to exit ?',...
            'Close Request Function',...
            'Exit WITHOUT Save','Save & Exit','Cancel','Cancel');
        switch selection
            case 'Exit WITHOUT Save'
                save ('history_rin.mat');
                delete(reditorh);
            case 'Save & Exit'
                savedone=saverin_callback;
                if savedone;
                    delete(reditorh);
                end
            case 'Cancel'
        end
    end

    function debug_callback(src,event)
        clc
        whos
        for k=1:length(allnames);
            eval(['assignin(''base'',''',allnames{k},''',',allnames{k},')']);
        end
    end

    function loadrin_callback(src,event)
        switch loadprevious
            case 'off'
                [loadname,loadpath]= uigetfile('*.in');
            case 'on'
                [loadname,loadpath]= uigetfile(fullload);
        end
        if loadname==0
        else
            fullload=fullfile(loadpath,loadname);
            save ('history_rin.mat');
            old_xmin=xmin{7};
            old_xmax=xmax{7};
            old_zmin=zmin{7};
            old_zmax=zmax{7};
            old_tmin=tmin{7};
            old_tmax=tmax{7};
            old_xmm=xmm{7};
            old_ntickx=ntickx{7};
            fun_read_rin(fullload);
            fun_reset_all_defaults(old_xmin,old_xmax,old_zmin,old_zmax,old_tmin,old_tmax,old_xmm,old_ntickx);
%             fun_set_default;
            update_generalp;
            update_table;
            set (ch11,'Enable','on'); set (ch12,'Enable','on'); set (ch13,'Enable','on'); set (ch14,'Enable','on');
            set (ch21,'Enable','on'); set (ch22,'Enable','on');
%             set (ch31,'Enable','off'); set (ch33,'Enable','on'); set (ch36,'Enable','on');
            set (ch41,'Enable','on');
            save ('history_rin.mat');
        end
    end

    function savedone=saverin_callback(src,event)
        savedone=false;
        selection = questdlg('The current r.in file will be overwritten. Are you sure?',...
            'Overwrite warning',...
            'Overwrite','New file','Cancel','Cancel');
        switch selection,
            case 'Yes',
                savedone=fun_write_rin(fullload);
                set (ch11,'Enable','on'); set (ch12,'Enable','on'); set (ch13,'Enable','on'); set (ch14,'Enable','on');
                set (ch21,'Enable','on'); set (ch22,'Enable','on');
                save ('history_rin.mat');
            case 'New file'
                savedone=saverinas_callback;
            case 'Cancel'
        end
    end

    function savedone=saverinas_callback(src,event)
        savedone=false;
        switch loadprevious
            case 'off'
                [savename,savepath]= uiputfile('*.in');
            case 'on'
                [savename,savepath]= uiputfile(fullsave);
        end
        if savename==0
        else
            fullsave=fullfile(savepath,savename);
            save ('history_rin.mat');
            savedone=fun_write_rin(fullsave);
            save ('history_rin.mat');
            set (ch11,'Enable','on'); set (ch12,'Enable','on'); set (ch13,'Enable','on'); set (ch14,'Enable','on');
            set (ch21,'Enable','on'); set (ch22,'Enable','on');
        end
    end

    function createnew_callback(src,event)
        prompt = {'\fontsize{12}xmin & xmax : Minimum & Maximum x coordinate (km)','\fontsize{12}zmin & zmax : Minimum & Maximum z coordinate (km)',...
            '\fontsize{12}tmin & tmax : Minimum & Maximum t coordinate (s)'};
        dlg_title = 'Key Parameter Setting';
        num_lines = [1,70];
        def = {[num2str(xmin{7}) ', ' num2str(xmax{7})],[num2str(zmin{7}) ', ' num2str(zmax{7})],[num2str(tmin{7}) ', ' num2str(tmax{7})]};
        options.Interpreter='tex';
        answer = inputdlg(prompt,dlg_title,num_lines,def,options);
        if ~isempty(answer)
            old_xmin=xmin{7};
            old_xmax=xmax{7};
            old_zmin=zmin{7};
            old_zmax=zmax{7};
            old_tmin=tmin{7};
            old_tmax=tmax{7};
            old_xmm=xmm{7};
            old_ntickx=ntickx{7};
            c=num2cell(str2num(sprintf('%s,%s,%s',answer{:})));
            [xmin{7} xmax{7} zmin{7} zmax{7} tmin{7} tmax{7}]=deal(c{:});
            [xmin{8} xmax{8} zmin{8} zmax{8} tmin{8} tmax{8}]=deal(true);
            fun_reset_all_defaults(old_xmin,old_xmax,old_zmin,old_zmax,old_tmin,old_tmax,old_xmm,old_ntickx);
%             fun_set_default;
            update_generalp;
            update_table;
            set (ch11,'Enable','off'); set (ch12,'Enable','off'); set (ch13,'Enable','off'); set (ch14,'Enable','on');
            set (ch21,'Enable','on'); set (ch22,'Enable','off');
%             set (ch33,'Enable','on'); set (ch36,'Enable','on');
            set (ch41,'Enable','on');
        end
    end

    function zelt_callback(src,event)
        options={'(1)  crustal example','(2)  refraction statics example using head waves','(3)  reflector example',...
            '(4)  synthetics for example 3','(5)  refraction statics example using turning rays','(6)  synthetics for example (1)',...
            '(7)  real crustal data example with floating reflectors','(8)  s-waves (Sg) and conversions (PmS) for example (1)'};
        choice = menu('Choose a template',options);
        filename=['Zelt_example_r',num2str(choice),'.in'];
        old_xmin=xmin{7};
        old_xmax=xmax{7};
        old_zmin=zmin{7};
        old_zmax=zmax{7};
        old_tmin=tmin{7};
        old_tmax=tmax{7};
        old_xmm=xmm{7};
        old_ntickx=ntickx{7};
        fun_read_rin(filename);
        fun_reset_all_defaults(old_xmin,old_xmax,old_zmin,old_zmax,old_tmin,old_tmax,old_xmm,old_ntickx);
%         fun_set_default;
        update_generalp;
        update_table;
        set (ch11,'Enable','on'); set (ch12,'Enable','on'); set (ch13,'Enable','off'); set (ch14,'Enable','on');
        set (ch21,'Enable','off'); set (ch22,'Enable','on');
        %             set (ch31,'Enable','off'); set (ch33,'Enable','on'); set (ch36,'Enable','on');
        set (ch41,'Enable','on');
        save ('history_rin.mat');
    end

    function bgh_SelectionChangeFcn(hObject,eventdata)
        tag=get(eventdata.NewValue,'Tag'); % Get Tag of selected object.
        switch tag
            case 'plt'
                fun_batch_ui_switch({axeh,trah,invh},'Visible','off');
                fun_batch_ui_switch({plth},'Visible','on');
            case 'axe'
                fun_batch_ui_switch({plth,trah,invh},'Visible','off');
                fun_batch_ui_switch({axeh},'Visible','on');
            case 'tra'
                fun_batch_ui_switch({plth,axeh,invh},'Visible','off');
                fun_batch_ui_switch({trah},'Visible','on');
            case 'inv'
                fun_batch_ui_switch({plth,axeh,trah},'Visible','off');
                fun_batch_ui_switch({invh},'Visible','on');
        end
        eval(['set(tbh,''ColumnName'',col_' tag ',''data'',data_' tag ');']);
    end

    function pushbutton_callback(src,event)
        tag = get(src,'Tag');
        parameter_modified=false;
        old_xmin=xmin{7};
        old_xmax=xmax{7};
        old_zmin=zmin{7};
        old_zmax=zmax{7};
        old_tmin=tmin{7};
        old_tmax=tmax{7};
        old_xmm=xmm{7};
        old_ntickx=ntickx{7};
        eval(['fun_pbhgroup',tag,';']);
        if parameter_modified;
            fun_reset_all_defaults(old_xmin,old_xmax,old_zmin,old_zmax,old_tmin,old_tmax,old_xmm,old_ntickx);
%             fun_set_default;
            update_generalp;
            update_table;
        end
    end







%% Tool functions

    function fun_read_rin(filein)
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
        display (['Finish reading ',filein]);
    end

    function fun_set_default()
        % 参数更新后，重新设置某些参数的缺省值/输出值
        % pltpra
        if isnan(xmmin{7});
            xmmin([5,7])=xmin(7);
        end
        if isnan(xmmax{7});
            xmmax([5,7])=xmax(7);
        end
        % axepra
        if isnan(xtmin{7});
            xtmin([5,7])=xmin(7);
        end
        if isnan(xtmax{7});
            xtmax([5,7])=xmax(7);
        end
        if isnan(ztmin{7});
            ztmin([5,7])=zmin(7);
        end
        if isnan(ztmax{7});
            ztmax([5,7])=zmax(7);
        end
        if isnan(xmint{7});
            xmint([5,7])=xmin(7);
        end
        if isnan(xmaxt{7});
            xmaxt([5,7])=xmax(7);
        end
        if isnan(xmmt{7});
            xmmt([5,7])=xmm(7);
        end
        if isnan(xtmint{7});
            xtmint([5,7])=xtmin(7);
        end
        if isnan(xtmaxt{7});
            xtmaxt([5,7])=xtmax(7);
        end
        if isnan(ntckxt{7});
            ntckxt([5,7])=ntickx(7);
        end
        if isnan(ttmin{7});
            ttmin([5,7])=tmin(7);
        end
        if isnan(ttmax{7});
            ttmax([5,7])=tmax(7);
        end
        % trapar
        if isnan(x2pt{7});
            x2pt([5,7])={(xmax{7}-xmin{7})/2000};
        end
        if isnan(hws{7});
            hws([5,7])={(xmax{7}-xmin{7})/25};
        end
        if isnan(stol{7});
            stol([5,7])={(xmax{7}-xmin{7})/3500};
        end
        if isnan(xminns{7});
            xminns([5,7])=xmin(7);
        end
        if isnan(xmaxns{7});
            xmaxns([5,7])=xmax(7);
        end
        if isnan(smin{7});
            smin([5,7])={(xmax{7}-xmin{7})/4500};
        end
        if isnan(smax{7});
            smax([5,7])={(xmax{7}-xmin{7})/15};
        end
        % invpar
        if isnan(ximax{7});
            ximax([5,7])={(xmax{7}-xmin{7})/20};
        end
    end

    function fun_reset_all_defaults(old_xmin,old_xmax,old_zmin,old_zmax,old_tmin,old_tmax,old_xmm,old_ntickx)
        % 当关键参数xmin和/或者xmax等更新后，必须重新设置以下参数的缺省值/输出值
            %irayt([5,7])=1; irayt(8)=false;
        if (~strcmp(num2str(xmin{7}),num2str(old_xmin)))||(~strcmp(num2str(xmax{7}),num2str(old_xmax)))
            % pltpra
            xmmin([5,7])=xmin(7);
            xmmax([5,7])=xmax(7);
            % axepra
            xtmin([5,7])=xmin(7);
            xtmax([5,7])=xmax(7);
            xmint([5,7])=xmin(7);
            xmaxt([5,7])=xmax(7);
            xtmint([5,7])=xtmin(7);
            xtmaxt([5,7])=xtmax(7);
            % trapar
            x2pt([5,7])={(xmax{7}-xmin{7})/2000};
            hws([5,7])={(xmax{7}-xmin{7})/25};
            stol([5,7])={(xmax{7}-xmin{7})/3500};
            xminns([5,7])=xmin(7);
            xmaxns([5,7])=xmax(7);
            smin([5,7])={(xmax{7}-xmin{7})/4500};
            smax([5,7])={(xmax{7}-xmin{7})/15};
            % invpar
            ximax([5,7])={(xmax{7}-xmin{7})/20};
        end
        if (~strcmp(num2str(xmm{7}),num2str(old_xmm)))
            xmmt([5,7])=xmm(7);
        end
        if (~strcmp(num2str(zmin{7}),num2str(old_zmin)))
            ztmin([5,7])=zmin(7);
        end
        if (~strcmp(num2str(zmax{7}),num2str(old_zmax)))
            ztmax([5,7])=zmax(7);
        end
        if (~strcmp(num2str(ntickx{7}),num2str(old_ntickx)))
            ntckxt([5,7])=ntickx(7);
        end
        if (~strcmp(num2str(tmin{7}),num2str(old_tmin)))
            ttmin([5,7])=tmin(7);
        end
        if (~strcmp(num2str(tmax{7}),num2str(old_tmax)))
            ttmax([5,7])=tmax(7);
        end
    end

    function savedone=fun_write_rin(fileout)
        savedone=false;
        fid = fopen(fileout,'w');
        countsingle=0; % 开关或者单值类型的输出，每行5个，然后换号（参考：数组类型的单独占一行，每行10个数据）
        for k=1:length(allnames);
            if k==1;
                currentsect='&pltpar';
%                 disp(['   ',currentsect,'  ']);
                fprintf(fid,'%s',['   ',currentsect,'  ']);
            end
            wordname=allnames{k};
            eval(['sectname=' wordname '{1};']);
            if ~strcmp(currentsect, sectname); % 输出的分区变了
%                 disp(['   ','&end']);
                fprintf(fid,'\n%s\n',['   ','&end']);
                currentsect=sectname;
%                 disp(['   ',currentsect,'  ']);
                fprintf(fid,'%s',['   ',currentsect,'  ']);
                countsingle=0;
            end
            if eval([wordname '{8};']); % 如果该变量需要输出
                vv=eval([wordname '{7};']);
                if ~isnan(vv);
                    type=eval([wordname '{2};']);
                    vl=length(vv); % 数据个数 value length
                    if vl==1;  %开关或者单值类型的输出，每行5个，然后换号
                        countsingle=countsingle+1;
                        if countsingle>5;
                            fprintf(fid,'\n            ');
                            countsingle=1;
                        end
                        if strcmp(type,'III');  % 整型变量的输出
%                             sprintf('%s=%s ',wordname,strrep(num2str(vv,'%d,'),' ',''))
                            fprintf(fid,'%s=%s ',wordname,strrep(num2str(vv,'%d,'),' ',''));
                        else   % 浮点类型的输出
%                             sprintf('%s=%s ',wordname,strrep(strrep(num2str(vv,'%10.4f,'),'.0000','.'),' ',''))
                            fprintf(fid,'%s=%s ',wordname,strrep(strrep(num2str(vv,'%10.4f,'),'.0000','.'),' ',''));
                        end
                    else % 数组类型的输出，单独起行，每10个数据一行
                        LN=ceil(vl/10); % 数组全部数据需要的行数
                        for ii=1:LN;
                            if countsingle~=0
                                fprintf(fid,'\n            ');
                            end
                            if ii==LN;  % 最后一行
                                vsub=vv((ii-1)*10+1:vl);
                                countsingle=6; % 数组单独起行，则单值也需要重新开始
                            else
                                vsub=vv((ii-1)*10+1:ii*10);
                            end
                            if ii==1;
%                                 sprintf('%s=',wordname)
                                fprintf(fid,'%s=',wordname);
                            else
                                fprintf(fid,'%6s',' ');
                            end
                            if strcmp(type,'III');  % 整型变量的输出
%                                 sprintf('%s ',strrep(num2str(vsub,'%d,'),' ',''))
                                fprintf(fid,'%s',strrep(strrep(num2str(vsub,'%d,'),' ',''),',',', '));
                            else   % 浮点类型的输出
%                                 sprintf('%s ',strrep(num2str(vsub,'%10.4f,'),' ',''))
                                fprintf(fid,'%s',strrep(strrep(num2str(vsub,'%10.4f,'),' ',''),',',', '));
                            end
                        end
                    end
                end
            end
        end
        fprintf(fid,'\n%s\n',['   ','&end']);
%         disp(['   ','&end']); % 输出结束了
        fclose(fid);
        savedone=true;
    end

    function fun_make_table
        cn={'Switch/Single','Value','Arrays ->'};
        td={};
        singl_counte=0;
        array_count=3;
        for k=1:length(allnames);
            if k==1;
                currentsect='&pltpar';
            end
            wordname=allnames{k};
            eval(['sectname=' wordname '{1};']);
            if ~strcmp(currentsect, sectname); % 输出的分区变了
                eval(['col_' currentsect(2:4) '=cn;']);
                eval(['data_' currentsect(2:4) '=td;']);
                currentsect=sectname;
                singl_counte=0;
                array_count=3;
                cn={'Switch/Single','Value','Arrays ->'};
                td={};
            end
            if eval([wordname '{8};']); % 如果该变量需要输出
                vv=eval([wordname '{7};']);
                if ~isnan(vv);
                    vl=length(vv); % 数据个数 value length
                    if vl==1;  %开关或者单值类型
                        singl_counte=singl_counte+1;
                        td{singl_counte,1}=wordname;
                        td{singl_counte,2}=vv;
                    else % 数组类型
                        array_count=array_count+1;
                        cn{array_count}=wordname;
                        td(1:vl,array_count)=num2cell(vv');
                    end
                end
            end
            if k==length(allnames)
                eval(['col_' currentsect(2:4) '=cn;']);
                eval(['data_' currentsect(2:4) '=td;']);
            end
        end
    end

    function update_table
        fun_make_table;
        current=get(bgh,'SelectedObject');
        tag=get(current,'Tag');
        eval(['set(tbh,''ColumnName'',col_' tag ',''data'',data_' tag ');']);
    end

    function update_generalp
        gptext{1}=['Model size: distance of x ranges ',num2str(xmin{7}),' to ',num2str(xmax{7}),' (km); depth of z ranges ',num2str(zmin{7}),' to ',num2str(zmax{7}),...
            ' (km); travel time of t ranges ',num2str(tmin{7}),' to ',num2str(tmax{7}),' (s).'];
        gptext{2}=['Plot size (horizontal X vertical): page ',num2str(xwndow{7}),' X ',num2str(ywndow{7}),' (mm); depth-distance window ',num2str(xmm{7}),' X ',num2str(zmm{7}),...
            ' (mm); time-distance window ',num2str(xmmt{7}),' X ',num2str(tmm{7}),' (mm); window separation ',num2str(sep{7}),' (mm).'];
        gptext{3}=['Total shots = ',num2str(length(xshot{7})),';          Two-point ray tracing i2pt = ',num2str(i2pt{7}),...
            ';         Calculate partial derivatives for inversion invr = ',num2str(invr{7})];
        ss='';
        for i=1:length(ivray{7});
            ss=[ss sprintf('%3d, ',ivray{7}(i))];
        end
        gptext{4}=sprintf('      Tracing ray codes         ray  = %s \nCorresponding arrivals   ivray =  %s ',num2str(ray{7},'%3.1f, '),ss);
        htext=allchild(generalp);
        LL=length(htext);
        for i=1:LL;
            set(htext(i),'String',gptext{LL+1-i}); % 最后建立的组件在最上方
        end
    end


    function fun_pbhgroup1
        %  iplot, isum, isep, [xwndow, ywndow], [ibcol, ifcol], colour
        dlg_title = 'Parameters of General Control for Plotting';
        varlist={'iplot','isum','isep', 'xwndow','ywndow','ibcol', 'ifcol','colour'};
        varnum=length(varlist);
        for i=1:varnum;
            if eval([varlist{i},'{8};']); % 当为true时以红色粗体提示该项目要输出到r.in
                ifout{i}=outlabel;
            else
                ifout{i}='';
            end
        end
        prompt{1} = ['\fontsize{10}',iplot{4},ifout{1},char(13,10)','\fontsize{11}\color{blue}iplot\color{black}: ',iplot{3},'\color{red}  Possible Value: ',num2str(iplot{9})];
        prompt{2} = [char(13,10)','\fontsize{10}',isum{4},ifout{2},char(13,10)','\fontsize{11}\color{blue}isum\color{black}: ',isum{3},'\color{red}  Possible Value: ',num2str(isum{9})];
        prompt{3} = [char(13,10)','\fontsize{10}',isep{4},ifout{3},char(13,10)','\fontsize{11}\color{blue}isep\color{black}: ',isep{3},'\color{red}  Possible Value: ',num2str(isep{9})];
        prompt{4} = [char(13,10)','\fontsize{10}',xwndow{4},ifout{4},char(13,10)','\fontsize{11}\color{magenta}[xwndow, ywndow]\color{black}: '...
            'the horizontal & vertical size of the graphics window (mm) that will over-ride a window size specified in an "mx11.opt" or ".Xdefaults" ',char(13,10)',...
            'file; the maximum allowable values (to use the entire screen) are [350 265] mm (defaults: if xwndow or ywndow is less than or equal to zero, the size of the window specified ',char(13,10)',...
            'in the "mx11.opt" or ".Xdefaults" file is used). Note: the effect of this parameter will depend on the local graphics system and machine type.','\color{red}  Maximum Value: [350 265]'];
        prompt{5} = [char(13,10)','\fontsize{10}[ibcol ifcol]定义模型的背景色和前景色；缺省值为[0 1]，即[白色 黑色]。',ifout{6},char(13,10)','\fontsize{11}\color[rgb]{0 .5 .5}[ibcol ifcol]\color{black}: ',...
            'background colour (defaults: 0) and foreground colour (defaults: 1).'];
        prompt{6} = [char(13,10)','\fontsize{10}',colour{4},ifout{8},char(13,10)','\fontsize{11}\color{blue}colour\color{black}: ',colour{3}];
        num_lines = [1,198];
        def = {num2str(iplot{7}) num2str(isum{7}) num2str(isep{7}) [num2str(xwndow{7}),' ', num2str(ywndow{7})] [num2str(ibcol{7}),' ',num2str(ifcol{7})] num2str(colour{7}) };
        options.Interpreter='tex';
        answer = inputdlg(prompt,dlg_title,num_lines,def,options);
        if ~isempty(answer);  % 这是为了检查是否点了cancel或者关闭窗口，此时返回的是空cell（不是空字符串！）
            ifsame=strcmpi(answer',def);  % 一一对应比较返回的答案是否与原来的相同。注意：answer返回的是列向量形式！
            ifsame=[ifsame(1:3) ifsame(4) ifsame(4) ifsame(5) ifsame(5) ifsame(6)];  % 将6个原始的判断扩展为跟参数数目一样的8个
            c=num2cell(str2num(sprintf('%s,%s,%s,%s,%s',answer{1:5})));
            [iplot{7} isum{7} isep{7} xwndow{7} ywndow{7} ibcol{7} ifcol{7}]=deal(c{:});
            colour{7}=str2num(answer{6});
            for i=1:varnum;
                if ~ifsame(i);  % 如果第i个返回项跟原来不同
                    eval([varlist{i},'{8}=true;']);
                    parameter_modified=true;
                end
            end
        end
    end

    function fun_pbhgroup2
        %  imod, ibnd, idash, ivel, velht, mcol
        dlg_title = 'Parameters to Plot Velocity Model';
        varlist={'imod','ibnd','idash', 'ivel','velht','mcol'};
        varnum=length(varlist);
        for i=1:varnum;
            if eval([varlist{i},'{8};']); % 当为true时以红色粗体提示该项目要输出到r.in
                ifout{i}=outlabel;
            else
                ifout{i}='';
            end
        end
        prompt{1} = ['\fontsize{10}',imod{4},ifout{1},char(13,10)','\fontsize{11}\color{blue}imod\color{black}: ',imod{3},'\color{red}  Possible Value: ',num2str(imod{9})];
        prompt{2} = [char(13,10)','\fontsize{10}',ibnd{4},ifout{2},char(13,10)','\fontsize{11}\color{blue}ibnd\color{black}: ',ibnd{3},'\color{red}  Possible Value: ',num2str(ibnd{9})];
        prompt{3} = [char(13,10)','\fontsize{10}',idash{4},ifout{3},char(13,10)','\fontsize{11}\color{blue}idash\color{black}: ',idash{3},'\color{red}  Possible Value: ',num2str(idash{9})];
        prompt{4} = [char(13,10)','\fontsize{10}',ivel{4},ifout{4},char(13,10)','\fontsize{11}\color{blue}ivel\color{black}: ',ivel{3},'\color{red}  Possible Value: ',num2str(ivel{9})];
        prompt{5} = [char(13,10)','\fontsize{10}',velht{4},ifout{5},char(13,10)','\fontsize{11}\color{blue}velht\color{black}: ',velht{3}];
        prompt{6} = [char(13,10)','\fontsize{10}',mcol{4},ifout{6},char(13,10)','\fontsize{11}\color{blue}mcol\color{black}: ',mcol{3}];
        num_lines = [1,190];
        def = {num2str(imod{7}) num2str(ibnd{7}) num2str(idash{7}), num2str(ivel{7}),num2str(velht{7}), num2str(mcol{7})};
        options.Interpreter='tex';
        answer = inputdlg(prompt,dlg_title,num_lines,def,options);
        if ~isempty(answer);  % 这是为了检查是否点了cancel或者关闭窗口，此时返回的是空cell（不是空字符串！）
            ifsame=strcmpi(answer',def);  % 一一对应比较返回的答案是否与原来的相同。注意：answer返回的是列向量形式！
            for i=1:varnum;
                if ~ifsame(i);  % 如果第i个返回项跟原来不同
                    eval([varlist{i},'{7}=str2num(answer{',num2str(i),'});']);
                    eval([varlist{i},'{8}=true;']);
                    parameter_modified=true;
                end
            end
        end
    end

    function fun_pbhgroup3
        %  iray, irayps, ircol, idot, nskip, nrskip, npskip
        dlg_title = 'Parameters of Rays Plotted in Model Window';
        varlist={'iray','irayps','ircol','idot', 'nskip','nrskip','npskip'};
        varnum=length(varlist);
        for i=1:varnum;
            if eval([varlist{i},'{8};']); % 当为true时以红色粗体提示该项目要输出到r.in
                ifout{i}=outlabel;
            else
                ifout{i}='';
            end
        end
        prompt{1} = ['\fontsize{10}',iray{4},ifout{1},char(13,10)','\fontsize{11}\color{blue}iray\color{black}: ',iray{3},'\color{red}  Possible Value: ',num2str(iray{9})];
        prompt{2} = ['\fontsize{10}',irayps{4},ifout{2},char(13,10)','\fontsize{11}\color{blue}irayps\color{black}: ',irayps{3},'\color{red}  Possible Value: ',num2str(irayps{9})];
        prompt{3} = ['\fontsize{10}',ircol{4},ifout{3},char(13,10)','\fontsize{11}\color{blue}ircol\color{black}: ',ircol{3},'\color{red}  Possible Value: ',num2str(ircol{9})];
        prompt{4} = ['\fontsize{10}',idot{4},ifout{4},char(13,10)','\fontsize{11}\color{blue}idot\color{black}: ',idot{3},'\color{red}  Possible Value: ',num2str(idot{9})];
        prompt{5} = ['\fontsize{10}',nskip{4},ifout{5},char(13,10)','\fontsize{11}\color{blue}nskip\color{black}: ',nskip{3}];
        prompt{6} = ['\fontsize{10}',nrskip{4},ifout{6},char(13,10)','\fontsize{11}\color{blue}nrskip\color{black}: ',nrskip{3}];
        prompt{7} = ['\fontsize{10}',npskip{4},ifout{7},char(13,10)','\fontsize{11}\color{blue}npskip\color{black}: ',npskip{3}];
        num_lines = [1,190];
        def = {num2str(iray{7}) num2str(irayps{7}) num2str(ircol{7}),num2str(idot{7}) num2str(nskip{7}),num2str(nrskip{7}),num2str(npskip{7})};
        options.Interpreter='tex';
        answer = inputdlg(prompt,dlg_title,num_lines,def,options);
        if ~isempty(answer);  % 这是为了检查是否点了cancel或者关闭窗口，此时返回的是空cell（不是空字符串！）
            ifsame=strcmpi(answer',def);  % 一一对应比较返回的答案是否与原来的相同。注意：answer返回的是列向量形式！
            for i=1:varnum;
                if ~ifsame(i);  % 如果第i个返回项跟原来不同
                    eval([varlist{i},'{7}=str2num(answer{',num2str(i),'});']);
                    eval([varlist{i},'{8}=true;']);
                    parameter_modified=true;
                end
            end
        end
    end

    function fun_pbhgroup4
        %  vred, itx, itxbox, idata, itcol, ibreak, symht
        dlg_title = 'Parameters Controlling Time-Distance Plot';
        varlist={'vred','itx','itxbox','idata', 'itcol','ibreak','symht'};
        varnum=length(varlist);
        for i=1:varnum;
            if eval([varlist{i},'{8};']); % 当为true时以红色粗体提示该项目要输出到r.in
                ifout{i}=outlabel;
            else
                ifout{i}='';
            end
        end
        prompt{1} = ['\fontsize{10}',vred{4},ifout{1},char(13,10)','\fontsize{11}\color{blue}vred\color{black}: ',vred{3},'\color{red}  Possible Value: 0 to 10'];
        prompt{2} = ['\fontsize{10}',itx{4},ifout{2},char(13,10)','\fontsize{11}\color{blue}itx\color{black}: ',itx{3},'\color{red}  Possible Value: ',num2str(itx{9})];
        prompt{3} = ['\fontsize{10}',itxbox{4},'\color{red}  Possible Value: ',num2str(itxbox{9}),ifout{3},char(13,10)','\fontsize{11}\color{blue}itxbox\color{black}: ',itxbox{3}];
        prompt{4} = ['\fontsize{10}',idata{4},ifout{4},char(13,10)','\fontsize{11}\color{blue}idata\color{black}: ',idata{3},'\color{red}  Possible Value: ',num2str(idata{9})];
        prompt{5} = ['\fontsize{10}',itcol{4},'\color{red}  Possible Value: ',num2str(itcol{9}),ifout{5},char(13,10)','\fontsize{11}\color{blue}itcol\color{black}: ',itcol{3}];
        prompt{6} = ['\fontsize{10}',ibreak{4},ifout{6},char(13,10)','\fontsize{11}\color{blue}ibreak\color{black}: ',ibreak{3},char(13,10)',...
            '\color{red}Possible Value: ',num2str(ibreak{9}),'        \fontsize{12}\bfReference: ray=',num2str(ray{7})];
        prompt{7} = ['\fontsize{10}',symht{4},ifout{7},char(13,10)','\fontsize{11}\color{blue}symht\color{black}: ',symht{3}];
        num_lines = [1,200];
        def = {num2str(vred{7}) num2str(itx{7}) num2str(itxbox{7}),num2str(idata{7}) num2str(itcol{7}),num2str(ibreak{7}),num2str(symht{7})};
        options.Interpreter='tex';
        answer = inputdlg(prompt,dlg_title,num_lines,def,options);
        if ~isempty(answer);  % 这是为了检查是否点了cancel或者关闭窗口，此时返回的是空cell（不是空字符串！）
            ifsame=strcmpi(answer',def);  % 一一对应比较返回的答案是否与原来的相同。注意：answer返回的是列向量形式！
            for i=1:varnum;
                if ~ifsame(i);  % 如果第i个返回项跟原来不同
                    eval([varlist{i},'{7}=str2num(answer{',num2str(i),'});']);
                    eval([varlist{i},'{8}=true;']);
                    parameter_modified=true;
                end
            end
        end
    end

    function fun_pbhgroup5
        %  modout, modi, [xmmin, xmmax], [dxmod, dzmod]
        dlg_title = 'Output Discretised Model for GMT Plotting';
        varlist={'modout','modi','xmmin','xmmax', 'dxmod','dzmod'};
        varnum=length(varlist);
        for i=1:varnum;
            if eval([varlist{i},'{8};']); % 当为true时以红色粗体提示该项目要输出到r.in
                ifout{i}=outlabel;
            else
                ifout{i}='';
            end
        end
        prompt{1} = ['\fontsize{10}',modout{4},ifout{1},char(13,10)','\fontsize{11}\color{blue}modout\color{black}: ',modout{3},'\color{red}  Possible Value: ',num2str(modout{9})];
        prompt{2} = [char(13,10)','\fontsize{10}',modi{4},ifout{2},char(13,10)','\fontsize{11}\color{blue}modi\color{black}: ',modi{3}];
        prompt{3} = [char(13,10)','\fontsize{10}[xmmin xmmax]为离散化模型文件v.out中x坐标的范围；缺省值为x坐标的极限[xmin xmax]。',ifout{3},char(13,10)',...
            '\fontsize{11}\color{blue}[xmmin xmmax]\color{black}: minimum and maximum x co-ordinates for the output model, v.out (defaults to xmin and xman). ',...
            'Note: xmin and xmax determine limits in x direction. (ARG 6.8.99)'];
        prompt{4} = [char(13,10)','\fontsize{10}',dxmod{4},ifout{4},char(13,10)','\fontsize{11}\color{blue}[dxmod dzmod]\color{black}: ',...
            'size of increment in x and z directions for discretised output model, v.out. (ARG 15.10.98)'];
        num_lines = [1,160];
        def = {num2str(modout{7}) num2str(modi{7}) [num2str(xmmin{7}),' ', num2str(xmmax{7})] [num2str(dxmod{7}),' ',num2str(dzmod{7})]};
        options.Interpreter='tex';
        answer = inputdlg(prompt,dlg_title,num_lines,def,options);
        if ~isempty(answer);  % 这是为了检查是否点了cancel或者关闭窗口，此时返回的是空cell（不是空字符串！）
            ifsame=strcmpi(answer',def);  % 一一对应比较返回的答案是否与原来的相同。注意：answer返回的是列向量形式！
            ifsame=[ifsame(1:2) ifsame(3) ifsame(3) ifsame(4) ifsame(4)];
            c=num2cell(str2num(sprintf('%s,%s,%s,%s',answer{[1 3 4]})));
            [modout{7} xmmin{7} xmmax{7} dxmod{7} dzmod{7}]=deal(c{:});
            modi{7}=str2num(answer{2});
            for i=1:varnum;
                if ~ifsame(i);  % 如果第i个返回项跟原来不同
                    eval([varlist{i},'{8}=true;']);
                    parameter_modified=true;
                end
            end
        end
    end

    function fun_pbhgroup6
        %  itxout, idump, dvmax, dsmax, irays, istep, iszero
        dlg_title = 'Parameters for Debug Purpose';
        varlist={'itxout','idump','dvmax', 'dsmax','irays','istep','iszero'};
        varnum=length(varlist);
        for i=1:varnum;
            if eval([varlist{i},'{8};']); % 当为true时以红色粗体提示该项目要输出到r.in
                ifout{i}=outlabel;
            else
                ifout{i}='';
            end
        end
        prompt{1} = ['\fontsize{10}',itxout{4},ifout{1},char(13,10)','\fontsize{11}\color{blue}itxout\color{black}: ',itxout{3},'\color{red}  Possible Value: ',num2str(itxout{9})];
        prompt{2} = ['\fontsize{10}',idump{4},char(13,10)','\fontsize{11}\color{blue}idump\color{black}: ',idump{3},'\color{red}  Possible Value: ',num2str(idump{9}),ifout{2}];
        prompt{3} = ['\fontsize{10}',dvmax{4},ifout{3},char(13,10)','\fontsize{11}\color{black}dvmax\color{black}: ',dvmax{3}];
        prompt{4} = ['\fontsize{10}',dsmax{4},char(13,10)','\fontsize{11}\color{black}dsmax\color{black}: ',dsmax{3},ifout{4}];
        prompt{5} = ['\fontsize{10}',irays{4},ifout{5},char(13,10)','\fontsize{11}\color{magenta}irays\color{black}: ',irays{3},'\color{red}  Possible Value: ',num2str(irays{9})];
        prompt{6} = ['\fontsize{10}',istep{4},ifout{6},char(13,10)','\fontsize{11}\color{magenta}istep\color{black}: ',istep{3},'\color{red}  Possible Value: ',num2str(istep{9})];
        prompt{7} = ['\fontsize{10}',iszero{4},ifout{7},char(13,10)','\fontsize{11}\color{black}iszero\color{black}: ',iszero{3},'\color{red}  Possible Value: ',num2str(iszero{9})];
        num_lines = [1,200];
        def = {num2str(itxout{7}) num2str(idump{7}) num2str(dvmax{7}) num2str(dsmax{7}) num2str(irays{7}) num2str(istep{7}) num2str(iszero{7})};
        options.Interpreter='tex';
        answer = inputdlg(prompt,dlg_title,num_lines,def,options);
        if ~isempty(answer);  % 这是为了检查是否点了cancel或者关闭窗口，此时返回的是空cell（不是空字符串！）
            ifsame=strcmpi(answer',def);  % 一一对应比较返回的答案是否与原来的相同。注意：answer返回的是列向量形式！
            for i=1:varnum;
                if ~ifsame(i);  % 如果第i个返回项跟原来不同
                    eval([varlist{i},'{7}=str2num(answer{',num2str(i),'});']);
                    eval([varlist{i},'{8}=true;']);
                    parameter_modified=true;
                end
            end
        end
    end

    function fun_pbhgroup7
        %  plotdev, iroute, iseg, title, xtitle, ytitle, frz, xmin1d, xmax1d, ifd, dxzmod
        dlg_title = 'No Longer Used Parameters for Linux';
        prompt{1} = [char(13,10)','\fontsize{12}plotdev: ',plotdev{4},char(13,10)','plotdev: ',plotdev{3}];
        prompt{2} = [char(13,10)',char(13,10)','\fontsize{12}iroute: ',iroute{4},char(13,10)','iroute: ',iroute{3},'\color{red} possible value: ',num2str(iroute{9})];
        prompt{3} = [char(13,10)','\fontsize{12}iseg: ',iseg{4},char(13,10)','iseg: ',iseg{3},'\color{red} possible value: ',num2str(iseg{9})];
        prompt{4} = [char(13,10)','\fontsize{12}title: ',title{3}];
        prompt{5} = [char(13,10)','\fontsize{12}xtitle: ',xtitle{3}];
        prompt{6} = [char(13,10)','\fontsize{12}ytitle: ',ytitle{3}];
        num_lines = [1,200];
        def = {plotdev{7} num2str(iroute{7}) num2str(iseg{7}) title{7} num2str(xtitle{7}) num2str(ytitle{7})};
        options.Interpreter='tex';
        answer = fun_reviewdlg(prompt,dlg_title,num_lines,def,options);
%         if ~isempty(answer)
%             irout{7}=str2num(answer{1});
%             iseg{7}=str2num(answer{2});
%             title{7}=answer{3};
%             xtitle{7}=str2num(answer{4});
%             ytitle{7}=str2num(answer{5});
%             [irout{8} iseg{8} title{8} xtitle{8} ytitle{8}]=deal(true);
%             parameter_modified=true;
%         end
    end

    function fun_pbhgroup21
        %  orig, sep, iaxlab, albht
        dlg_title = 'Set origin coordinates, label size, ect of plot axes';
        varlist={'orig', 'sep', 'iaxlab', 'albht'};
        varnum=length(varlist);
        for i=1:varnum;
            if eval([varlist{i},'{8};']); % 当为true时以红色粗体提示该项目要输出到r.in
                ifout{i}=outlabel;
            else
                ifout{i}='';
            end
        end
        prompt{1} = [char(13,10)','\fontsize{12}',orig{4},ifout{1},char(13,10)','orig: ',orig{3}];
        prompt{2} = [char(13,10)','\fontsize{12}',sep{4},ifout{2},char(13,10)','sep: ',sep{3}];
        prompt{3} = [char(13,10)','\fontsize{12}',iaxlab{4},ifout{3},char(13,10)','iaxlab: ',iaxlab{3},'\color{red} possible value: ',num2str(iaxlab{9})];
        prompt{4} = [char(13,10)','\fontsize{12}',albht{4},ifout{4},char(13,10)','albht: ',albht{3}];
        num_lines = [1,200];
        def = {num2str(orig{7}) num2str(sep{7}) num2str(iaxlab{7}) num2str(albht{7})};
        options.Interpreter='tex';
        answer = inputdlg(prompt,dlg_title,num_lines,def,options);
        if ~isempty(answer);  % 这是为了检查是否点了cancel或者关闭窗口，此时返回的是空cell（不是空字符串！）
            ifsame=strcmpi(answer',def);  % 一一对应比较返回的答案是否与原来的相同。注意：answer返回的是列向量形式！
            for i=1:varnum;
                if ~ifsame(i);  % 如果第i个返回项跟原来不同
                    eval([varlist{i},'{7}=str2num(answer{',num2str(i),'});']);
                    eval([varlist{i},'{8}=true;']);
                    parameter_modified=true;
                end
            end
        end
    end

    function fun_pbhgroup22
        %  [xmin, xmax, xmm, xtmin, xtmax, ntickx, ndecix], [zmin, zmax, zmm, ztmin, ztmax, ntickz, ndeciz]
        [parameter_modified,xmin, xmax, xmm, xtmin, xtmax, ntickx, ndecix, zmin, zmax, zmm, ztmin, ztmax, ntickz, ndeciz]=...
            fun_rin_DDAxes(xmin, xmax, xmm, xtmin, xtmax, ntickx, ndecix, zmin, zmax, zmm, ztmin, ztmax, ntickz, ndeciz);

    end

    function fun_pbhgroup23
        %  itrev, [xmint, xmaxt, xmmt, xtmint, xtmaxt, ntckxt, ndecxt], [tmin, tmax, tmm, ttmin, ttmax, ntickt, ndecit]
        [parameter_modified,itrev, xmint, xmaxt, xmmt, xtmint, xtmaxt, ntckxt, ndecxt, tmin, tmax, tmm, ttmin, ttmax, ntickt, ndecit]=...
            fun_rin_TDAxes(itrev, xmint, xmaxt, xmmt, xtmint, xtmaxt, ntckxt, ndecxt, tmin, tmax, tmm, ttmin, ttmax, ntickt, ndecit);
    end

    function fun_pbhgroup31
        %  ifast, [i2pt, n2pt, x2pt], isrch, imodf, aamin, aamax, xsmax, [istop, stol], [step, smin, smax]
        [parameter_modified,ifast, i2pt, n2pt, x2pt, isrch, imodf, aamin, aamax, xsmax, istop, stol, step, smin, smax]=...
            fun_rin_General(ifast, i2pt, n2pt, x2pt, isrch, imodf, aamin, aamax, xsmax, istop, stol, step, smin, smax);
%         dlg_title = 'Parameters of General Control for Ray Tracing';
%         prompt{1} = ['\fontsize{12}ifast: ',ifast{3},'\color{red} possible value: ',num2str(ifast{9})];
%         prompt{2} = [char(13,10)','\fontsize{12}\color{blue}i2pt','\color{black}: ',i2pt{4},char(13,10)','i2pt: ',i2pt{3},'\color{red} possible value: ',num2str(i2pt{9})];
%         prompt{3} = ['\fontsize{12}\color{blue}n2pt','\color{black}: ',n2pt{3}];
%         prompt{4} = ['\fontsize{12}\color{blue}x2pt','\color{black}: ',x2pt{3}];
%
%
%         num_lines = [1,200];
%         def = {nu2str(ifast{7}) num2str(i2pt{7}) num2str(n2pt{7}) num2str(x2pt{7})};
%         options.Interpreter='tex';
%         answer = inputdlg(prompt,dlg_title,num_lines,def,options);
%         if ~isempty(answer)
%             ifast{7}=str2num(answer{1});
%             i2pt{7}=str2num(answer{2});
%             n2pt{7}=str2num(answer{3});
%             x2pt{7}=str2num(answer{4});
%             [ifast{8} i2pt{8} n2pt{8} x2pt{8}]=deal(true);
%             parameter_modified=true;
%         end
    end

    function fun_pbhgroup32
        %  [xshot, zshot, ishot], [ray, iturn, nray, nsmax, amin, amax, space]
        [parameter_modified,xshot,zshot,ishot,ray,iturn,nray,nsmax,amin,amax,space]=fun_rin_SourceRay(xshot,zshot,ishot,ray,iturn,nray,nsmax,amin,amax,space);
    end

    function fun_pbhgroup33
        %  idiff, crit, hws, nhary
        dlg_title = 'Special Parameters for Head Waves';
        varlist={'idiff','crit','hws', 'nhary'};
        varnum=length(varlist);
        for i=1:varnum;
            if eval([varlist{i},'{8};']); % 当为true时以红色粗体提示该项目要输出到r.in
                ifout{i}=outlabel;
            else
                ifout{i}='';
            end
        end
        prompt{1} = [char(13,10)','\fontsize{12}',idiff{4},ifout{1},char(13,10)','idiff: ',idiff{3},'\color{red}  Possible Value: ',num2str(idiff{9})];
        prompt{2} = [char(13,10)','\fontsize{12}',crit{4},ifout{2},char(13,10)','crit: ',crit{3}];
        prompt{3} = [char(13,10)','\fontsize{12}',hws{4},ifout{3},char(13,10)','hws: ',hws{3}];
        prompt{4} = [char(13,10)','\fontsize{12}',nhary{4},ifout{4},char(13,10)','nhary: ',nhary{3}];
        num_lines = [1,200];
        def = {num2str(idiff{7}) num2str(crit{7}) num2str(hws{7}) num2str(nhary{7})};
        options.Interpreter='tex';
        answer = inputdlg(prompt,dlg_title,num_lines,def,options);
        if ~isempty(answer);  % 这是为了检查是否点了cancel或者关闭窗口，此时返回的是空cell（不是空字符串！）
            ifsame=strcmpi(answer',def);  % 一一对应比较返回的答案是否与原来的相同。注意：answer返回的是列向量形式！
            for i=1:varnum;
                if ~ifsame(i);  % 如果第i个返回项跟原来不同
                    eval([varlist{i},'{7}=str2num(answer{',num2str(i),'});']);
                    eval([varlist{i},'{8}=true;']);
                    parameter_modified=true;
                end
            end
        end
    end

    function fun_pbhgroup34
        %  [ibsmth, npbnd, nbsmth], [xminns, xmaxns, insmth]
        dlg_title = 'Parameters for simulation of smooth layer boundary';
        varlist={'ibsmth','npbnd','nbsmth','insmth', 'xminns','xmaxns'};
        varnum=length(varlist);
        for i=1:varnum;
            if eval([varlist{i},'{8};']); % 当为true时以红色粗体提示该项目要输出到r.in
                ifout{i}=outlabel;
            else
                ifout{i}='';
            end
        end
        prompt{1} = [char(13,10)','\fontsize{12}',ibsmth{4},ifout{1},char(13,10)','\color{blue}ibsmth\color{black}: ',ibsmth{3},'\color{red}  Possible Value: ',num2str(ibsmth{9})];
        prompt{2} = [char(13,10)','\fontsize{12}',npbnd{4},ifout{2},char(13,10)','\color{blue}npbnd\color{black}: ',npbnd{3}];
        prompt{3} = [char(13,10)','\fontsize{12}',nbsmth{4},ifout{3},char(13,10)','\color{blue}nbsmth\color{black}: ',nbsmth{3}];
        prompt{4} = [char(13,10)',char(13,10)','\fontsize{12}当上述ibsmth=1 or 2，但又不想对所有层界面（或者层界面的一部分）进行光滑时，可以用下面的参数进行限制：',char(13,10)',...
            '在整型数组insmth中填入不想进行光滑的层界面编号，如果insmth保持缺省值0，则表示所有的层都会被光滑。',char(13,10)',...
            '进一步的，可以设定xminns和xmaxns，使得光滑仅在insmth中定义的这些层的[xminns,xmaxns]之外的部分才进行（缺省值分别为模型的左右边界xmin和xmax）。',char(13,10)',...
            '\color{magenta}insmth\color{black}: ',insmth{3},ifout{4}];
        prompt{5} = [char(13,10)','\fontsize{12}\color{magenta}xminns\color{black}: ',xminns{3},ifout{5}];
        prompt{6} = ['\fontsize{12}\color{magenta}xmaxns\color{black}: ',xmaxns{3},ifout{6}];
        num_lines = [1,200];
        def = {num2str(ibsmth{7}) num2str(npbnd{7}) num2str(nbsmth{7}) num2str(insmth{7}) num2str(xminns{7}) num2str(xmaxns{7})};
        options.Interpreter='tex';
        answer = inputdlg(prompt,dlg_title,num_lines,def,options);
        if ~isempty(answer);  % 这是为了检查是否点了cancel或者关闭窗口，此时返回的是空cell（不是空字符串！）
            ifsame=strcmpi(answer',def);  % 一一对应比较返回的答案是否与原来的相同。注意：answer返回的是列向量形式！
            for i=1:varnum;
                if ~ifsame(i);  % 如果第i个返回项跟原来不同
                    eval([varlist{i},'{7}=str2num(answer{',num2str(i),'});']);
                    eval([varlist{i},'{8}=true;']);
                    parameter_modified=true;
                end
            end
        end
    end

    function fun_pbhgroup35
        %  isrch, [ray, iturn, nrbnd, rbnd]
        [parameter_modified,isrch, ray, iturn, nrbnd, rbnd]=fun_rin_multiple(isrch, ray, iturn, nrbnd, rbnd);
    end

    function fun_pbhgroup36
        %  isrch, [ray, ncbnd, cbnd], pois, [poisb, poisl, poisbl]
        [parameter_modified,isrch, ray, ncbnd, cbnd, pois, poisb, poisl, poisbl]=fun_rin_PSwave(isrch, ray, ncbnd, cbnd, pois, poisb, poisl, poisbl);
    end

    function fun_pbhgroup37
        %  iraysl, [xshot, ishot, ray, irayt]
        [parameter_modified,iraysl,xshot,ishot,ray,irayt]=fun_rin_irayt(iraysl,xshot,ishot,ray,irayt);
    end

    function fun_pbhgroup38
        %  [ray, frbnd]
        [parameter_modified,ray,frbnd]=fun_rin_FR(ray,frbnd);
    end

    function fun_pbhgroup39
        %  nsmin, ntan
    end

    function fun_pbhgroup41
        %  invr, ivray
        dlg_title = 'Key Parameters for Inversion';
        varlist={'invr',  'ivray'};
        varnum=length(varlist);
        for i=1:varnum;
            if eval([varlist{i},'{8};']); % 当为true时以红色粗体提示该项目要输出到r.in
                ifout{i}=outlabel;
            else
                ifout{i}='';
            end
        end
        prompt{1} = [char(13,10)','\fontsize{12}',invr{4},ifout{1},char(13,10)','orig: ',invr{3}];
        prompt{2} = [char(13,10)',char(13,10)','\fontsize{12}',ivray{4},ifout{2},char(13,10)','ivray: ',ivray{3},char(13,10)','\color{red}Reference: ray=',num2str(ray{7})];
        num_lines = [1,200];
        def = {num2str(invr{7}) num2str(ivray{7})};
        options.Interpreter='tex';
        answer = inputdlg(prompt,dlg_title,num_lines,def,options);
        if ~isempty(answer);  % 这是为了检查是否点了cancel或者关闭窗口，此时返回的是空cell（不是空字符串！）
            ifsame=strcmpi(answer',def);  % 一一对应比较返回的答案是否与原来的相同。注意：answer返回的是列向量形式！
            for i=1:varnum;
                if ~ifsame(i);  % 如果第i个返回项跟原来不同
                    eval([varlist{i},'{7}=str2num(answer{',num2str(i),'});']);
                    eval([varlist{i},'{8}=true;']);
                    parameter_modified=true;
                end
            end
        end
    end

    function fun_pbhgroup42
        %  ximax, ttunc, bndunc, velunc
        dlg_title = 'Other Parameters for Inversion';
        varlist={'ximax','ttunc','bndunc', 'velunc'};
        varnum=length(varlist);
        for i=1:varnum;
            if eval([varlist{i},'{8};']); % 当为true时以红色粗体提示该项目要输出到r.in
                ifout{i}=outlabel;
            else
                ifout{i}='';
            end
        end
        prompt{1} = [char(13,10)','\fontsize{12}',ximax{4},ifout{1},char(13,10)','ximax: ',ximax{3}];
        prompt{2} = [char(13,10)',char(13,10)','\fontsize{12}',ttunc{4},ifout{2},char(13,10)','ttunc: ',ttunc{3}];
        prompt{3} = [char(13,10)',char(13,10)','\fontsize{12}',bndunc{4},ifout{3},char(13,10)','bndunc: ',bndunc{3}];
        prompt{4} = [char(13,10)',char(13,10)','\fontsize{12}',velunc{4},ifout{4},char(13,10)','velunc: ',velunc{3}];
        num_lines = [1,200];
        def = {num2str(ximax{7}) num2str(ttunc{7}) num2str(bndunc{7}) num2str(velunc{7})};
        options.Interpreter='tex';
        answer = inputdlg(prompt,dlg_title,num_lines,def,options);
        if ~isempty(answer);  % 这是为了检查是否点了cancel或者关闭窗口，此时返回的是空cell（不是空字符串！）
            ifsame=strcmpi(answer',def);  % 一一对应比较返回的答案是否与原来的相同。注意：answer返回的是列向量形式！
            for i=1:varnum;
                if ~ifsame(i);  % 如果第i个返回项跟原来不同
                    eval([varlist{i},'{7}=str2num(answer{',num2str(i),'});']);
                    eval([varlist{i},'{8}=true;']);
                    parameter_modified=true;
                end
            end
        end
    end


end   % end of tool_r_in_editor
