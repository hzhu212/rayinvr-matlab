function [parameter_modified,iraysl,xshot,ishot,ray,irayt]=fun_rin_irayt(iraysl,xshot,ishot,ray,irayt)

parameter_modified=false;
names={'iraysl','xshot','ishot','ray','irayt'};
NN=length(names);
oldvalue={};
for i=1:NN;
    eval(['oldvalue{',num2str(i),'}=',names{i},';']);
end
batchmode=[];

%---- UI
if ishandle(237);
    controlh = 237;
    set(controlh,'Visible','on');
else
    controlh = figure(237);
    set(controlh,'Visible','on','Name','Specify irayt','MenuBar','none','NumberTitle','off','Position',[250,75,800,650]); 

    toggleh=uicontrol(controlh,'Style','togglebutton','String','Currently iraysl=0, press to change to 1','HorizontalAlignment','left','FontWeight','bold','FontSize',12,...
        'Callback',@togglebutton_callback,'Units','normalized','Position',[.05 .94 0.4 .05],'ForegroundColor','b','Value',false,'TooltipString',[iraysl{4},char(13,10)',iraysl{3}]);
    okpb=uicontrol(controlh,'Style','pushbutton','String','OK','Tag','OK','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.5 .94 0.2 .05],'ForegroundColor','blue','BackgroundColor','y');
    uicontrol(controlh,'Style','pushbutton','String','Cancel','Tag','Cancel','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.75 0.94 .2 .05],'ForegroundColor','blue','BackgroundColor','y');
    
    leftp=uipanel(controlh,'Visible','on','Position',[.0 .0 1 0.935],'Title','Specify "irayt"  ("xshot", "zshot" and "ray" are uneditable)','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','k');
%     tbdata=fun_make_table(xshot,ishot,ray,irayt);
    tbdata=fun_make_table(xshot,ray,irayt);
    %以下在tb中设定xshot、ishot、ray不可改，因为是由原始数据生成的展开排列，若在此收集更改后的数据则不易处理重复情况，故若需更改参数可在其他按钮窗口更改；
    %另外，若前三项不可改，则append a new line意义不大？
    tb=uitable(leftp,'Units','normalized','Position',[.01 .01 0.475 0.98],'ColumnName',{'xshot','Direction','ray','irayt','Select'},'ColumnFormat',{'char','char','char','char','logical'},...
            'ColumnEditable',[false,false,false,true,true],'FontSize',10,'Data',tbdata,'ColumnWidth',{60 60 60 50 50},'Enable','Inactive');
    batchmode(1)=uicontrol(leftp,'Style','pushbutton','Tag','1','String','Set to 1','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@pushbutton_callback,'Units','normalized','Position',[.5 .92 0.47 .06],'ForegroundColor','k','TooltipString','Switch on the ray tracing.');
    batchmode(2)=uicontrol(leftp,'Style','pushbutton','Tag','2','String','Set to 0','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@pushbutton_callback,'Units','normalized','Position',[.5 .85 0.47 .06],'ForegroundColor','r','TooltipString','Switch off the ray tracing!');
    batchmode(3)=uicontrol(leftp,'Style','pushbutton','String','Check All','Tag','1','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.5 .78 0.15 .06],'ForegroundColor','blue');
    batchmode(4)=uicontrol(leftp,'Style','pushbutton','String','Uncheck All','Tag','2','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.66 0.78 .15 .06],'ForegroundColor','blue');
    batchmode(5)=uicontrol(leftp,'Style','pushbutton','String','Flip Checks','Tag','3','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.82 .78 .15 .06],'ForegroundColor','blue');
    usage=['说明：',char(13,10)','iraysl',iraysl{4},char(13,10)',...
        'irayt数组定义了某个shot是否追踪某组ray的开关（缺省为1，即要追踪），对应顺序如下：最外层的循环是xshot，内部依次是对应该xshot往左射线（-1）和往右射线（1）的ray个数。'...
        '例如：shot 1往左的ray 1，往左的ray 2，…，往左的ray n，往右的ray 1，…，往右的ray n，shot 2，…，shot m。一般说来，由于缺省值是1，因此只需要把不需要追踪的部分设为0。'...
        '注意：无论ishot的值为多少，irayt都必须对2个方向进行设定！'];
    usage=[usage char(13,10)',char(13,10)','Explanation：',char(13,10)','iraysl:',char(13,10)',iraysl{3},char(13,10)',char(13,10)',...
        'irayt:',char(13,10)',irayt{3},char(13,10)',char(13,10)','xshot:',char(13,10)',xshot{3},char(13,10)',char(13,10)',...
        'ray:',char(13,10)',ray{3},char(13,10)'];
%     usage=[usage char(13,10)',char(13,10)','Explanation：',char(13,10)','iraysl:',char(13,10)',iraysl{3},char(13,10)',char(13,10)',...
%         'irayt:',char(13,10)',irayt{3},char(13,10)',char(13,10)','xshot:',char(13,10)',xshot{3},char(13,10)',char(13,10)',...
%         'ishot:',char(13,10)',ishot{3},char(13,10)',char(13,10)','ray:',char(13,10)',ray{3},char(13,10)'];
    uicontrol(leftp,'Style','edit','String',usage,'HorizontalAlignment','left','FontSize',9,'Units','normalized','Position',[.5 .01 .49 .76],'Max',100,'Enable','Inactive');
    
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
            set(src,'String','Currently iraysl=1, press to change to 0','ForegroundColor','r');
            iraysl{7}=1;
            irayt{8}=true;
        else
            fun_batch_ui_switch(batchmode(1:5),'Enable','off');
            fun_batch_ui_switch(tb,'Enable','Inactive');
            set(src,'String','Currently iraysl=0, press to change to 1','ForegroundColor','b');
            iraysl{7}=0;
            irayt{8}=false;
        end
    end

    function pushbutton_callback(src,event)
        tag=get(src,'Tag');
        tdata=get(tb,'Data');
        index=cell2mat(tdata(:,end));
        switch tag
            case '1' % set irayt=1
                tdata(index,4)={'1'};
            case '2' % set irayt=0
                tdata(index,4)={'0'};        
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
%     function tbdata=fun_make_table(xshot,ishot,ray,irayt)
%        count=0;
%        data=[];
%        len=length(irayt{7});
%        for i=1:length(xshot{7})
%            jj=ishot{7}(i);
%            if jj==2
%                temp=[-1,1];
%            else
%                temp=jj;
%            end
%            for j=temp
%                for k=ray{7}
%                    count=count+1;
%                    flag=1;
%                    if count<len+1 %使之前更改为0的irayt在再次打开按钮窗口时可呈现
%                        flag=irayt{7}(count);
%                    end    
%                    newline={num2str(xshot{7}(i)),num2str(j),num2str(k),num2str(flag),false};
%                    data=[data; newline];
%                end
%            end
%        end
%        tbdata=data;
%     end

    function tbdata=fun_make_table(xshot,ray,irayt)
       count=0;
       data=[];
       len=length(irayt{7});
       for i=1:length(xshot{7})
           temp=[-1,1];
           for j=temp
               for k=ray{7}
                   count=count+1;
                   flag=1;
                   if count<len+1 %使之前更改为0的irayt在再次打开按钮窗口时可呈现
                       flag=irayt{7}(count);
                   end    
                   newline={num2str(xshot{7}(i)),num2str(j),num2str(k),num2str(flag),false};
                   data=[data; newline];
               end
           end
       end
       tbdata=data;
    end
    
    function fun_output
        data=get(tb,'Data');
        c=[];
        for i=1:length(data(:,4))
            c=[c str2num(data{i,4})];
        end
        irayt{7}=c;
        if (~strcmp(num2str(irayt{7}),num2str(oldvalue{4}{7})))
            irayt{8}=true;
        end
    end
    
end
    