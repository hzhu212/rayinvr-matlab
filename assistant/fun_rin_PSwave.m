function [parameter_modified,isrch, ray, ncbnd, cbnd, pois, poisb, poisl, poisbl]=fun_rin_PSwave(isrch, ray, ncbnd, cbnd, pois, poisb, poisl, poisbl)

parameter_modified=false;
names={'isrch', 'ray', 'ncbnd', 'cbnd', 'pois', 'poisb', 'poisl', 'poisbl'};
NN=length(names);
oldvalue={};
for i=1:NN;
    eval(['oldvalue{',num2str(i),'}=',names{i},';']);
end
batchmode=[];
tb=[];

%---- UI
if ishandle(236);
    controlh = 236;
    set(controlh,'Visible','on');
else
    controlh = figure(236);
    set(controlh,'Visible','off','Name','P wave <=> S wave parameters','MenuBar','none','NumberTitle','off','Position',[400,50,600,700]); 
    %% top buttons
    toggleh=uicontrol(controlh,'Style','togglebutton','String','Press here to MODIFY!','HorizontalAlignment','left','FontWeight','bold','FontSize',12,...
        'Callback',@togglebutton_callback,'Units','normalized','Position',[.005 .91 0.35 .08],'ForegroundColor','r','Value',false);
    bgh = uibuttongroup(controlh,'Title','','FontWeight','bold','FontSize',13,'Position',[.36 .91 .45 .08],'SelectionChangeFcn',@bgh_SelectionChangeFcn);
    uicontrol(bgh,'Style','radiobutton','String','Specify converting boundaries','Tag','boundary','Enable','on','Units','normalized','Position',[.01 .5 .99 .5],'FontWeight','bold','FontSize',12,'ForegroundColor','black');
    uicontrol(bgh,'Style','radiobutton','String','Change Poisson''s ratio','Tag','Poisson','Enable','on','Units','normalized','Position',[.01 .0 .99 .5],'FontWeight','bold','FontSize',12,'ForegroundColor','black');
    okpb=uicontrol(controlh,'Style','pushbutton','String','OK','Tag','OK','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.82 .95 0.175 .045],'ForegroundColor','blue','BackgroundColor','y');
    uicontrol(controlh,'Style','pushbutton','String','Cancel','Tag','Cancel','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.82 0.9 .175 .045],'ForegroundColor','blue','BackgroundColor','y');

    
    %% ----------- left panel
    leftp=uipanel(controlh,'Visible','on','Position',[.0 .0 1 0.905],'Title','Specify converting boundaries','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','k');
    p_isrch=uipanel(leftp,'Visible','on','Position',[.0 .0 1 0.3]);
    batchmode(1)=uicontrol(p_isrch,'Style','checkbox','Tag','1','String','Output  " isrch=1 "  to r.in','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@checkbox_callback,'Units','normalized','Position',[.25 .8 0.5 .2],'ForegroundColor','r','Value',isrch{7});
    usage=['isrch的说明：',char(13,10)',isrch{4},char(13,10)',char(13,10)','Usage of isrch: ',char(13,10)',isrch{3},char(13,10)'];
    uicontrol(p_isrch,'Style','edit','String',usage,'HorizontalAlignment','left','FontSize',9,'Units','normalized','Position',[.02 .01 0.96 .79],'Max',100,'Enable','Inactive');
    p_boundary=uipanel(leftp,'Visible','on','Position',[.0 .3 1 0.7]);
    tbdata=fun_make_table({ray{7},ncbnd{7},cbnd{7}},1);
    tb(1)=uitable(p_boundary,'Units','normalized','Position',[.01 .01 0.425 0.98],'ColumnName',{'ray','ncbnd','cbnd','Select'},'ColumnFormat',{'char','char','char','logical'},...
            'ColumnEditable',[true,true,true,true],'FontSize',10,'Data',tbdata,'ColumnWidth',{40 40 70 45},'Enable','Inactive');
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
    usage=['说明：',char(13,10)','ncbnd是',ncbnd{4},char(13,10)','cbnd是',cbnd{4},char(13,10)',char(13,10)','Usage of ncbnd: ',char(13,10)',ncbnd{3},...
        char(13,10)',char(13,10)','Usage of cbnd: ',char(13,10)',cbnd{3},char(13,10)'];
    uicontrol(p_boundary,'Style','edit','String',usage,'HorizontalAlignment','left','FontSize',9,'Units','normalized','Position',[.44 .01 0.55 .66],'Max',100,'Enable','Inactive');
    
    %% ----------- right panel
    rightp=uipanel(controlh,'Visible','off','Position',[.0 .0 1 0.905],'Title','Change Poisson''s ratio','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','k');
    p_pois=uipanel(rightp,'Visible','on','Position',[.0 .5 1 0.5]);
    tbdata=fun_make_table(pois(7),2);
    tb(2)=uitable(p_pois,'Units','normalized','Position',[.01 .01 0.425 0.98],'ColumnName',{'pois','Select'},'ColumnFormat',{'char','logical'},...
        'ColumnEditable',[true,true],'FontSize',10,'Data',tbdata,'ColumnWidth',{80 50},'Enable','Inactive');
    batchmode(7)=uicontrol(p_pois,'Style','checkbox','Tag','2','String','Poisson'' ratios of model layers','HorizontalAlignment','left','FontWeight','bold','FontSize',14,...
        'Callback',@checkbox_callback,'Units','normalized','Position',[.46 .9 0.54 .1],'ForegroundColor','r','TooltipString','Modify and output Poisson'' ratios of model layers');
    batchmode(21)=uicontrol(p_pois,'Style','pushbutton','Tag','21','String','Append a new line','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@pushbutton_callback,'Units','normalized','Position',[.45 .81 0.27 .1],'ForegroundColor','k','TooltipString','Add a new line to the table end.');
    batchmode(22)=uicontrol(p_pois,'Style','pushbutton','Tag','22','String','Delete the selected','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@pushbutton_callback,'Units','normalized','Position',[.725 .81 0.27 .1],'ForegroundColor','k','TooltipString','Delete the selected table lines!');
    batchmode(23)=uicontrol(p_pois,'Style','pushbutton','String','Check All','Tag','21','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.45 .7 0.17 .1],'ForegroundColor','blue');
    batchmode(24)=uicontrol(p_pois,'Style','pushbutton','String','Uncheck All','Tag','22','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.63 0.7 .175 .1],'ForegroundColor','blue');
    batchmode(25)=uicontrol(p_pois,'Style','pushbutton','String','Flip Checks','Tag','23','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.815 .7 .175 .1],'ForegroundColor','blue');
    usage=['说明：',char(13,10)','pois',pois{4},char(13,10)',char(13,10)','Usage of pois: ',char(13,10)',pois{3},char(13,10)'];
    uicontrol(p_pois,'Style','edit','String',usage,'HorizontalAlignment','left','FontSize',9,'Units','normalized','Position',[.44 .01 0.55 .66],'Max',100,'Enable','Inactive');
    
    p_poisbl=uipanel(rightp,'Visible','on','Position',[.0 .0 1 0.5]);
    tbdata=fun_make_table({poisl{7},poisb{7},poisbl{7}},3);
    tb(3)=uitable(p_poisbl,'Units','normalized','Position',[.01 .01 0.425 0.98],'ColumnName',{'poisl','poisb','poisbl','Select'},'ColumnFormat',{'char','char','char','logical'},...
        'ColumnEditable',[true,true,true,true],'FontSize',10,'Data',tbdata,'ColumnWidth',{40 40 70 45},'Enable','Inactive');
    batchmode(8)=uicontrol(p_poisbl,'Style','checkbox','Tag','3','String','Adjust model trapezoids','HorizontalAlignment','left','FontWeight','bold','FontSize',14,...
        'Callback',@checkbox_callback,'Units','normalized','Position',[.46 .9 0.54 .1],'ForegroundColor','r','TooltipString','Modify and output Poisson'' ratios within specific model trapezoids');
    batchmode(31)=uicontrol(p_poisbl,'Style','pushbutton','Tag','31','String','Append a new line','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@pushbutton_callback,'Units','normalized','Position',[.45 .81 0.27 .1],'ForegroundColor','k','TooltipString','Add a new line to the table end.');
    batchmode(32)=uicontrol(p_poisbl,'Style','pushbutton','Tag','32','String','Delete the selected','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@pushbutton_callback,'Units','normalized','Position',[.725 .81 0.27 .1],'ForegroundColor','k','TooltipString','Delete the selected table lines!');
    batchmode(33)=uicontrol(p_poisbl,'Style','pushbutton','String','Check All','Tag','31','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.45 .7 0.17 .1],'ForegroundColor','blue');
    batchmode(34)=uicontrol(p_poisbl,'Style','pushbutton','String','Uncheck All','Tag','32','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.63 0.7 .175 .1],'ForegroundColor','blue');
    batchmode(35)=uicontrol(p_poisbl,'Style','pushbutton','String','Flip Checks','Tag','33','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.815 .7 .175 .1],'ForegroundColor','blue');
    usage=['说明：',char(13,10)',poisbl{4},char(13,10)',char(13,10)','Usage of poisl: ',char(13,10)',poisl{3},char(13,10)',char(13,10)','Usage of poisb: ',char(13,10)',poisb{3},...
        char(13,10)',char(13,10)','Usage of poisbl: ',char(13,10)',poisbl{3},char(13,10)'];
    uicontrol(p_poisbl,'Style','edit','String',usage,'HorizontalAlignment','left','FontSize',9,'Units','normalized','Position',[.44 .01 0.55 .66],'Max',100,'Enable','Inactive');

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
            fun_batch_ui_switch([batchmode(1:8) tb(1)],'Enable','on');
            checkbox_callback(batchmode(7));
            checkbox_callback(batchmode(8));
            set(src,'String','Return REVIEW mode','ForegroundColor','b');
        else
            fun_batch_ui_switch(batchmode([1:8 21:25 31:35]),'Enable','off');
            fun_batch_ui_switch(tb,'Enable','inactive');
            set(src,'String','Press here to MODIFY!','ForegroundColor','r');
        end
    end

    function bgh_SelectionChangeFcn(hObject,eventdata)
        switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
            case 'boundary'
                set(leftp,'Visible','on');
                set(rightp,'Visible','off');
            case 'Poisson'
                set(rightp,'Visible','on');
                set(leftp,'Visible','off');
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
    function tb=fun_make_table(col,id)
        colnum=length(col);
        tb=cell(15,colnum+1);
        tb(:,1:end-1)={''};
        tb(:,end)={false};
        col1=col{1};
        for i=1:length(col1);
            tb{i,1}=num2str(col1(i));
            tb{i,end}=false;
            if id==3; % poisbl
                tb{i,2}=num2str(col{2}(i));
                tb{i,3}=num2str(col{3}(i));
            end
        end
        if id==1; % ncbnd
            col2=col{2};
            col3=col{3};
            for i=1:length(col2);
                count=col2(i);
                tb{i,2}=num2str(count);
                if count==0;
                    tb{i,3}='';
                else
                    tb{i,3}=num2str(col3(1:count));
                    col3(1:count)=[];
                end
            end
        end
    end
 
    function fun_output
        % table 1: ray,ncbnd,cbnd
        data=get(tb(1),'Data');
        [c1 c2 c3]=deal([]);
        for i=1:length(data(:,1))
            c1=[c1 str2num(data{i,1})];
            c2=[c2 str2num(data{i,2})];
            c3=[c3 str2num(data{i,3})];
        end
        ray{7}=c1;
        ncbnd{7}=c2; ncbnd{8}=true;
        if isempty(c3)
            cbnd{7}=NaN; cbnd{8}=false;
        else
            cbnd{7}=c3; cbnd{8}=true;
        end
        % table 2: pois
        data=get(tb(2),'Data');
        c1=[];
        for i=1:length(data(:,1))
            c1=[c1 str2num(data{i,1})];
        end
        if isempty(c1)
            pois{7}=NaN; cbnd{8}=false;
        else
            pois{7}=c1; pois{8}=true;
        end
        % table 3: poisl,poisb,poisbl
        data=get(tb(3),'Data');
        [c1 c2 c3]=deal([]);
        for i=1:length(data(:,1))
            c1=[c1 str2num(data{i,1})];
            c2=[c2 str2num(data{i,2})];
            c3=[c3 str2num(data{i,3})];
        end
        if length(c1)~=length(c2) || length(c2)~=length(c3) || length(c1)~=length(c3) || isempty(c1) || isempty(c2) || isempty(c3)
            poisl{8}=false; poisb{8}=false; poisbl{8}=false;
        else
            poisl{8}=true; poisb{8}=true; poisbl{8}=true;
            poisl{7}=c1; poisb{7}=c2; poisbl{7}=c3;
        end
    end

end  % of function