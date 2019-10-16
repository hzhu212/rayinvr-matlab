function [selectL,zmin,zmax,dx,dy,slswitch,bselect,X1D,plot1D,output1D,needreplot]=fun_layer_label_selection...
    (LN,zmin,zmax,ZZ,selectL,dx,dy,slswitch,bselect,X1D,plot1D,output1D)

needreplot=true;
tbdata=cell(LN,1);
tbdata(:)={false};
tbdata(selectL)={true};
mzmin=min(ZZ(1,:));
mzmax=max(ZZ(LN,:));
if slswitch{6}; % 根据colorplot的要求设置初始状态
    ssss='on';
else
    ssss='off';
end
rowname={};
for i=1:LN;
    rowname{i}=['Layer ',num2str(i)];
end


%---- UI
if ishandle(122);
    controlh = 122;
    set(controlh,'Visible','on');
else
    controlh = figure(122);
    set(controlh,'Visible','off','Name','Set model plot parameters','MenuBar','none','NumberTitle','off','Position',[100,50,750,600]); 
    %----------- left panel
    leftp=uipanel(controlh,'Position',[.0 .0 0.45 1],'Title','Specify layers to plot model nodes','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','red');
    sls{2}=uicontrol(leftp,'Style','checkbox','String','Display depth nodes (open square)','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.05 .95 0.9 .05],'ForegroundColor','k','Value',cell2mat(slswitch(2)));
    sls{3}=uicontrol(leftp,'Style','checkbox','String','Label depth values (km)','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.05 .9 0.9 .05],'ForegroundColor','k','Value',cell2mat(slswitch(3)));
    sls{4}=uicontrol(leftp,'Style','checkbox','String','Display velocity nodes (solid dot)','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.05 .85 0.9 .05],'ForegroundColor','k','Value',cell2mat(slswitch(4)));
    sls{5}=uicontrol(leftp,'Style','checkbox','String','Label velocity values (km/s)','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.05 .8 0.9 .05],'ForegroundColor','k','Value',cell2mat(slswitch(5)));
    bls{1}=uicontrol(leftp,'Style','checkbox','String','Plot block''s vertical boundary','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.05 .75 0.9 .05],'ForegroundColor','k','Value',cell2mat(bselect(1)));
    bls{2}=uicontrol(leftp,'Style','checkbox','String','Label block number','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.05 .7 0.9 .05],'ForegroundColor','k','Value',cell2mat(bselect(2)));
    tb=uitable(leftp,'Units','normalized','Position',[.05 .0 0.55 0.68],'ColumnName','Show nodes','ColumnFormat',{'logical'},...
            'ColumnEditable',true,'FontSize',10,'Data',tbdata,'RowName',rowname);
    uicontrol(leftp,'Style','pushbutton','String','Check All','Tag','checkall','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.65 .6 0.3 .05],'ForegroundColor','blue');
    uicontrol(leftp,'Style','pushbutton','String','Uncheck All','Tag','clear','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.65 0.5 .3 .05],'ForegroundColor','blue');
    uicontrol(leftp,'Style','pushbutton','String','Flip Checks','Tag','flip','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.65 .4 .3 .05],'ForegroundColor','blue');
    %----------- right panel
    rightp=uipanel(controlh,'Position',[.45 .0 0.55 1],'Title','Overall controls','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','b');
    sls{1}=uicontrol(rightp,'Style','checkbox','String','Label all layer top boundary','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.05 .95 0.9 .05],'ForegroundColor','k','Value',cell2mat(slswitch(1)));
    uicontrol(rightp,'Style','text','String','Model depth range (Zmin & Zmax)','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .875 0.9 .05],'FontWeight','bold','ForegroundColor','b');
    uicontrol(rightp,'Style','edit','String',num2str(mzmin),'HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .825 0.4 .05],'Enable','Inactive');
    uicontrol(rightp,'Style','edit','String',num2str(mzmax),'HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.55 .825 0.4 .05],'Enable','Inactive');
    uicontrol(rightp,'Style','text','String','Current plot depth range','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .75 0.9 .05],'FontWeight','bold','ForegroundColor','blue');
    uicontrol(rightp,'Style','edit','String',num2str(zmin),'HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .7 0.4 .05],'Enable','Inactive');
    uicontrol(rightp,'Style','edit','String',num2str(zmax),'HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.55 .7 0.4 .05],'Enable','Inactive');
    uicontrol(rightp,'Style','text','String','Set new plot depth range below !','HorizontalAlignment','center','FontSize',12,'Units','normalized','Position',[.05 .625 0.9 .05],'FontWeight','bold','ForegroundColor','r');
    zminedit=uicontrol(rightp,'Style','edit','String',num2str(zmin),'HorizontalAlignment','center','FontSize',12,'Units','normalized','Position',[.05 .575 0.4 .05],'FontWeight','bold','ForegroundColor','r','Enable','on');
    zmaxedit=uicontrol(rightp,'Style','edit','String',num2str(zmax),'HorizontalAlignment','center','FontSize',12,'Units','normalized','Position',[.55 .575 0.4 .05],'FontWeight','bold','ForegroundColor','r','Enable','on');
    sls{6}=uicontrol(rightp,'Style','checkbox','String','Discretise and color plot the P-wave velocity model','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.05 .5 0.9 .05],'ForegroundColor','k','Value',cell2mat(slswitch(6)),'Callback',@colorplot_callback);
    uicontrol(rightp,'Style','text','String',' Distance (x) spacing (km)             Depth (z) spacing (km)   ','HorizontalAlignment','center','FontSize',10,...
        'Units','normalized','Position',[.05 .45 0.9 .05],'FontWeight','bold','ForegroundColor','blue');
    dxedit=uicontrol(rightp,'Style','edit','String',num2str(dx),'HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .4 0.4 .05],'Enable',ssss);
    dyedit=uicontrol(rightp,'Style','edit','String',num2str(dy),'HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.55 .4 0.4 .05],'Enable',ssss);
    p1D=uicontrol(rightp,'Style','checkbox','String','Plot 1D velocity model at below distances (x axis)','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Tag','plot','Units','normalized','Position',[.05 .325 0.9 .05],'ForegroundColor','k','Value',plot1D,'Callback',@X1D_callback);
    w1D=uicontrol(rightp,'Style','checkbox','String','And write to seperate "Vp_at_(x).txt" files','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Tag','write','Units','normalized','Position',[.05 .275 0.9 .05],'ForegroundColor','k','Value',output1D,'Callback',@X1D_callback);
    X1Dedit=uicontrol(rightp,'Style','edit','String',num2str(X1D),'HorizontalAlignment','left','FontSize',10,'Units','normalized','Position',[.05 .225 0.9 .05],'Enable','off');
    X1D_callback(p1D);
    okpb=uicontrol(rightp,'Style','pushbutton','String','OK','Tag','OK','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.05 .15 0.4 .05],'ForegroundColor','blue','BackgroundColor','y');
    uicontrol(rightp,'Style','pushbutton','String','Cancel','Tag','Cancel','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.55 0.15 .4 .05],'ForegroundColor','blue','BackgroundColor','y');
    %------ others
    set(controlh,'Visible','on');
    set(controlh,'CloseRequestFcn',@my_closerequest)
end

uiwait(controlh);

%----- Callback Functions ------%
    function my_closerequest(hObject, eventdata)
        selection = questdlg('Do you want to save the changes before exit?',...
            'Close Request Function','Yes','No','Cancel','Cancel');
        switch selection,
            case 'Yes'
                exit_callback(okpb);
            case 'No'
                needreplot=false;
                delete(controlh);
            case 'Cancel'
        end
    end

    function setcheck_callback(src,event)
        table1data=get(tb,'Data');
        switch get(src,'Tag');
            case 'checkall'
                table1data(:,end)={true};
            case 'clear'
                table1data(:,end)={false};
            case 'flip'
                table1data(:,end)=num2cell(logical(~cell2mat(table1data(:,end))));
        end
        set(tb,'Data',table1data);
    end

    function exit_callback(src,event)
        switch get(src,'Tag')
            case 'OK'
                for i=1:6;
                    if get(sls{i},'Value')==get(sls{i},'Max');
                        slswitch{i}=true;
                    else
                        slswitch{i}=false;
                    end
                end
                for i=1:2;
                    if get(bls{i},'Value')==get(bls{i},'Max');
                        bselect{i}=true;
                    else
                        bselect{i}=false;
                    end
                end
                tbdata=get(tb,'Data');
                selectL=find(cell2mat(tbdata(:,1)))'; % note: selectL must be a row vector for "for" loop!
                zmin=str2num(get(zminedit,'String'));
                zmax=str2num(get(zmaxedit,'String'));
                if slswitch{6}; % 如果勾选了画彩色
                    dx=str2num(get(dxedit,'String'));
                    dy=str2num(get(dyedit,'String'));
                end
                if output1D || plot1D;
                    X1D=str2num(get(X1Dedit,'String'));
                end
                delete (controlh);
            case 'Cancel'
                selection = questdlg('Are you sure to give up the changes and exit?',...
                    'Close Request Function','Yes','Cancel','Cancel');
                switch selection
                    case 'Yes'
                        needreplot=false;
                        delete (controlh);
                end
        end
    end

    function colorplot_callback(src,event)
        if get(src,'Value')==get(src,'Max');
            set(dxedit,'Enable','on');
            set(dyedit,'Enable','on');
        else
            set(dxedit,'Enable','off');
            set(dyedit,'Enable','off');
        end
    end

    function X1D_callback(src,event)
        switch get(src,'Tag');
            case 'plot'
                if get(src,'value')==get(src,'max')
                    plot1D=true;
                else
                    plot1D=false;
                end
            case 'write'
                if get(src,'value')==get(src,'max')
                    output1D=true;
                else
                    output1D=false;
                end
        end
        if output1D || plot1D
            set(X1Dedit,'Enable','on');
        else
            set(X1Dedit,'Enable','off');
        end
    end

end  % of [selectL,zmin,zmax,slswitch]=fun_layer_label_selection(LN,zmin,zmax,ZZ,selectL,slswitch)