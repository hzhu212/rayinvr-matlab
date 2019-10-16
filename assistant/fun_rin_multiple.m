function [parameter_modified,isrch, ray, iturn, nrbnd, rbnd]=fun_rin_multiple(isrch, ray, iturn, nrbnd, rbnd)

parameter_modified=false;
names={'isrch', 'ray', 'iturn', 'nrbnd', 'rbnd'};
NN=length(names);
oldvalue={};
for i=1:NN;
    eval(['oldvalue{',num2str(i),'}=',names{i},';']);
end
batchmode=[];
tb=[];

%---- UI
if ishandle(235);
    controlh = 235;
    set(controlh,'Visible','on');
else
    controlh = figure(235);
    set(controlh,'Visible','off','Name','Including multiples','MenuBar','none','NumberTitle','off','Position',[400,50,700,650]); 
    %% top buttons
    toggleh=uicontrol(controlh,'Style','togglebutton','String','Press here to MODIFY!','HorizontalAlignment','left','FontWeight','bold','FontSize',12,...
        'Callback',@togglebutton_callback,'Units','normalized','Position',[.05 .94 0.4 .05],'ForegroundColor','r','Value',false);
    okpb=uicontrol(controlh,'Style','pushbutton','String','OK','Tag','OK','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.5 .94 0.2 .05],'ForegroundColor','blue','BackgroundColor','y');
    uicontrol(controlh,'Style','pushbutton','String','Cancel','Tag','Cancel','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.75 0.94 .2 .05],'ForegroundColor','blue','BackgroundColor','y');

    
    %% ----------- left panel
    leftp=uipanel(controlh,'Visible','on','Position',[.0 .0 1 0.935],'Title','Specify multiple reflection boundaries','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','k');
    p_isrch=uipanel(leftp,'Visible','on','Position',[.0 .0 1 0.3]);
    batchmode(1)=uicontrol(p_isrch,'Style','checkbox','Tag','1','String','Output  " isrch=1 "  to r.in','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@checkbox_callback,'Units','normalized','Position',[.25 .8 0.5 .2],'ForegroundColor','r','Value',isrch{7});
    usage=['isrch的说明：',char(13,10)',isrch{4},char(13,10)',char(13,10)','Usage of isrch: ',char(13,10)',isrch{3},char(13,10)'];
    uicontrol(p_isrch,'Style','edit','String',usage,'HorizontalAlignment','left','FontSize',9,'Units','normalized','Position',[.02 .01 0.96 .79],'Max',100,'Enable','Inactive');
    p_boundary=uipanel(leftp,'Visible','on','Position',[.0 .3 1 0.7]);
    tbdata=fun_make_table({ray{7},iturn{7},nrbnd{7},rbnd{7}});
    tb(1)=uitable(p_boundary,'Units','normalized','Position',[.01 .01 0.425 0.98],'ColumnName',{'ray','iturn','nrbnd','rbnd','Select'},'ColumnFormat',{'char','char','char','char','logical'},...
            'ColumnEditable',[true,true,true,true,true],'FontSize',10,'Data',tbdata,'ColumnWidth',{40 40 40 70 45},'Enable','Inactive');
    batchmode(2)=uicontrol(leftp,'Style','pushbutton','Tag','11','String','Append a new line','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@pushbutton_callback,'Units','normalized','Position',[.47 .92 0.5 .06],'ForegroundColor','k','TooltipString','Add a new line to the table end.');
    batchmode(3)=uicontrol(leftp,'Style','pushbutton','Tag','12','String','Delete the selected','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@pushbutton_callback,'Units','normalized','Position',[.47 .85 0.5 .06],'ForegroundColor','k','TooltipString','Delete the selected table lines!');
    batchmode(4)=uicontrol(leftp,'Style','pushbutton','String','Check All','Tag','11','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.45 .78 0.17 .06],'ForegroundColor','blue');
    batchmode(5)=uicontrol(leftp,'Style','pushbutton','String','Uncheck All','Tag','12','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.63 0.78 .175 .06],'ForegroundColor','blue');
    batchmode(6)=uicontrol(leftp,'Style','pushbutton','String','Flip Checks','Tag','13','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.815 .78 .175 .06],'ForegroundColor','blue');
    usage=['说明：',char(13,10)','iturn是',iturn{4},char(13,10)','nrbnd是',nrbnd{4},char(13,10)','rbnd是',rbnd{4},char(13,10)',char(13,10)','Usage of iturn: ',char(13,10)',iturn{3},char(13,10)',char(13,10)',...
        'Usage of nrbnd: ',char(13,10)',nrbnd{3},char(13,10)',char(13,10)','Usage of rbnd: ',char(13,10)',rbnd{3},char(13,10)'];
    uicontrol(p_boundary,'Style','edit','String',usage,'HorizontalAlignment','left','FontSize',9,'Units','normalized','Position',[.44 .01 0.55 .66],'Max',100,'Enable','Inactive');
    
   

    %------ others
    togglebutton_callback(toggleh);
    set(controlh,'Visible','on');
    set(controlh,'CloseRequestFcn',@my_closerequest);
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
            fun_batch_ui_switch([batchmode(1:6) tb(1)],'Enable','on');
            set(src,'String','Return REVIEW mode','ForegroundColor','b');
        else
            fun_batch_ui_switch(batchmode(1:6),'Enable','off');
            fun_batch_ui_switch(tb,'Enable','inactive');
            set(src,'String','Press here to MODIFY!','ForegroundColor','r');
        end
    end

    function checkbox_callback(src,event)
        tag=get(src,'Tag');
        value=get(src,'Value');
        switch tag
            case '1'
                isrch{7}=value;
                isrch{8}=logical(value);
            case '2'
                if value;  % =1时表明被选择，因此需要激活下面的按钮
                    fun_batch_ui_switch(batchmode(21:25),'Enable','on');
                    set(tb(2),'Enable','on');
                else
                    fun_batch_ui_switch(batchmode(21:25),'Enable','off');
                    set(tb(2),'Enable','Inactive');
                end
            case '3'
                if value;  % =1时表明被选择，因此需要激活下面的按钮
                    fun_batch_ui_switch(batchmode(31:35),'Enable','on');
                    set(tb(3),'Enable','on');
                else
                    fun_batch_ui_switch(batchmode(31:35),'Enable','off');
                    set(tb(3),'Enable','Inactive');
                end
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
        tb=cell(15,colnum+1);
        tb(:,1:end-1)={''};
        tb(:,end)={false};
        col1=col{1};
        col2=col{2};
        for i=1:length(col1);
            tb{i,1}=num2str(col1(i));
            if length(col2)>=i;
                tb{i,2}=num2str(col2(i));
            end
            tb{i,end}=false;
        end
        col3=col{3};
        col4=col{4};
        for i=1:length(col3);
            count=col3(i);
            tb{i,3}=num2str(count);
            if count==0;
                tb{i,4}='';
            else
                tb{i,4}=num2str(col4(1:count));
                col4(1:count)=[];
            end
        end
    end
 
    function fun_output
        % table 1: ray,nrbnd,rbnd
        data=get(tb(1),'Data');
        [c1 c2 c3 c4]=deal([]);
        for i=1:length(data(:,1))
            c1=[c1 str2num(data{i,1})];
            c2=[c2 str2num(data{i,2})];
            c3=[c3 str2num(data{i,3})];
            c4=[c4 str2num(data{i,4})];
        end
        ray{7}=c1;
        iturn{7}=c2; iturn{8}=true;
        nrbnd{7}=c3; nrbnd{8}=true;
        if isempty(c4)
            rbnd{7}=NaN; rbnd{8}=false;
        else
            rbnd{7}=c4; rbnd{8}=true;
        end
    end

end  % of function