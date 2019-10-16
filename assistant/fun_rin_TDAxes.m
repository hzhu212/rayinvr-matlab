function [parameter_modified,itrev, xmint, xmaxt, xmmt, xtmint, xtmaxt, ntckxt, ndecxt, tmin, tmax, tmm, ttmin, ttmax, ntickt, ndecit]=...
    fun_rin_TDAxes(itrev, xmint, xmaxt, xmmt, xtmint, xtmaxt, ntckxt, ndecxt, tmin, tmax, tmm, ttmin, ttmax, ntickt, ndecit)
%数据用char处理，可以显示多个缺省值，但不能修改保存

parameter_modified=false;
names={'itrev', 'xmint', 'xmaxt', 'xmmt', 'xtmint', 'xtmaxt', 'ntckxt', 'ndecxt', 'tmin', 'tmax', 'tmm', 'ttmin', 'ttmax', 'ntickt', 'ndecit'};
distanceParameter={xmint, xmaxt, xmmt, xtmint, xtmaxt, ntckxt, ndecxt};
disPName={'xmint', 'xmaxt', 'xmmt', 'xtmint', 'xtmaxt', 'ntckxt', 'ndecxt'};
timeParameter={tmin, tmax, tmm, ttmin, ttmax, ntickt, ndecit};
timePName={'tmin', 'tmax', 'tmm', 'ttmin', 'ttmax', 'ntickt', 'ndecit'};
NN=length(names);
oldvalue={};
tb=[];
batchmode=[];
for i=1:NN;
    eval(['oldvalue{',num2str(i),'}=',names{i},';']);
end

%---- UI
if ishandle(223);
    controlh = 223;
    set(controlh,'Visible','on');
else
    controlh = figure(223);
    set(controlh,'Visible','on','Name','Set Time-Distance Axes Parameters','MenuBar','none','NumberTitle','off','Position',[200,100,800,600]); 

    %% top buttons
    toggleh=uicontrol(controlh,'Style','togglebutton','String','Press here to MODIFY!','HorizontalAlignment','left','FontWeight','bold','FontSize',12,...
        'Callback',@togglebutton_callback,'Units','normalized','Position',[.3335 .91 0.32 .08],'ForegroundColor','r','Value',false);
    okpb=uicontrol(controlh,'Style','pushbutton','String','OK','Tag','OK','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.66 .925 0.16 .05],'ForegroundColor','blue','BackgroundColor','y');
    uicontrol(controlh,'Style','pushbutton','String','Cancel','Tag','Cancel','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.83 0.925 .16 .05],'ForegroundColor','blue','BackgroundColor','y');
   
   %% ----------- panels  
    LeftPanel = uipanel(controlh,'Visible','on','Position',[.0 .0 0.333 .98],'Title','Parameter Explanation','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','k');
    poph = uicontrol(LeftPanel,'Style','popup','String',names,'Units','normalized','Position',[0 0 1 .97],...
        'FontWeight','bold','FontSize',12,'Callback',@pop_callback);
    textBox = uicontrol(LeftPanel,'Style','text','String',['itrev Explanation',char(13,10)',char(13,10)',itrev{4},char(13,10)',char(13,10)',itrev{3}],...
        'Units','normalized','Position',[0 .1 1 .77],'FontWeight','bold','FontSize',12,'ForegroundColor','blue','BackgroundColor','w');
    batchmode(7)=uicontrol(LeftPanel,'Style','checkbox','String','itrev=1','HorizontalAlignment','left','FontWeight','bold','FontSize',14,...
        'Callback',@checkbox_callback,'Value',itrev{7},'Units','normalized','Position',[.32 .02 0.54 .08],'ForegroundColor','r',...
        'TooltipString',[itrev{3},char(13,10)',itrev{4}],'Enable','off');
    
    MiddlePanel = uipanel(controlh,'Visible','on','Position',[0.333 .0 0.333 .9],'Title','Time Axis','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','k');
    tbDataTime = fun_make_table(timeParameter,timePName);
    tb(1) = uitable(MiddlePanel,'Tag','time','Units','normalized','Position',[0 .1 1 .85],...
    'ColumnName',{'Name','Value','isOutput'},'ColumnFormat',{'char','char','logical'},...
    'ColumnEditable',[false true true],'ColumnWidth',{70 70 70},'FontSize',9,'Data',tbDataTime,'Enable','Inactive','CellSelectionCallback',@cellselect_callback);
    batchmode(1)=uicontrol(MiddlePanel,'Style','pushbutton','String','All','Tag','11','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[0 0.025 0.333 .05],'ForegroundColor','blue','Enable','off');
    batchmode(2)=uicontrol(MiddlePanel,'Style','pushbutton','String','Clear','Tag','12','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[0.333 0.025 0.333 .05],'ForegroundColor','blue','Enable','off');
    batchmode(3)=uicontrol(MiddlePanel,'Style','pushbutton','String','Flip','Tag','13','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[0.666 0.025 0.333 .05],'ForegroundColor','blue','Enable','off');
    
    RightPanel = uipanel(controlh,'Visible','on','Position',[0.666 .0 0.333 .9],'Title','Distance Axis','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','k');
    tbDataDis = fun_make_table(distanceParameter,disPName);
    tb(2) = uitable(RightPanel,'Tag','distance','Units','normalized','Position',[0 .1 1 .85],...
        'ColumnName',{'Name','Value','isOutput'},'ColumnFormat',{'char','char','logical'},...
        'ColumnEditable',[false true true],'ColumnWidth',{70 70 70},'FontSize',9,'Data',tbDataDis,'Enable','Inactive','CellSelectionCallback',@cellselect_callback);
    batchmode(4)=uicontrol(RightPanel,'Style','pushbutton','String','All','Tag','21','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[0 0.025 0.333 .05],'ForegroundColor','blue','Enable','off');
    batchmode(5)=uicontrol(RightPanel,'Style','pushbutton','String','Clear','Tag','22','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[0.333 0.025 0.333 .05],'ForegroundColor','blue','Enable','off');
    batchmode(6)=uicontrol(RightPanel,'Style','pushbutton','String','Flip','Tag','23','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[0.666 0.025 0.333 .05],'ForegroundColor','blue','Enable','off');
    
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

    function pop_callback(src,event)
       index = get(src,'Value');
       nameList = get(src,'String');
       selectedName = nameList(index);
       selectedName = selectedName{1};
       tempTextEN='';
       tempTextCN='';
       eval(['tempTextEN = ',selectedName,'{3}']);
       eval(['tempTextCN = ',selectedName,'{4}']);
       set(textBox,'String',[selectedName,' Explanation',char(13,10)',char(13,10)',tempTextCN,char(13,10)',char(13,10)',tempTextEN]);
    end

    function cellselect_callback(src,event)
        switch get(src,'tag')
            case 'distance'
                base=1;
            case 'time'
                base=8;
        end
        rowcol=event.Indices;
        row=rowcol(1,1);
        set(poph,'value',base+row);
        pop_callback(poph);
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

    function togglebutton_callback(src,event)
        if get(src,'Value')  % Value=1时按下
            fun_batch_ui_switch([batchmode(1:7) tb],'Enable','on');
            set(src,'String','Return REVIEW mode','ForegroundColor','b');
        else
            fun_batch_ui_switch(batchmode(1:7),'Enable','off');
            fun_batch_ui_switch(tb,'Enable','inactive');
            set(src,'String','Press here to MODIFY!','ForegroundColor','r');
        end
    end

    function checkbox_callback(src,event)
        set(poph,'value',1);
        pop_callback(poph);
        value=get(src,'Value');
        itrev{7}=value;
        itrev{8}=logical(value);
    end

%% ----- Tool Functions ------%(数据按char处理)
    function fun_output
        tbData=get(tb(1),'Data');
        for i=1:(length(timeParameter)-1) %此组中最后一个参数ndecit有多个值，str2num处理不了，所以先不包括
            eval([tbData{i,1},'{7}=',tbData{i,2},';']);
            eval([tbData{i,1},'{8}=tbData{i,3};']);
        end
        tbData=get(tb(2),'Data');
        for j=1:(length(distanceParameter)-1) %此组中最后一个参数ndecxt有多个值，str2num处理不了，所以先不包括
            eval([tbData{j,1},'{7}=',tbData{j,2},';']);
            eval([tbData{j,1},'{8}=tbData{j,3};']);
        end
    end

    function tb=fun_make_table(list,namelist)
        tb = cell(length(list),3);
        for i=1:length(list)
            tb{i,1} = namelist{i};
            tb{i,2} = num2str(list{i}{7});
            tb{i,3} = list{i}{8};
        end
    end

end