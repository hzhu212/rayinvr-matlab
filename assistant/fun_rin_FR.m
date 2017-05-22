function [parameter_modified,ray, frbnd]=fun_rin_FR(ray, frbnd)

parameter_modified=false;
names={'ray','frbnd'};
NN=length(names);
oldvalue={};
for i=1:NN;
    eval(['oldvalue{',num2str(i),'}=',names{i},';']);
end
batchmode=[];

%---- UI
if ishandle(238);
    controlh = 238;
    set(controlh,'Visible','on');
else
    controlh = figure(238);
    set(controlh,'Visible','on','Name','Floating reflectors','MenuBar','none','NumberTitle','off','Position',[350,75,700,650]); 

    toggleh=uicontrol(controlh,'Style','togglebutton','String','Press here to MODIFY!','HorizontalAlignment','left','FontWeight','bold','FontSize',12,...
        'Callback',@togglebutton_callback,'Units','normalized','Position',[.05 .94 0.4 .05],'ForegroundColor','r','Value',false);
    okpb=uicontrol(controlh,'Style','pushbutton','String','OK','Tag','OK','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.5 .94 0.2 .05],'ForegroundColor','blue','BackgroundColor','y');
    uicontrol(controlh,'Style','pushbutton','String','Cancel','Tag','Cancel','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.75 0.94 .2 .05],'ForegroundColor','blue','BackgroundColor','y');

    leftp=uipanel(controlh,'Visible','on','Position',[.0 .0 1 0.935],'Title','Specify floating reflectors','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','k');
    tbdata=fun_make_table(ray,frbnd);
    tb=uitable(leftp,'Units','normalized','Position',[.01 .01 0.425 0.98],'ColumnName',{'ray','frbnd','Select'},'ColumnFormat',{'char','char','logical'},...
            'ColumnEditable',[true,true,true],'FontSize',10,'Data',tbdata,'ColumnWidth',{70 70 70},'Enable','Inactive');
    batchmode(1)=uicontrol(leftp,'Style','pushbutton','Tag','1','String','Append a new line','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@pushbutton_callback,'Units','normalized','Position',[.47 .92 0.5 .06],'ForegroundColor','k','TooltipString','Add a new line to the table end.');
    batchmode(2)=uicontrol(leftp,'Style','pushbutton','Tag','2','String','Delete the selected','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@pushbutton_callback,'Units','normalized','Position',[.47 .85 0.5 .06],'ForegroundColor','k','TooltipString','Delete the selected table lines!');
    batchmode(3)=uicontrol(leftp,'Style','pushbutton','String','Check All','Tag','1','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.45 .78 0.17 .06],'ForegroundColor','blue');
    batchmode(4)=uicontrol(leftp,'Style','pushbutton','String','Uncheck All','Tag','2','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.63 0.78 .175 .06],'ForegroundColor','blue');
    batchmode(5)=uicontrol(leftp,'Style','pushbutton','String','Flip Checks','Tag','3','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.815 .78 .175 .06],'ForegroundColor','blue');
    usage=['Explanation：',char(13,10)','ray:',char(13,10)',ray{3},char(13,10)',ray{4},char(13,10)',char(13,10)','frbnd:',char(13,10)',frbnd{3},char(13,10)',frbnd{4}];
    uicontrol(leftp,'Style','edit','String',usage,'HorizontalAlignment','left','FontSize',9,'Units','normalized','Position',[.44 .01 .55 .76],'Max',100,'Enable','Inactive');
    %uicontrol(leftp,'Style','edit','String','test','HorizontalAlignment','left','FontSize',9,'Units','normalized','Position',[.44 .01 .55 .76],'Max',100,'Enable','Inactive');
    
    togglebutton_callback(toggleh);
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
            fun_batch_ui_switch([batchmode(1:5) tb],'Enable','on');
            set(src,'String','Return REVIEW mode','ForegroundColor','b');
        else
            fun_batch_ui_switch(batchmode(1:5),'Enable','off');
            fun_batch_ui_switch(tb,'Enable','Inactive');
            set(src,'String','Press here to MODIFY!','ForegroundColor','r');
        end
    end

    function UISwith(flag)
        if(strcmp(flag,'off'))
            set(tb,'Enable','Inactive');
            for i=1:length(batchmode)
                set(batchmode{i},'Enable','off');
            end
        else
            set(tb,'Enable','on');
            for i=1:length(batchmode)
                set(batchmode{i},'Enable','on');
            end
        end
        
    end
    
    function pushbutton_callback(src,event)
        tag=get(src,'Tag');
        tdata=get(tb,'Data');
        cc=length(get(tb,'ColumnName'));
        newline=cell(1,cc);
        newline(1:end-1)={''};
        newline(end)={false};
        switch tag
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
        set(tb,'Data',tdata);
    end
   
    function setcheck_callback(src,event)
        tag=get(src,'Tag');
        table1data=get(tb,'Data');
        switch tag;
            case '1'  % check all
                table1data(:,end)={true};
            case '2' % clear all checks
                table1data(:,end)={false};
            case '3' % flip check selections
                table1data(:,end)=num2cell(logical(~cell2mat(table1data(:,end))));
        end
        set(tb,'Data',table1data);
    end

    %% Tool functions
    function tb=fun_make_table(ray,frbnd)
        tb = cell(length(ray{7}),3);
        for i=1:length(ray{7})
            tb{i,1}=num2str(ray{7}(i));
            tb{i,2}=num2str(frbnd{7});
            tb{i,3}=false;
        end
    end
    
    function fun_output
        data=get(tb,'Data');
        [c1 c2]=deal([]);
        for i=1:length(data(:,1))
            c1=[c1 str2num(data{i,1})];
            c2=[c2 str2num(data{i,2})];
        end
        ray{7}=c1; 
        frbnd{7}=c2; 
        if (~strcmp(num2str(frbnd{7}),num2str(oldvalue{2}{7})))
            frbnd{8}=true;
        end
    end
    
end
    


