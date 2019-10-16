function [parameter_modified,xmin, xmax, xmm, xtmin, xtmax, ntickx, ndecix, zmin, zmax, zmm, ztmin, ztmax, ntickz, ndeciz]=...
    fun_rin_DDAxes(xmin, xmax, xmm, xtmin, xtmax, ntickx, ndecix, zmin, zmax, zmm, ztmin, ztmax, ntickz, ndeciz)


parameter_modified=false;
names={'xmin', 'xmax', 'xmm', 'xtmin', 'xtmax', 'ntickx', 'ndecix', 'zmin', 'zmax', 'zmm', 'ztmin', 'ztmax', 'ntickz', 'ndeciz'};

%%ndecix};!!!ndecix这个参数有多个缺省值！！没处理
distanceParameter={xmin, xmax, xmm, xtmin, xtmax, ntickx};
disPName={'xmin', 'xmax', 'xmm', 'xtmin', 'xtmax', 'ntickx', 'ndecix'};

%%ndeciz};!!!ndeciz这个参数有多个缺省值！！没处理
depthParameter={zmin, zmax, zmm, ztmin, ztmax, ntickz};
dthPName={'zmin', 'zmax', 'zmm', 'ztmin', 'ztmax', 'ntickz', 'ndeciz'};
%%allParameter=[distanceParameter,depthParameter];
NN=length(names);
oldvalue={};
tb=[];
batchmode=[];
for i=1:NN;
    eval(['oldvalue{',num2str(i),'}=',names{i},';']);
end

%---- UI
if ishandle(222);
    controlh = 222;
    set(controlh,'Visible','on');
else
    controlh = figure(222);
    set(controlh,'Visible','on','Name','Set Depth-Distance Axes Parameters','MenuBar','none','NumberTitle','off','Position',[200,100,800,600]); 
    
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
    textBox = uicontrol(LeftPanel,'Style','text','String',['xmin Explanation',char(13,10)',char(13,10)',xmin{4},char(13,10)',char(13,10)',xmin{3}],...
        'Units','normalized','Position',[0 .1 1 .77],'FontWeight','bold','FontSize',12,'ForegroundColor','blue','BackgroundColor','w');
    
    MiddlePanel = uipanel(controlh,'Visible','on','Position',[0.333 .0 0.333 .9],'Title','Distance Axis','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','k');
    tbDataDis = fun_make_table(distanceParameter,disPName,{7,8});
    tb(1) = uitable(MiddlePanel,'Tag','distance','Units','normalized','Position',[0 .1 1 .85],...
    'ColumnName',{'Name','Value','isOutput'},'ColumnFormat',{'char','numeric','logical'},...
    'ColumnEditable',[false true true],'ColumnWidth',{70 70 70},'FontSize',9,'Data',tbDataDis,'Enable','Inactive','CellSelectionCallback',@cellselect_callback);
    batchmode(1)=uicontrol(MiddlePanel,'Style','pushbutton','String','All','Tag','11','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[0 0.025 0.333 .05],'ForegroundColor','blue','Enable','off');
    batchmode(2)=uicontrol(MiddlePanel,'Style','pushbutton','String','Clear','Tag','12','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[0.333 0.025 0.333 .05],'ForegroundColor','blue','Enable','off');
    batchmode(3)=uicontrol(MiddlePanel,'Style','pushbutton','String','Flip','Tag','13','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[0.666 0.025 0.333 .05],'ForegroundColor','blue','Enable','off');
    
    RightPanel = uipanel(controlh,'Visible','on','Position',[0.666 .0 0.333 .9],'Title','Depth Axis','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','k');
    tbDataDth = fun_make_table(depthParameter,dthPName,{7,8});
    tb(2) = uitable(RightPanel,'Tag','depth','Units','normalized','Position',[0 .1 1 .85],...
        'ColumnName',{'Name','Value','isOutput'},'ColumnFormat',{'char','numeric','logical'},...
        'ColumnEditable',[false true true],'ColumnWidth',{70 70 70},'FontSize',9,'Data',tbDataDth,'Enable','Inactive','CellSelectionCallback',@cellselect_callback);
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
                        output({7,8});
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
       eval(['tempTextEN = ',selectedName,'{3};']);
       eval(['tempTextCN = ',selectedName,'{4};']);
       set(textBox,'String',[selectedName,' Explanation',char(13,10)',char(13,10)',tempTextCN,char(13,10)',char(13,10)',tempTextEN]);
    end

    function cellselect_callback(src,event)
        switch get(src,'tag')
            case 'distance'
                base=0;
            case 'depth'
                base=7;
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
            fun_batch_ui_switch([batchmode(1:6) tb],'Enable','on');
            set(src,'String','Return REVIEW mode','ForegroundColor','b');
        else
            fun_batch_ui_switch(batchmode(1:6),'Enable','off');
            fun_batch_ui_switch(tb,'Enable','inactive');
            set(src,'String','Press here to MODIFY!','ForegroundColor','r');
        end
    end
%% ----- Tool Functions ------%(数据按numeric处理)
    function output(index)
        %output the data changes!
        tbData=get(tb(1),'Data');
        for i=1:length(distanceParameter)
            for j=1:length(index)
                eval([tbData{i,1},'{index{j}}=tbData{i,j+1};']);
            end
        end
        tbData=get(tb(2),'Data');
        for i=1:length(depthParameter)
            for j=1:length(index)
                eval([tbData{i,1},'{index{j}}=tbData{i,j+1};']);
            end
        end
    end

    function tb=fun_make_table(list,namelist,colIndex)
        tb = cell(length(list),length(colIndex)+1);
        for i=1:length(list)
            tb{i,1} = namelist{i};
            for j=1:length(colIndex)
                tb{i,j+1}=list{i}{colIndex{j}};
            end
        end
    end

end

