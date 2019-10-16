function [parameter_modified,xshot,zshot,ishot,ray,iturn,nray,nsmax,amin,amax,space]=fun_rin_SourceRay(xshot,zshot,ishot,ray,iturn,nray,nsmax,amin,amax,space)

parameter_modified=false;
names={'xshot', 'zshot', 'ishot', 'ray', 'iturn', 'nray', 'nsmax', 'amin', 'amax', 'space'};
NN=length(names);
oldvalue={};
for i=1:NN;
    eval(['oldvalue{',num2str(i),'}=',names{i},';']);
end
batchmode=[];
tb=[];

%---- UI
if ishandle(232);
    controlh = 232;
    set(controlh,'Visible','on');
else
    controlh = figure(232);
    set(controlh,'Visible','off','Name','Source & Ray L.n','MenuBar','none','NumberTitle','off','Position',[250,100,700,600]); 

    %% top buttons
    toggleh=uicontrol(controlh,'Style','togglebutton','String','Press here to MODIFY!','HorizontalAlignment','left','FontWeight','bold','FontSize',12,...
        'Callback',@togglebutton_callback,'Units','normalized','Position',[.005 .91 0.35 .08],'ForegroundColor','r','Value',false);
    bgh = uibuttongroup(controlh,'Title','','FontWeight','bold','FontSize',13,'Position',[.36 .91 .45 .08],'SelectionChangeFcn',@bgh_SelectionChangeFcn);
    uicontrol(bgh,'Style','radiobutton','String','Specify Source Parameters','Tag','source','Enable','on','Units','normalized','Position',[.01 .5 .99 .5],'FontWeight','bold','FontSize',12,'ForegroundColor','black');
    uicontrol(bgh,'Style','radiobutton','String','For Ray Code L.n','Tag','ray','Enable','on','Units','normalized','Position',[.01 .0 .99 .5],'FontWeight','bold','FontSize',12,'ForegroundColor','black');
    okpb=uicontrol(controlh,'Style','pushbutton','String','OK','Tag','OK','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.82 .95 0.175 .045],'ForegroundColor','blue','BackgroundColor','y');
    uicontrol(controlh,'Style','pushbutton','String','Cancel','Tag','Cancel','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.82 0.9 .175 .045],'ForegroundColor','blue','BackgroundColor','y');
    
    %% ----------- left panel
    leftp=uipanel(controlh,'Visible','on','Position',[.0 .0 1 0.90],'Title','Specify Source Parameters','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','k');
    tbdata=fun_make_table({xshot{7},zshot{7},ishot{7}});
    tb(1)=uitable(leftp,'Units','normalized','Position',[.01 .01 0.425 0.98],'ColumnName',{'xshot','zshot','ishot','Select'},'ColumnFormat',{'char','char','char','logical'},...
            'ColumnEditable',[true,true,true,true],'FontSize',10,'Data',tbdata,'ColumnWidth',{50 50 50 50},'Enable','Inactive');
    batchmode(1)=uicontrol(leftp,'Style','pushbutton','Tag','11','String','Append a new line','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@pushbutton_callback,'Units','normalized','Position',[.47 .92 0.5 .06],'ForegroundColor','k','TooltipString','Add a new line to the table end.');
    batchmode(2)=uicontrol(leftp,'Style','pushbutton','Tag','12','String','Delete the selected','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@pushbutton_callback,'Units','normalized','Position',[.47 .85 0.5 .06],'ForegroundColor','k','TooltipString','Delete the selected table lines!');
    batchmode(3)=uicontrol(leftp,'Style','pushbutton','String','Check All','Tag','11','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.45 .78 0.17 .06],'ForegroundColor','blue');
    batchmode(4)=uicontrol(leftp,'Style','pushbutton','String','Uncheck All','Tag','12','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.63 0.78 .175 .06],'ForegroundColor','blue');
    batchmode(5)=uicontrol(leftp,'Style','pushbutton','String','Flip Checks','Tag','13','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.815 .78 .175 .06],'ForegroundColor','blue');
    usage=['说明：',char(13,10)','这是一组用于定义震源source的参数。其中，xshot和zshot分别为震源在模型中的距离和深度位置（单位：km）。注意：xshot的缺省值为0；zshot可以为负值，'...
        '因为模型的顶可以高出海平面的0km（向下深度增加为正值）。如果r.in中没有定义zshot，那么实际上缺省的zshot值是从模型的第一个界面（即层1的顶）向下的一个很小的距离'...
        '（比如0.02 km，极限为0.00051 km），而不是从代表画图范围的那个距离-深度图的矩形框顶部开始算。',char(13,10)',...
        'ishot定义对应的震源进行射线追踪的方式：（1）ishot=0为不追踪；（2）=-1为仅追踪左半支；（3）=1为仅追踪右半支；（4）=2为左右两支都追踪。由于ishot的缺省值为0，'...
        '且ishot与xshot一一对应，因此，如果只改变ishot前面的部分，则后面剩余的就全是0。另外，经验表明，对于SCS的反射事件，仅追踪某一支可能并不安全。'];
    usage=[usage char(13,10)',char(13,10)','Exlanation：',char(13,10)','xshot:',char(13,10)',xshot{3},char(13,10)',char(13,10)',...
        'zshot:',char(13,10)',zshot{3},char(13,10)',char(13,10)','ishot:',char(13,10)',ishot{3},char(13,10)'];
    uicontrol(leftp,'Style','edit','String',usage,'HorizontalAlignment','left','FontSize',9,'Units','normalized','Position',[.44 .01 0.55 .74],'Max',100,'Enable','Inactive');
    
    %% ----------- right panel
    rightp=uipanel(controlh,'Visible','off','Position',[.0 .0 1 0.90],'Title','Change Ray L.n','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','k');
    tbdata=fun_make_table({ray{7}, iturn{7}, nray{7}, nsmax{7}, amin{7}, amax{7}, space{7}});
    tb(2)=uitable(rightp,'Units','normalized','Position',[.01 .51 0.99 0.5],'ColumnName',{'ray', 'iturn', 'nray', 'nsmax', 'amin', 'amax', 'space','Select'},'ColumnFormat',{'char','char','char','char','char','char','char','logical'},...
        'ColumnEditable',[true,true,true,true,true,true,true,true],'FontSize',10,'Data',tbdata,'ColumnWidth',{70 70 70 70 70 70 70 65},'Enable','Inactive');
    batchmode(21)=uicontrol(rightp,'Style','pushbutton','Tag','21','String','Append a new line','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@pushbutton_callback,'Units','normalized','Position',[.01 0.41 0.2 .08],'ForegroundColor','k','TooltipString','Add a new line to the table end.');
    batchmode(22)=uicontrol(rightp,'Style','pushbutton','Tag','22','String','Delete the selected','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@pushbutton_callback,'Units','normalized','Position',[.01 .31 0.2 .08],'ForegroundColor','k','TooltipString','Delete the selected table lines!');
    batchmode(23)=uicontrol(rightp,'Style','pushbutton','String','Check All','Tag','21','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.01 .21 0.2 .08],'ForegroundColor','blue');
    batchmode(24)=uicontrol(rightp,'Style','pushbutton','String','Uncheck All','Tag','22','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.01 0.11 .2 .08],'ForegroundColor','blue');
    batchmode(25)=uicontrol(rightp,'Style','pushbutton','String','Flip Checks','Tag','23','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.01 .01 .2 .08],'ForegroundColor','blue');
    usage=['说明：',char(13,10)','这是一组跟数组ray中的ray code一一对应的参数。ray code定义为L.n形式的小数，跟某层中的某种类型波相对应'...
        '（注意：tx.in和ivray中的ray group编码为整数，代表跟同一个L.n相关的所有走时）：',char(13,10)',...
        'L.1：在 L 地层中折射的射线轨迹；',char(13,10)',...
        'L.2：在 L 地层的底界面反射的射线轨迹；',char(13,10)',...
        'L.3：在 L 地层的底界面上滑行的首波的射线轨迹。',char(13,10)',...
        'iturn开关数组控制是否需要考虑多次波。当为缺省值1时，仅搜索最简单的primary wave（初至波）；当需要考虑包括层间反射等多次波的情况时，必须设为0 。',char(13,10)',...
        'nray数组指定要对L.n进行追踪的射线数目（缺省值为10）；与其它参数一样，如果只定义了一个值，则这个值会用到所有的ray code上。',char(13,10)',...
        'nsmax数组指定搜索起飞角度时的最大射线追踪数目。',char(13,10)',...
        'amin和amax数组分别指定起飞角度的最小和最大值（带正负符号进行比较）；无论是向左追踪还是向右追踪，水平位置为0度，向上为负角度，向下为正角度。注意：这两个参数仅用于ray=1.0的情况（例如水中直达波追踪）。',char(13,10)',...
        'space数组用于改变起飞角度在最小和最大值之间的间距：如果space=1，起飞角度间隔是均匀的；space>1，则起飞角度会集中在最小值附近；而0 < space < 1则会导致起飞角度集中在最大值附近。'...
        '缺省值为1；如果space=2，那么对于陆地反射事件（L.2）比较适合，而对于海面到海底的反射，可能0 < space < 1更适合，并且数值越小，射线越集中。'];
    usage=[usage char(13,10)',char(13,10)','Exlanation：',char(13,10)','ray:',char(13,10)',ray{3},char(13,10)',ray{4},char(13,10)',char(13,10)','iturn:',char(13,10)',iturn{3},char(13,10)',iturn{4},char(13,10)',char(13,10)','nray',char(13,10)',nray{3},char(13,10)',nray{4},char(13,10)',char(13,10)',...
        'nsmax:',char(13,10)',nsmax{3},char(13,10)',nsmax{4},char(13,10)',char(13,10)','amin:',char(13,10)',amin{3},char(13,10)',amin{4},char(13,10)',char(13,10)','amax',char(13,10)',amax{3},char(13,10)',amax{4},char(13,10)',char(13,10)','space:',char(13,10)',space{3},char(13,10)',space{4}];
    uicontrol(rightp,'Style','edit','String',usage,'HorizontalAlignment','left','FontSize',9,'Units','normalized','Position',[.22 .01 0.77 .49],'Max',100,'Enable','Inactive');
    
    %------ others
    togglebutton_callback(toggleh);
    set(controlh,'Visible','on');
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
            fun_batch_ui_switch([batchmode([1:5 21:25]),tb],'Enable','on');
            set(src,'String','Return REVIEW mode','ForegroundColor','b');
        else
            fun_batch_ui_switch(batchmode([1:5 21:25]),'Enable','off');
            fun_batch_ui_switch(tb,'Enable','inactive');
            set(src,'String','Press here to MODIFY!','ForegroundColor','r');
        end
    end

    function bgh_SelectionChangeFcn(hObject,eventdata)
        switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
            case 'source'
                set(leftp,'Visible','on');
                set(rightp,'Visible','off');
            case 'ray'
                set(rightp,'Visible','on');
                set(leftp,'Visible','off');
        end
    end

    function setcheck_callback(src,event)
        tag=get(src,'Tag');
        tnumber=str2num(tag(1));
        table1data=get(tb(tnumber),'Data');
        switch tag(2);
            case '1'  % check all
                table1data(:,end)={true};
            case '2' % clear all checks
                table1data(:,end)={false};
            case '3' % flip check selections
                table1data(:,end)=num2cell(logical(~cell2mat(table1data(:,end))));
        end
        set(tb(tnumber),'Data',table1data);
    end

    function pushbutton_callback(src,event)
        tag=get(src,'Tag');
        tnumber=str2num(tag(1));
        tdata=get(tb(tnumber),'data');
        cc=length(get(tb(tnumber),'ColumnName'));
        newline=cell(1,cc);
        newline(1:end-1)={''};
        newline(end)={false};
        switch tag(2)
            case '1' % append a new line
                tdata=[tdata; newline];
            case '2' % delete selected lines
                selection = questdlg('Are you sure to PERMANENT delete the selected lines?',...
                    'Delete confirm','Yes','Cancel','Cancel');
                switch selection
                    case 'Yes'
                        tdata(cell2mat(tdata(:,end)),:)=[];
                end         
        end
        set(tb(tnumber),'data',tdata);
    end

    %% Tool functions
    function tb=fun_make_table(col)
        colnum=length(col);
        MM=length(col{1}); %xshot/ray的长度可以涵盖其他数据长度
        tb=cell(MM,colnum+1);
        tb(:,1:end-1)={''};
        tb(:,end)={false};
        for j=1:colnum
            for i=1:length(col{j})
                tb{i,j}=num2str(col{j}(i));
            end
        end
    end

    function fun_output
        % table 1: source
        data=get(tb(1),'Data');
        [c1 c2 c3]=deal([]);
        for i=1:length(data(:,1))
            c1=[c1 str2num(data{i,1})];
            c3=[c3 str2num(data{i,3})];
        end
        for j=1:length(data(:,2)) %zshot与xshot、ishot长度可能不同
            c2=[c2 str2num(data{j,2})];
        end
        xshot{7}=c1; 
        zshot{7}=c2; 
        if (~strcmp(num2str(zshot{7}),num2str(oldvalue{2}{7})))
            zshot{8}=true;
        end
        ishot{7}=c3;
        
        % table 2: ray
        data=get(tb(2),'Data');
        [c1 c2 c3 c4 c5 c6 c7]=deal([]);
        for i=1:length(data(:,1)) %每一列长度可能不同；data(:,1)过滤不掉导入文件的空值
            if ~isempty(data(i,1)) %不能判断出非空数值
                c1=[c1 str2num(data{i,1})];
            end
        end
        for i=1:length(data(:,2))
            c2=[c2 str2num(data{i,2})];
        end
        for i=1:length(data(:,3))
            c3=[c3 str2num(data{i,3})];
        end
        for i=1:length(data(:,4))
            c4=[c4 str2num(data{i,4})];
        end
        for i=1:length(data(:,5))
            c5=[c5 str2num(data{i,5})];
        end
        for i=1:length(data(:,6))
            c6=[c6 str2num(data{i,6})];
        end
        for i=1:length(data(:,7))
            c7=[c7 str2num(data{i,7})];
        end
        ray{7}=c1;
        iturn{7}=c2;
        if (~strcmp(num2str(iturn{7}),num2str(oldvalue{5}{7})))
            iturn{8}=true;
        end
        nray{7}=c3;
        nsmax{7}=c4;
        amin{7}=c5;
        if (~strcmp(num2str(amin{7}),num2str(oldvalue{8}{7})))
            amin{8}=true;
        end
        amax{7}=c6;
        if (~strcmp(num2str(amax{7}),num2str(oldvalue{9}{7})))
            amax{8}=true;
        end
        space{7}=c7;
    end

end  % of function
