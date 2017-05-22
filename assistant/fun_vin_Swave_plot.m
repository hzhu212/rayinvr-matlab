function [pois,poisbl,selectL,zmin,zmax,dx,dy,slswitch,bselect]=fun_vin_Swave_plot...
    (pois,poisbl,LN,pmodel,xmin,xmax,zmin,zmax,xx,ZZ,selectL,dx,dy,slswitch,blocks,bselect,savepath,precision)
% 跟纵波模型不同，selectL在这里将选中的界面画为实线（一般来说对应原始纵波模型），而把没有打勾的界面画为虚线（一般是在纵波模型插入的层）
% pmodel会根据泊松比转换为横波模型 model
% savepath 用于保存 v_s.in

% poisbl={};
needreplot=true;
tpois=table_pois(pois);
tbdata=cell(LN,2); % column 1为selectL，2 为泊松比值
tbdata(:,1)={false};
tbdata(selectL,1)={true};
tbdata(:,2)= num2cell(tpois);
if isempty(poisbl)
    tbcolname={'Solid boundary' 'Poisson ratio'};
    tbcolformat={'logical' 'numeric'};
    tbcoleditable=[true true];
    tbcolwidth={'auto' 'auto'};
else
    tbcolname={'Solid boundary' ['Layer',char(13,10)',' Poisson'] 'Block Poisson'};
    tbcolformat={'logical' 'numeric' 'char'};
    tbcoleditable=[true true true];
    tbcolwidth={'auto' 'auto' 400};
    tbdata(:,3)=table_poisbl(poisbl);
end
model=pmodel;
mzmin=min(ZZ(1,:));
mzmax=max(ZZ(LN,:));
if slswitch{6}; % 根据colorplot的要求设置初始状态
    ssss='on';
else
    ssss='off';
end



%% ---- UI
if ishandle(125);
    controlh = 125;
    set(controlh,'Visible','on');
else
    controlh = figure(125);
    set(controlh,'Visible','off','Name','Set S-wave plot parameters','MenuBar','none','NumberTitle','off','Position',[100,50,950,650]); 
    %----------- left panel
    leftp=uipanel(controlh,'Position',[.0 .0 0.55 1],'Title','Specify layer parameters','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','red');
    sls{7}=uicontrol(leftp,'Style','checkbox','String','Plot layer boundary','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.05 .95 0.9 .05],'ForegroundColor','k','Value',cell2mat(slswitch(7)));
    sls{1}=uicontrol(leftp,'Style','checkbox','String','Label all layer top boundary','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.05 .9 0.9 .05],'ForegroundColor','k','Value',cell2mat(slswitch(1)));
    sls{2}=uicontrol(leftp,'Style','checkbox','String','Display depth nodes (open square)','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.05 .85 0.9 .05],'ForegroundColor','k','Value',cell2mat(slswitch(2)));
    sls{3}=uicontrol(leftp,'Style','checkbox','String','Label depth values (km)','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.05 .8 0.9 .05],'ForegroundColor','k','Value',cell2mat(slswitch(3)));
    sls{4}=uicontrol(leftp,'Style','checkbox','String','Display velocity nodes (solid dot)','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.05 .75 0.9 .05],'ForegroundColor','k','Value',cell2mat(slswitch(4)));
    sls{5}=uicontrol(leftp,'Style','checkbox','String','Label velocity (km/s) or Poisson''s ratio','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.05 .7 0.9 .05],'ForegroundColor','k','Value',cell2mat(slswitch(5)));
    uicontrol(leftp,'Style','pushbutton','String','Batch set Poisson''s ratio','Tag','BatchPoisson','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setPoisson_callback,'Units','normalized','Position',[.05 .64 0.9 .05],'ForegroundColor','blue');
    tb=uitable(leftp,'Units','normalized','Position',[.005 .0 0.79 0.63],'ColumnName',tbcolname,'ColumnFormat',tbcolformat,...
            'ColumnEditable',tbcoleditable,'ColumnWidth',tbcolwidth,'FontSize',10,'Data',tbdata);
    uicontrol(leftp,'Style','pushbutton','String','All','Tag','checkall','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.8 .5 0.195 .05],'ForegroundColor','blue');
    uicontrol(leftp,'Style','pushbutton','String','Clear','Tag','clear','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.8 0.4 .195 .05],'ForegroundColor','blue');
    uicontrol(leftp,'Style','pushbutton','String','Flip','Tag','flip','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.8 .3 .195 .05],'ForegroundColor','blue');
    
    %----------- right panel
    rightp=uipanel(controlh,'Position',[.55 .0 0.45 1],'Title','Overall controls','TitlePosition','centertop',...
        'FontWeight','bold','FontSize',12,'ForegroundColor','b');
    sls{9}=uicontrol(rightp,'Style','checkbox','String','Output S-wave velocity model to v_s.in file','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.05 .95 0.9 .05],'ForegroundColor','k','Value',cell2mat(slswitch(9)));
    sls{8}=uicontrol(rightp,'Style','checkbox','String','Display color map of Poisson''s ratio','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.05 .9 0.9 .05],'ForegroundColor','k','Value',cell2mat(slswitch(8)));
    p1=uipanel(rightp,'Units','normalized','Position',[.025 .72 0.95 .155]);
    sls{6}=uicontrol(p1,'Style','checkbox','String','Discretise and color plot the S-wave velocity model','HorizontalAlignment','left','FontWeight','bold','FontSize',10,...
        'Callback','','Units','normalized','Position',[.025 .65 0.95 .3],'ForegroundColor','k','Value',cell2mat(slswitch(6)),'Callback',@colorplot_callback);
    uicontrol(p1,'Style','text','String',' Distance (x) spacing (km)','HorizontalAlignment','center','FontSize',10,...
        'Units','normalized','Position',[.00 .35 0.5 .3],'FontWeight','bold','ForegroundColor','blue');
    uicontrol(p1,'Style','text','String','Depth (z) spacing (km)','HorizontalAlignment','center','FontSize',10,...
        'Units','normalized','Position',[.55 .35 0.4 .3],'FontWeight','bold','ForegroundColor','blue');
    dxedit=uicontrol(p1,'Style','edit','String',num2str(dx),'HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .05 0.4 .3],'Enable',ssss);
    dyedit=uicontrol(p1,'Style','edit','String',num2str(dy),'HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.55 .05 0.4 .3],'Enable',ssss);
    p2=uipanel(rightp,'Units','normalized','Title','Depth range of plot','TitlePosition','centertop','Position',[.025 .25 0.95 .45],'FontWeight','bold','FontSize',10,'ForegroundColor','k');
    uicontrol(p2,'Style','text','String','Model depth range (Zmin & Zmax)','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .8 0.9 .1],'FontWeight','bold','ForegroundColor','b');
    uicontrol(p2,'Style','edit','String',num2str(mzmin),'HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .675 0.4 .125],'Enable','Inactive');
    uicontrol(p2,'Style','edit','String',num2str(mzmax),'HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.55 .675 0.4 .125],'Enable','Inactive');
    uicontrol(p2,'Style','text','String','Current plot depth range','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .5 0.9 .1],'FontWeight','bold','ForegroundColor','blue');
    uicontrol(p2,'Style','edit','String',num2str(zmin),'HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .375 0.4 .125],'Enable','Inactive');
    uicontrol(p2,'Style','edit','String',num2str(zmax),'HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.55 .375 0.4 .125],'Enable','Inactive');
    uicontrol(p2,'Style','text','String','Set new plot depth range below !','HorizontalAlignment','center','FontSize',12,'Units','normalized','Position',[.05 .2 0.9 .125],'FontWeight','bold','ForegroundColor','r');
    zminedit=uicontrol(p2,'Style','edit','String',num2str(zmin),'HorizontalAlignment','center','FontSize',12,'Units','normalized','Position',[.05 .05 0.4 .15],'FontWeight','bold','ForegroundColor','r','Enable','on');
    zmaxedit=uicontrol(p2,'Style','edit','String',num2str(zmax),'HorizontalAlignment','center','FontSize',12,'Units','normalized','Position',[.55 .05 0.4 .15],'FontWeight','bold','ForegroundColor','r','Enable','on');
    VSpb=uicontrol(rightp,'Style','pushbutton','String','Plot/Update Vs','Tag','OK','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@Vs_callback,'Units','normalized','Position',[.05 .15 0.425 .07],'ForegroundColor','blue','BackgroundColor','y');
    POISpb=uicontrol(rightp,'Style','pushbutton','String','Plot/Update Poisson','Tag','Cancel','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@pois_callback,'Units','normalized','Position',[.525 0.15 .425 .07],'ForegroundColor','blue','BackgroundColor','y');
    okpb=uicontrol(rightp,'Style','pushbutton','String','OK','Tag','OK','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.05 .05 0.425 .07],'ForegroundColor','blue','BackgroundColor','y');
    uicontrol(rightp,'Style','pushbutton','String','Cancel','Tag','Cancel','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@exit_callback,'Units','normalized','Position',[.525 0.05 .425 .07],'ForegroundColor','blue','BackgroundColor','y');
    %------ others
    set(controlh,'Visible','on');
    set(controlh,'CloseRequestFcn',@my_closerequest)
end

uiwait(controlh);

%% ----- Callback Functions ------%
    function my_closerequest(hObject, eventdata)
        selection = questdlg('Plot S-wave velocity model or not?',...
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
    
    function setPoisson_callback(src,event)
        h1251 = figure(1251);
        set(h1251,'Name','Input Poisson''s ratio','MenuBar','none','NumberTitle','off','Position',[150,250,650,400]);
        uicontrol(h1251,'Style','text','String',['Input or paste Poisson''s ratio of each model layer just as them in r.in file. Note: ',char(13,10)',...
            '(1) if only one value behind "pois=", it will be used for all layers; ',char(13,10)',...
            '(2) if inputs for layers are less than ',num2str(LN),', the current model''s layer number, the last value will be used for all rest layers.',char(13,10)',...
            '(3) if inputs for layers are more than model layer, the exceeding parts will be cut off.'],...
            'HorizontalAlignment','left','FontSize',12,'Units','normalized','Position',[.0 .7 1 .3],'FontWeight','bold','ForegroundColor','r');
        tbdata=get(tb,'data');
        tpois=cell2mat(tbdata(:,2)');
        lll=length(tpois);
        if lll>=length(pois)
            pois=tpois;
        else
            pois(1:lll)=tpois;
        end
        editstring='pois=';
        for i=1:length(pois)
            editstring=[editstring num2str(pois(i)) ', '];
        end
        if length(tbdata(1,:))==3; % 定义了block poisson
            [lvalue bvalue blvalue]=deal(''); % 层、块、泊松比：初始为空
            for i=1:LN
                tbcol3=str2num(tbdata{i,3});
                if ~isempty(tbcol3)
                    for j=1:length(tbcol3)/2;
                        lvalue=[lvalue num2str(i) ', '];
                        bvalue=[bvalue num2str(tbcol3(j*2-1)) ', '];
                        blvalue=[blvalue num2str(tbcol3(j*2)) ', '];
                    end
                end
            end
            editstring=[editstring,char(13,10)','poisl=',lvalue, char(13,10)','poisb=',bvalue,char(13,10)','poisbl=',blvalue];
        end
        poisedit=uicontrol(h1251,'Style','edit','String',editstring,'HorizontalAlignment','left','FontSize',10,'Units','normalized','Position',[.0 .15 1 .55],...
            'FontWeight','normal','ForegroundColor','k','Enable','on','Max',100);
        uicontrol(h1251,'Style','pushbutton','String','OK','Tag','OK','HorizontalAlignment','center','FontWeight','bold','FontSize',14,...
            'Callback',@pois_closerequest,'Units','normalized','Position',[.2 .0 0.25 .15],'ForegroundColor','blue','BackgroundColor','y');
        uicontrol(h1251,'Style','pushbutton','String','Cancel','Tag','Cancel','HorizontalAlignment','center','FontWeight','bold','FontSize',14,...
            'Callback',@pois_closerequest,'Units','normalized','Position',[.55 0.0 .25 .15],'ForegroundColor','blue','BackgroundColor','y');
        set(h1251,'CloseRequestFcn',@pois_closerequest);
        function pois_closerequest(src,event)
            tag=get(src,'tag');
            switch tag;
                case 'Cancel'
                    delete(h1251);
                case 'OK'
                    selection = questdlg('Save the changes of Poisson''s ratio?',...
                        'Close Request Function','Yes','No','Cancel','Cancel');
                    switch selection,
                        case 'Yes'
                            editstring=sscanf(get(poisedit,'string')','%s'); % 多行时按column读取，所以必须转置
                            I1=findstr(editstring,'pois=');
                            I2=findstr(editstring,'poisl=');
                            I3=findstr(editstring,'poisb=');
                            I4=findstr(editstring,'poisbl=');
                            index=findstr(editstring,'=');
                            [IB IX]=sort([I1 I2 I3 I4]);
                            for i=1:length(IB)
                                if i==length(IB);
                                    value=str2num(editstring(index(i)+1:end))';
                                else
                                    value=str2num(editstring(index(i)+1:IB(i+1)-1))';
                                end
                                switch IX(i)
                                    case 1
                                        I1=value;
                                    case 2
                                        I2=value;
                                    case 3
                                        I3=value;
                                    case 4
                                        I4=value;
                                end
                            end
                            new=I1;
                            if isequal(new,pois);
                            else
                                pois=new;
                                tpois=table_pois(pois);
                                tbdata(:,2)= num2cell(tpois);
                            end
                            if isempty(I2) || isempty(I3) || isempty(I4) 
                            else
                                total=max(I2);
                                newpoisbl=cell(1,total);
                                for i=unique(I2)';
                                    index= I2==i;
                                    newpoisbl{i}=[I3(index) I4(index)];
                                end
                                if ~isequal(newpoisbl,poisbl)
                                    if length(newpoisbl)<length(poisbl)
                                        poisbl(1:length(newpoisbl))=newpoisbl;
                                    else
                                        poisbl=newpoisbl;
                                    end
                                end
                            end
                            if isempty(poisbl)
                                tbdata=tbdata(:,1:2);
                                tbcolname={'Solid boundary' 'Poisson ratio'};
                                tbcolformat={'logical' 'numeric'};
                                tbcoleditable=[true true];
                                tbcolwidth={'auto' 'auto'};
                            else
                                tbcolname={'Solid boundary' 'Layer Poisson' 'Block Poisson'};
                                tbcolformat={'logical' 'numeric' 'char'};
                                tbcoleditable=[true true true];
                                tbcolwidth={'auto' 'auto' 400};
                                tbdata(:,3)=table_poisbl(poisbl);
                            end
                            set(tb,'data',tbdata,'ColumnName',tbcolname,'ColumnFormat',tbcolformat,'ColumnEditable',tbcoleditable,'ColumnWidth',tbcolwidth);
                            delete(h1251);
                        case 'No'
                            delete(h1251);
                        case 'Cancel'
                    end
            end
        end
    end

    function setcheck_callback(src,event)
        table1data=get(tb,'Data');
        switch get(src,'Tag');
            case 'checkall'
                table1data(:,1)={true};
            case 'clear'
                table1data(:,1)={false};
            case 'flip'
                table1data(:,1)=num2cell(logical(~cell2mat(table1data(:,1))));
        end
        set(tb,'Data',table1data);
    end

    function exit_callback(src,event)
        switch get(src,'Tag')
            case 'OK'
                % plot Vs
                Vs_callback;
                % plot Poisson
                if slswitch{8};
                    pois_callback;
                end
                % save v_s.in & Poisson.txt
                if slswitch{9}
                    fun_save_v_in(model,fullfile(savepath,'v_s.in'),precision);
                    fid=fopen(fullfile(savepath,'Poisson.txt'),'w');
                    s1=[]; s2=[];
                    for ii=1:length(pois);
                        s1=[s1 sprintf(' |%-6i',ii)];
                        s2=[s2 sprintf(' %-5.4f,',pois(ii))];
                    end
                    fprintf(fid,'Layer%s\n',s1);
                    fprintf(fid,'pois=%s\n',s2);
                    if length(tbdata(1,:))==3; % 定义了block poisson
                        [lvalue bvalue blvalue]=deal(''); % 层、块、泊松比：初始为空
                        for i=1:LN
                            tbcol3=str2num(tbdata{i,3});
                            if ~isempty(tbcol3)
                                for j=1:length(tbcol3)/2;
                                    lvalue=[lvalue num2str(i) ', '];
                                    bvalue=[bvalue num2str(tbcol3(j*2-1)) ', '];
                                    blvalue=[blvalue num2str(tbcol3(j*2)) ', '];
                                end
                            end
                        end
                        fprintf(fid,'poisl=%s\n',lvalue);
                        fprintf(fid,'poisb=%s\n',bvalue);
                        fprintf(fid,'poisbl=%s\n',blvalue);
                    end
                    fclose(fid);
                end
                delete (controlh);
            case 'Cancel'
                selection = questdlg('Are you sure to give up plotting and exit?',...
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

    function Vs_callback(src,event)  % 画横波速度图
        if ishandle(1252);
            f1252 = 1252;
            set(f1252,'Visible','on');
        else
            f1252=figure(1252);
            set(f1252,'Name','S-wave velocity model','NumberTitle','off','Position',[100,10,1000,700]);
        end
        plot_Vs_or_Poisson(f1252);
    end

    function pois_callback(src,event) % 画泊松比图
        if ishandle(1253);
            f1253 = 1253;
            set(f1253,'Visible','on');
        else
            f1253=figure(1253);
            set(f1253,'Name','Poisson''s ratio model','NumberTitle','off','Position',[100,10,1000,700]);
        end
        plot_Vs_or_Poisson(f1253);
    end

%% -- Tool function
    function tpois=table_pois(pois)
        if isempty(pois)
            pois=0.25; % rayinvr缺省的泊松比值
        end
        if length(pois)>LN;
            tpois=pois(1:LN);
        else
            tpois(1:length(pois))= pois;
            tpois(length(pois):LN)= pois(end);
        end
    end

    function poisblstring=table_poisbl(poisbl)
        % poisbl每层为一个cell元素，每个cell元素为n*2的矩阵，第一列是块号，第二列是泊松比值
        poisblstring=cell(1,LN); % 有效长度不能超过当前的模型层数
        poisblstring(:)={''};
        for i=1:min(length(poisbl),LN)  
            mp=poisbl{i};
            if isempty(mp)
                poisblstring{i}='';
            else
                ss='  ';
                for j=1:length(mp(:,1))
                    ss=[ss num2str(mp(j,1)) ', ' num2str(mp(j,2)) '  '];
                end
                poisblstring{i}=ss;
            end
        end
    end

    function P_to_S(tb)
        tbdata=get(tb,'Data');
        for i=1:LN-1;
            vp=[pmodel(i).tv(2,:); pmodel(i).bv(2,:)];
            vs=fun_Vp_to_Vs_using_Poisson(vp,tbdata{i,2});
            model(i).tv(2,:)=vs(1,:);
            model(i).bv(2,:)=vs(2,:);
        end
    end

    function plot_Vs_or_Poisson(fnumber)
        % general prepare
        for i=1:9;
            if get(sls{i},'Value')==get(sls{i},'Max');
                slswitch{i}=true;
            else
                slswitch{i}=false;
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
        tpois=cell2mat(tbdata(:,2)');
        PL=length(tpois);
        if PL>=length(pois)
            pois=tpois;
        else
            pois(1:PL)=tpois;
        end
        P_to_S(tb);
        scolor={'m','k','r'};  % for node variable or not: m for -1 of gradient, k for 0 of fixed, r for 1 of derivative
        symb={'s','.','.'}; % s for depth node, . for top and bottom velocity node
        UselectL=find(~cell2mat(tbdata(:,1)))'; % note: UselectL must be a row vector for "for" loop!
        [labelL,symbolZ,labelZ,symbolV,labelV,colorplot]=deal(slswitch{1:6});
        fn=fieldnames(model);
        
        % start plot
        figure (fnumber);
        hold off;
        if colorplot && fnumber==1252;  % Color plot Vs 处理彩色图
            wh = waitbar(1/4,'Preparing the color plot, please wait...');
            if dx==0 || dy==0;
                dx=0.01; dy=0.01;
            end
            X=xmin:0.001:xmax;  % 横向采用1米的精度对深度和速度进行插值
            [x,y,z]=deal([]);
            for i=1:LN-1;
                % top V
                x=[x; X'];
                v1=getfield(model,{i},fn{1});
                v=interp1(v1(1,:),v1(2,:),X,'linear');
                y=[y; v'+0.00001];
                v1=getfield(model,{i},fn{2});
                v=interp1(v1(1,:),v1(2,:),X,'linear');
                z=[z; v'];
                % bottom V
                x=[x; X'];
                v1=getfield(model,{i+1},fn{1});
                v=interp1(v1(1,:),v1(2,:),X,'linear');
                y=[y; v'];
                v1=getfield(model,{i},fn{3});
                v=interp1(v1(1,:),v1(2,:),X,'linear');
                z=[z; v'];
            end
            waitbar(2/4,wh);
            F = TriScatteredInterp(x,y,z);
            waitbar(3/4,wh);
            XI=xmin:dx:xmax;
            YI=zmin:dy:zmax;
            [qx,qy] = meshgrid(XI,YI);
            qz = F(qx,qy);
            waitbar(3.5/4,wh);
            delete (wh);
            load('mycolormap','pvelocity_color_map');
            pcolor(qx,qy,qz);%伪彩色图
            shading interp;
            %             caxis([1.499, 4.5]);
            colormap(pvelocity_color_map);
            colorbar('location','southoutside');
            hold on;
        end
        if fnumber==1253; % Color plot Poisson
            load('mycolormap','pvelocity_color_map');
            fill([xx fliplr(xx)]',[ZZ(1:end-1,:) fliplr(ZZ(2:end,:))]',pois(1:LN-1),'LineStyle','none');
            colormap(flipud(pvelocity_color_map));
            colorbar('location','southoutside');
            hold on;
        end
        
        % layer boundary
        if slswitch{7}; % 如果勾选了画层边界
            plot(xx,ZZ(selectL,:),'k-'); % 勾选的特定层画实线，一般是纵波模型的层
            hold on;
            if ~isempty(UselectL);
                plot(xx,ZZ(UselectL,:),'k--'); % 非勾选的特定层画虚线，比如插入的中间层
            end
        end
                
        % Label Layer number
        if labelL
            for i=1:LN;
                text(xmin-(xmax-xmin)/20,ZZ(i,1),['B',num2str(i)]);
                text(xmax+(xmax-xmin)/20,ZZ(i,end),['B',num2str(i)]);
            end
        end
        
        % Top Z
        if symbolZ;
            j=1;
            for i=selectL;
                value=getfield(model,{i},fn{j});
                vl=length(value(1,:));
                if i==LN;
                    pd=ones(1,vl)*2;
                else
                    pd=value(3,:)+2;
                end
                for k=1:vl;
                    px=value(1,k);
                    py=value(2,k);
                    plot(px,py,[scolor{pd(k)},symb{j}]);
                    hold on;
                    if labelZ;
                        text(px-(xmax-xmin)/100,py-(zmax-zmin)/50,sprintf('%5.3f',py));
                    end
                end
            end
        end
        
        if fnumber==1252; % label velocity only valid for Vs plot
            % Top V
            if symbolV || labelV;
                j=2;
                for i=selectL;
                    if i~=LN;
                        value=getfield(model,{i},fn{j});
                        px=value(1,:);
                        vl=length(px);
                        py=interp1(xx,ZZ(i,:),px,'linear');
                        d=interp1(xx,ZZ(i+1,:),px,'linear')-py;
                        pd=value(3,:)+2;
                        for k=1:vl;
                            dd=min([d(k)/4,(zmax-zmin)/100]);
                            if symbolV;
                                plot(px(k),py(k)+dd,[scolor{pd(k)},symb{j}],'MarkerSize',15); 
                                hold on;
                            end
                            if labelV;
                                text(px(k)+(xmax-xmin)/80,py(k)+dd,['\color{blue}',sprintf('%5.3f',value(2,k))]);
                                hold on;
                            end
                        end
                    end
                end
            end
            % bottom V
            if symbolV || labelV;
                j=3;
                for i=selectL;
                    if i~=LN;
                        value=getfield(model,{i},fn{j});
                        px=value(1,:);
                        vl=length(px);
                        py=interp1(xx,ZZ(i+1,:),px,'linear');
                        d=py-interp1(xx,ZZ(i,:),px,'linear');
                        pd=value(3,:)+2;
                        for k=1:vl;
                            dd=min([d(k)/4,(zmax-zmin)/100]);
                            if symbolV;
                                plot(px(k),py(k)-dd,[scolor{pd(k)},symb{j}],'MarkerSize',15);
                            end
                            if labelV;
                                text(px(k)+(xmax-xmin)/80,py(k)-dd,['\color{orange}',sprintf('%5.3f',value(2,k))]);
                            end
                        end
                    end
                end
            end
        end
        
        if fnumber==1253; % label Poisson value
            if labelV;
                xmid=(xmin+xmax)/2;
                for i=1:2:LN-1;
                    dmid=(interp1(xx,ZZ(i,:),xmid,'linear')+interp1(xx,ZZ(i+1,:),xmid,'linear'))/2;
                    text(xmid+(xmax-xmin)/40,dmid,['\color{blue}' sprintf('%5.3f',pois(i))],'BackgroundColor',[1 1 1],'EdgeColor','k','Margin',2);                    
                end
                for i=2:2:LN-1;
                    dmid=(interp1(xx,ZZ(i,:),xmid,'linear')+interp1(xx,ZZ(i+1,:),xmid,'linear'))/2;
                    text(xmid-(xmax-xmin)/20,dmid,['\color{blue}' sprintf('%5.3f',pois(i))],'BackgroundColor',[1 1 1],'EdgeColor','k','Margin',2);                    
                end
            end
        end
                    
        % axes et al
        if fnumber==1252; % for Vs plot
            text(xmin,zmin-(zmax-zmin)/20,['Symbol: square for depth, dot for velocity ({\color{red}red color for change label 1, \color{magenta}magenta for -1, }black for 0)',char(13,10)',...
                'Value: black for depth, {\color{blue}blue for top velocity, \color{orange}orange for bottom velocity}'],...
                'BackgroundColor',[.7 .9 .7],'EdgeColor','c','Margin',8);
        end
        if fnumber==1253; % for Poisson plot
            text(xmin,zmin-(zmax-zmin)/20,['Symbol: square for depth node position, )',char(13,10)',...
                'Value: black for depth, {\color{blue}blue for Poisson''s ratio.}'],...
                'BackgroundColor',[.7 .9 .7],'EdgeColor','c','Margin',8);
        end
        set(gca,'YDir','reverse');
        xlabel('Distance (km)');
        ylabel ('Depth (km)');
        ylim ([zmin zmax]);
        xlim ([xmin-(xmax-xmin)/10,xmax+(xmax-xmin)/10]);
        hold off;
        wh=waitbar(4/4,'Successfully finished!');
        delete(wh);
    end  % end plot_Vs_or_Poisson

    

end  % 