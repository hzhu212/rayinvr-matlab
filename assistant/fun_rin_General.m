function [parameter_modified,ifast, i2pt, n2pt, x2pt, isrch, imodf, aamin, aamax, xsmax, istop, stol, step, smin, smax]=fun_rin_General(ifast, i2pt, n2pt, x2pt, isrch, imodf, aamin, aamax, xsmax, istop, stol, step, smin, smax)

parameter_modified=false;
names={'ifast', 'i2pt', 'n2pt', 'x2pt', 'isrch', 'imodf', 'aamin', 'aamax', 'xsmax', 'istop', 'stol', 'step', 'smin', 'smax'};
list1={i2pt, n2pt, x2pt};
namelist1={'i2pt', 'n2pt', 'x2pt'};
list2={istop, stol};
namelist2={'istop', 'stol'};
list3={step, smin, smax};
namelist3={'step', 'smin', 'smax'};
list4={ifast, isrch, imodf};
namelist4={'ifast', 'isrch', 'imodf'};
list5={aamin, aamax, xsmax};
namelist5={'aamin', 'aamax', 'xsmax'};
NN=length(names);
oldvalue={};
for i=1:NN;
    eval(['oldvalue{',num2str(i),'}=',names{i},';']);
end
batchmode=[];
tb=[];

%---- UI
if ishandle(231);
    controlh = 231;
    set(controlh,'Visible','on');
else
    controlh = figure(231);
    set(controlh,'Visible','on','Name','General Control','MenuBar','none','NumberTitle','off','Position',[400,50,600,700]); 
    
    %% top buttons
    toggleh=uicontrol(controlh,'Style','togglebutton','String','Press here to MODIFY!','HorizontalAlignment','left','FontWeight','bold','FontSize',12,...
        'Callback',@togglebutton_callback,'Units','normalized','Position',[.005 .91 0.35 .08],'ForegroundColor','r','Value',false);
    bgh = uibuttongroup(controlh,'Title','','FontWeight','bold','FontSize',13,'Position',[.36 .91 .45 .08],'SelectionChangeFcn',@bgh_SelectionChangeFcn);
    uicontrol(bgh,'Style','radiobutton','String','Specify group parameter','Tag','group','Enable','on','Units','normalized','Position',[.01 .5 .99 .5],'FontWeight','bold','FontSize',12,'ForegroundColor','black');
    uicontrol(bgh,'Style','radiobutton','String','Change single parameter','Tag','single','Enable','on','Units','normalized','Position',[.01 .0 .99 .5],'FontWeight','bold','FontSize',12,'ForegroundColor','black');
    okpb=uicontrol(controlh,'Style','pushbutton','String','OK','Tag','OK','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.82 .95 0.175 .045],'ForegroundColor','blue','BackgroundColor','y');
    uicontrol(controlh,'Style','pushbutton','String','Cancel','Tag','Cancel','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.82 0.9 .175 .045],'ForegroundColor','blue','BackgroundColor','y');

 %% ----------- left panel
    leftp=uipanel(controlh,'Visible','on','Position',[.0 .0 1 0.90],'Title','Specify group parameter','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','k');
    p1=uipanel(leftp,'Visible','on','Position',[.0 .66 1 0.325]);
    p2=uipanel(leftp,'Visible','on','Position',[.0 .33 1 0.325]);
    p3=uipanel(leftp,'Visible','on','Position',[.0 .0 1 0.325]);
    
    tbdata1=fun_make_table(list1,namelist1);
    tb(1)=uitable(p1,'Units','normalized','Position',[.0 .0 0.44 1],'ColumnName',{'Name','Value','isOutput'},'ColumnFormat',{'char','numeric','logical'},...
        'ColumnEditable',[false,true,true],'FontSize',10,'Data',tbdata1,'ColumnWidth',{70 70 70},'Enable','Inactive');
    usage=['说明：',char(13,10)','这是一组用于控制两点法射线追踪的参数，其中i2pt开关的取值为[0 1 2]，缺省值为1（原始缺省值为0）。当i2pt为1时进行含有sources and observed receiver的两点法追踪，'...
        '程序会搜索连接震源（r.in）和观测接收点（tx.in）位置的射线的起飞角度（注意：仅针对列在ivray和tx.in中共有的走时射线组编号）,即只有从震源出发、真正到达接收器的射线才是有效射线，'...
        '这是反演的方式，射线数目跟tx.in有关，不完全由nray决定。因此，nray只要足够大即可（比如每个shot的有效射线数不再变化，或者总的搜索射线数不再变化）；'...
        '当i2pt为0时，射线完全由起飞角度决定，与接收器无关，因此，有效射线的数目=nray，即这是一种正演；i2pt=2专门针对floating reflector，'...
        '即只有那些能够在合适的floating reflector（如果frbnd>0）上进行反射的射线才会被追踪。',char(13,10)',...
        'n2pt是两点法追踪时可以进行的最大迭代次数，即对于每个接收点用于确定射线起飞角度的最大有效射线数目；缺省值为5。',char(13,10)',...
        'x2pt是两点法追踪时，如果某次迭代的射线终止点（在模型顶面）与该观测点的距离小于这个值（单位：km），即认为结果可以接受，即使迭代数没有达到n2pt也会停止迭代，转入下一个观测点。'...
        '缺省值为(xmax-xmin)/2000。'];
    usage=[usage char(13,10)',char(13,10)','Exlanation：',char(13,10)','i2pt:',char(13,10)',i2pt{3},char(13,10)',char(13,10)',...
        'n2pt:',char(13,10)',n2pt{3},char(13,10)',char(13,10)',char(13,10)','x2pt:',char(13,10)',x2pt{3},char(13,10)'];
    uicontrol(p1,'Style','edit','String',usage,'HorizontalAlignment','left','FontSize',9,'Units','normalized','Position',[.45 .0 0.54 1],'Max',100,'Enable','Inactive');
    
    tbdata2=fun_make_table(list2,namelist2);
    tb(2)=uitable(p2,'Units','normalized','Position',[.0 .0 0.44 1],'ColumnName',{'Name','Value','isOutput'},'ColumnFormat',{'char','numeric','logical'},...
        'ColumnEditable',[false,true,true],'FontSize',10,'Data',tbdata2,'ColumnWidth',{70 70 70},'Enable','Inactive');
    usage=['说明：',char(13,10)','这是一组用于控制射线追踪是否停止的条件。其中，istop开关的取值范围为[1 2]。当为缺省值1时，如果射线反射的界面没有列在ray或者rbnd数组中，',...
        '则射线追踪停止。当istop=2时，那么除了1的效果外，如果射线往下进入了比ray code（L.n）定义的层号L更深的层，则射线追踪停止。',char(13,10)',...
        'stol用于判断是否能进一步优化结果：如果连续两次迭代的射线终点距离小于这个数值（单位：km），则迭代终止。因此，如果令stol=0，则可以在搜索模式下保证总能使用nsmax条射线。缺省值为(xmax-xmin)/3500)。'];
    usage=[usage char(13,10)',char(13,10)','Exlanation：',char(13,10)','istop:',char(13,10)',istop{3},char(13,10)',char(13,10)',char(13,10)','stol:',char(13,10)',stol{3},char(13,10)'];
    uicontrol(p2,'Style','edit','String',usage,'HorizontalAlignment','left','FontSize',9,'Units','normalized','Position',[.45 .0 0.54 1],'Max',100,'Enable','Inactive');

    tbdata3=fun_make_table(list3,namelist3);
    tb(3)=uitable(p3,'Units','normalized','Position',[.0 .0 0.44 1],'ColumnName',{'Name','Value','isOutput'},'ColumnFormat',{'char','numeric','logical'},...
        'ColumnEditable',[false,true,true],'FontSize',10,'Data',tbdata3,'ColumnWidth',{70 70 70},'Enable','Inactive');
    usage=['说明：',char(13,10)','这是一组用于控制射线追踪时迭代步长值的参数。其中，step参数控制公式step length (km) = step*v/(|vx|+|vz|)，v是速度，'...
        'vx和vz分别是速度v对x和z的偏微分；缺省值为0.05。',char(13,10)','smin和smax分别是允许的最小和最大步长值step length (km)。缺省值分别为',char(13,10)',...
        '(xmax-xmin)/4500 和 (xmax-xmin)/15。'];
    usage=[usage char(13,10)',char(13,10)','Exlanation：',char(13,10)','step:',char(13,10)',step{3},char(13,10)',char(13,10)',...
        'smin:',char(13,10)',smin{3},char(13,10)',char(13,10)','smax:',char(13,10)',smax{3},char(13,10)'];
    uicontrol(p3,'Style','edit','String',usage,'HorizontalAlignment','left','FontSize',9,'Units','normalized','Position',[.45 .0 0.54 1],'Max',100,'Enable','Inactive');

%% ----------- right panel
    rightp=uipanel(controlh,'Visible','off','Position',[.0 .0 1 0.90],'Title','Change single parameter','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','k');
    p4=uipanel(rightp,'Visible','on','Position',[.0 .5 1 0.495]);
    p5=uipanel(rightp,'Visible','on','Position',[.0 .0 1 0.495]);
    
    tbdata4=fun_make_table(list4,namelist4);
    tb(4)=uitable(p4,'Units','normalized','Position',[.0 .0 0.44 1],'ColumnName',{'Name','Value','isOutput'},'ColumnFormat',{'char','numeric','logical'},...
        'ColumnEditable',[false,true,true],'FontSize',10,'Data',tbdata4,'ColumnWidth',{70 70 70},'Enable','Inactive');
    usage=['说明：',char(13,10)','ifast开关打开时（=1）使用没有错误控制的Runge-Kutta方法解射线追踪方程，比ifast=0时快30-40%，且精度相同。'...
        '因此，除非ifast=1出现明显错误，或者测试最终模型，都应该始终使用ifast=1。',char(13,10)',...
        'isrch开关保证程序能够对重复的ray code再次进行起飞角度的搜索，当ray中有相同的ray code重复出现时（ivray中有两个及以上的ray group对应同一个ray code导致起飞角度不同，'...
        '例如在nrbnd, rbnd, ncbnd, cbnd中指定了多次波和转换波的情况），必须将它设为1；缺省值为0。',char(13,10)',...
        'imodf开关打开（=1）时，程序将使用v.in中的速度模型；关闭时（=0）则使用r.in文件的第5部分（不推荐！）。'];
    usage=[usage char(13,10)',char(13,10)','Exlanation：',char(13,10)','ifast:',char(13,10)',ifast{3},char(13,10)',char(13,10)',...
        'isrch:',char(13,10)',isrch{3},char(13,10)',char(13,10)','imodf:',char(13,10)',imodf{3},char(13,10)'];
    uicontrol(p4,'Style','edit','String',usage,'HorizontalAlignment','left','FontSize',9,'Units','normalized','Position',[.45 .0 0.54 1],'Max',100,'Enable','Inactive');

    tbdata5=fun_make_table(list5,namelist5);
    tb(5)=uitable(p5,'Units','normalized','Position',[.0 .0 0.44 1],'ColumnName',{'Name','Value','isOutput'},'ColumnFormat',{'char','numeric','logical'},...
        'ColumnEditable',[false,true,true],'FontSize',10,'Data',tbdata5,'ColumnWidth',{70 70 70},'Enable','Inactive');
    usage=['说明：',char(13,10)','这是一组用于控制射线起飞角度的参数。其中，aamin是折射事件在第一层中的最小起飞角度（缺省值为5），aamax是L.2反射事件的最大起飞角度（缺省值为85）。',char(13,10)',...
        'xsmax则用于确定搜索模式下的L.2反射事件的最小起飞角度，使得（1）当iturn=1（仅考虑最简单的primary wave初至波）时，该L.2 ray group反射点的最大偏移距为xsmax/2 (km)，'...
        '（2）当iturn=0时，反射点的最大偏移距为xsmax (km)。如果要考察的是首波L.3，则xsmax是首波离开界面往上返回的最大偏移距。',char(13,10)',...
        '而xsmax=0可以保证（1）L.2反射事件搜索可以到达L层底界面所有区域的起飞角度，直到抵达模型边界；（2）L.3首波事件沿着L层界面（顶界面）追踪，直到抵达模型边界。缺省值为0.0。'];
    usage=[usage char(13,10)',char(13,10)','Exlanation：',char(13,10)','aamin:',char(13,10)',aamin{3},char(13,10)',char(13,10)',...
        'aamax:',char(13,10)',aamax{3},char(13,10)',char(13,10)','xsmax:',char(13,10)',xsmax{3},char(13,10)'];
    uicontrol(p5,'Style','edit','String',usage,'HorizontalAlignment','left','FontSize',9,'Units','normalized','Position',[.45 .0 0.54 1],'Max',100,'Enable','Inactive');

    %------ others
    togglebutton_callback(toggleh);
    set(controlh,'CloseRequestFcn',@my_closerequest)
end
    uiwait(controlh);  % 等待这个窗口界面关闭后再把数据回传，否则无法把变化保存下来
    
    %% ----- Callback Functions ------%
    function my_closerequest(hObject, eventdata)
        selection = questdlg('Do you want to save the changes before exit?',...
            'Close Request Function','Yes','No','Cancel','Cancel');
        switch selection,
            case 'Yes'
                exit_callback(okpb);
            case 'No'
                parameter_modified=false;
                for i=1:NN;
                    eval([names{i},'=oldvalue{',num2str(i),'};']);
                end
                delete(controlh);
            case 'Cancel'
        end
    end

    function exit_callback(src,event)
        switch get(src,'Tag')
            case 'OK'
                selection = questdlg('Save changes and exit?',...
                    'Close Request Function','Yes','Cancel','Cancel');
                switch selection
                    case 'Yes'
                        fun_output;
                        parameter_modified=true;
                        delete (controlh);
                end
            case 'Cancel'
                selection = questdlg('Are you sure to give up the changes and exit?',...
                    'Close Request Function','Yes','Cancel','Cancel');
                switch selection
                    case 'Yes'
                        parameter_modified=false;
                        for i=1:NN;
                            eval([names{i},'=oldvalue{',num2str(i),'};']);
                        end
                        delete (controlh);
                end
        end
    end

    function togglebutton_callback(src,event)
        if get(src,'Value')  % Value=1时按下
            fun_batch_ui_switch(tb,'Enable','on');
            set(src,'String','Return REVIEW mode','ForegroundColor','b');
        else
            fun_batch_ui_switch(tb,'Enable','inactive');
            set(src,'String','Press here to MODIFY!','ForegroundColor','r');
        end
    end

    function bgh_SelectionChangeFcn(hObject,eventdata)
        switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
            case 'group'
                set(leftp,'Visible','on');
                set(rightp,'Visible','off');
            case 'single'
                set(rightp,'Visible','on');
                set(leftp,'Visible','off');
        end
    end

    %% ----- Tool Functions ------%
    function fun_output
        for i=1:5
            tbData=get(tb(i),'Data');
            [m,n]=size(tbData);
            for j=1:m
               eval([tbData{j,1},'{7}=tbData{j,2};']);
               eval([tbData{j,1},'{8}=tbData{j,3};']);
            end
        end
    end

    function tb=fun_make_table(list,namelist)
        tb = cell(length(list),3);
        for i=1:length(list)
            tb{i,1} = namelist{i};
            tb{i,2}=list{i}{7};
            tb{i,3}=list{i}{8};
        end
    end


end