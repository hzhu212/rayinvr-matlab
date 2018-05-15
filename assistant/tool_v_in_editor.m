function tool_v_in_editor

    global model LN xmin xmax zmin zmax precision xx ZZ vinerror selectL scolor;
    global veditorh;
    % disp ('1: v.in editor');

    % variables to save to history_vin.mat
    save_list = {
        'veditorh', 'loadpath', 'loadname', 'fullload', 'savepath', 'savename', ...
        'fullsave', 'DX', 'DY', 'overlayboundary', 'labelboundary', 'pois', ...
        'poisbl', 'X1D'};

    % initial file path and names
    [loadpath,loadname,savepath,savename,fullload,fullsave]=deal('');
    DX=0.005; DY=0.005;  % 对模型进行离散化时的横向和深度方向的采样间隔，单位 km
    overlayboundary='1'; % 彩色图上是否叠加层的边界
    labelboundary='1'; % 彩色图上的层边界是否标注序号
    pois=0.25; % rayinvr缺省的泊松比值
    poisbl={}; % 微调四边形块中的泊松比值，缺省为空；存储方式为：每层为一个cell元素，每个cell元素为n*2的矩阵，第一列是块号，第二列是泊松比值
    X1D=[]; % 用于存放绘制一维速度剖面x坐标的数组
    plot1D=false; % 是否画出一维剖面
    output1D=false; % 是否输出一维剖面到文本文件

    % load last run information
    if exist('history_vin.mat','file');
        s=load ('history_vin.mat');
        veditorh=s.veditorh;
        loadpath=s.loadpath;
        loadname=s.loadname;
        fullload=s.fullload;
        savepath=s.savepath;
        savename=s.savename;
        fullsave=s.fullsave;
        DX=s.DX;
        DY=s.DY;
        overlayboundary=s.overlayboundary;
        labelboundary=s.labelboundary;
        pois=s.pois;
        poisbl=s.poisbl;
        X1D=s.X1D;
    end
    if isempty(fullload)
        loadprevious='off';
    else
        loadprevious='on';
    end
    if isempty(fullsave)
        saveprevious='off';
    else
        saveprevious='on';
    end
    if isempty(pois)
        pois=0.25; % rayinvr缺省的泊松比值
    end
    % if isempty(X1D)
    %     X1D=mean(xx([1,end]));
    % end

    % labelL='y'; % 'y' for yes to label the layer boundary number; 'n' for no
    % symbolZ='n'; %
    % labelZ='n'; % 'y' for yes to label depth value; 'n' for no: only valid if the symbol is drawn
    % symbolV='y'; %
    % labelV='y'; %

    slswitch={true,true,false,true,false,false,true,false,true}; % checkbox状态，依次为（1）Label all layer top boundary；（2）Display depth nodes (open square)；
    % （3）Label depth values (km)；（4）Display velocity nodes (solid dot)；（5）Label velocity values (km/s)；（6）Discretise and color plot the P-wave velocity model；
    % （7）Plot layer boundary of color S-wave velocity model；（8）Display color map of Poisson''s ratio；（9）Output S-wave velocity model to v_s.in file as well as Poisson's ratio table to Poisson.txt

    [plotzmin,plotzmax,xmax,zmax]=deal([]);

    % blocks：model每层的四边形块是把这层顶、底的所有深度和速度节点的横坐标从左往右排序、去除重复项后划出来的。
    blocks={}; % 每一层是一个cell元素，用n*3的矩阵存储block纵向竖线的横坐标和上、下深度坐标
    bselect={false false}; % 控制block绘制的开关，分别对应：是否绘制短竖线；是否从左到右标记block的序号（标识方法：层号-block序号）

    %--------------- UI ---------------------%
    if ishandle(veditorh);
        % veditorh = 1;
        % set(veditorh,'Visible','on');
        figure(veditorh);
    else
        veditorh = figure();
        set(veditorh,'Visible','off','Name','v.in editor',...
            'NumberTitle','on','Position',[100,10,1000,700]);
        % menu item
        menuh1 = uimenu(veditorh,'Label','File','position',1);
        ch11=uimenu(menuh1,'Label','Load v.in','Callback',@loadvin_callback);
        ch12=uimenu(menuh1,'Label','Load previous edit v.in','Callback',@loadvin_callback,'Enable',loadprevious);
        ch13=uimenu(menuh1,'Label','Save','Callback',@savevin_callback,'Enable','off');
        ch14=uimenu(menuh1,'Label','Save as','Callback',@savevinas_callback,'Enable','off');
        uimenu(menuh1,'Label','Quit','Callback','exit','Separator','on','Accelerator','Q');

        menuh2 = uimenu(veditorh,'Label','Plot','position',2);
        ch21=uimenu(menuh2,'Label','Replot model','Callback',@plot_callback,'Enable','off');
        ch22=uimenu(menuh2,'Label','Plot control','Callback',@control_callback,'Enable','off');
        ch23=uimenu(menuh2,'tag','35','Label','Color plot discretised velocity model (fort.35 file)','Callback',@fort_file_callback,'Enable','off','Separator','on');
        ch24=uimenu(menuh2,'tag','63','Label','Color plot ray density (fort.63 file)','Callback',@fort_file_callback,'Enable','off');
        ch25=uimenu(menuh2,'tag','Swave','Label','Color plot S-wave velocity and/or Poisson ratio model ','Callback',@S_plot_callback,'Enable','off','Separator','on');

        menuh3 = uimenu(veditorh,'Label','Edit model','position',3);
        ch31=uimenu(menuh3,'Label','Create from zero','Callback',@createnew_callback,'Enable','on');
        ch32=uimenu(menuh3,'Label','Create by import bathymetry','Callback','','Enable','off');
        ch33=uimenu(menuh3,'Label','Edit layers','Separator','on','Enable','off','Callback',@editlayer_callback);
        ch36=uimenu(menuh3,'Label','Precision convertor (current model)','Separator','on','Callback',@precision_callback,'Enable','off');
        uimenu(menuh3,'Label','Precision convertor (batch)','Callback',@precisionbatch_callback);

        menuh4 = uimenu(veditorh,'Label','Debug','position',4);
        ch41=uimenu(menuh4,'Label','Export all virables to base workspace','Callback',@debug_callback,'Enable','off');

        menuh5 = uimenu(veditorh,'Label','Help','position',5,'Enable','on');
        uimenu(menuh5,'Label','Read me','Callback','');

        uimenu(veditorh,'Label','   >>> SYSTEM MENU >>>','position',6,'Enable','off');

        set(veditorh,'CloseRequestFcn',@my_closerequest)
        % make the window visable
        set(veditorh,'Visible','on');
    end


    %----- Callback Functions ------%
    function my_closerequest(hObject, eventdata)
        selection = questdlg('Do you want to exit ?',...
            'Close Request Function',...
            'Yes','No','Yes');
        switch selection,
            case 'Yes',
                save('history_vin.mat', save_list{:});
                delete(veditorh);
            case 'No'
        end
    end

    function debug_callback(src,event)
        clc
        whos
        assignin('base','model',model);
    end

    function loadvin_callback(src,event)
        switch loadprevious
            case 'off'
                [loadname,loadpath]= uigetfile('*.in');
            case 'on'
                [loadname,loadpath]= uigetfile(fullload);
        end
        if loadname==0
        else
            fullload=fullfile(loadpath,loadname);
            set (ch12,'Enable','on'); set (ch13,'Enable','on'); set (ch14,'Enable','on');
            set (ch21,'Enable','on'); set (ch22,'Enable','on'); set (ch23,'Enable','on'); set (ch24,'Enable','on'); set (ch25,'Enable','on');
            set (ch31,'Enable','off'); set (ch33,'Enable','on'); set (ch36,'Enable','on');
            set (ch41,'Enable','on');
            % save ('history_vin.mat');
            [model,LN,xmin,xmax,zmin,zmax,precision,xx,ZZ,error]=fun_load_vin(fullload);
            if ~isempty(error)
                hh=warndlg(error);
                uiwait(hh);
            end
            update_block_coordinates;
            selectL=1:LN;
            plotzmin=zmin;
            plotzmax=zmax;
            fun_plot_model(veditorh,model,xmin,xmax,plotzmin,plotzmax,xx,ZZ,selectL,DX,DY,blocks,bselect,X1D,plot1D,output1D,loadpath,slswitch);
            % save ('history_vin.mat');
        end
    end

    function savevinas_callback(src,event)
        switch loadprevious
            case 'off'
                [savename,savepath]= uiputfile('*.in');
            case 'on'
                [savename,savepath]= uiputfile(fullsave);
        end
        if savename==0
        else
            fullsave=fullfile(savepath,savename);
            % save ('history_vin.mat');
            fun_save_v_in(model,fullsave,precision);
            % save ('history_vin.mat');
            if strcmpi(get(ch11,'Enable'),'off')
                set (ch11,'Enable','on');
                set (ch12,'Enable','on');
            end
        end
    end

    function savevin_callback(src,event)
        selection = questdlg('The current v.in file will be overwritten. Are you sure?',...
            'Overwrite warning',...
            'Yes','No','No');
        switch selection,
            case 'Yes',
                fun_save_v_in(model,fullload,precision)
                % save ('history_vin.mat');
            case 'No'
        end
    end

    function precision_callback(src,event)
        switch precision
            case 'low'
                target='high';
            case 'high'
                target='low';
        end
        options.Interpreter = 'tex';
        options.Default = 'Cancel';
        qstring(1) = {['\bf\fontsize{12}The current v.in file is in \color{red} ',precision,' precision,']};
        qstring(2) = {['\color{black}do you want to convert it to \color{red}',target,' precision format?']};
        choice = questdlg(qstring,'Confirm','Yes','Cancel',options);
        switch choice,
            case 'Yes',
                [savename,savepath]= uiputfile(fullsave);
                if savename==0
                else
                    fullsave=fullfile(savepath,savename);
                    % save ('history_vin.mat');
                    fun_save_v_in(model,fullsave,target)
                end
            case 'Cancel'
        end
    end

    function precisionbatch_callback(src,event)
        fun_precision_batch(savepath);
    end

    function plot_callback(src,event)
        fun_plot_model(veditorh,model,xmin,xmax,plotzmin,plotzmax,xx,ZZ,selectL,DX,DY,blocks,bselect,X1D,plot1D,output1D,loadpath,slswitch);
        % save ('history_vin.mat');
    end

    function control_callback(src,event)
        [selectL,plotzmin,plotzmax,DX,DY,slswitch,bselect,X1D,plot1D,output1D,needreplot]=fun_layer_label_selection...
            (LN,plotzmin,plotzmax,ZZ,selectL,DX,DY,slswitch,bselect,X1D,plot1D,output1D);
        if needreplot;
            plot_callback(src,event);
        end
    end

    function fort_file_callback(src,event)
        tag=get(src,'tag');
        switch tag;
            case '35'
                fortname=uigetfile(fullfile(loadpath,'fort.35'),'Pick the fort.35 file');
                ysign=1;
            case '63'
                fortname=uigetfile(fullfile(loadpath,'fort.63'),'Pick the fort.63 file');
                ysign=-1;
        end
        if fortname==0
        else
            fort=importdata(fullfile(loadpath,fortname));
            x=fort(:,1); y=fort(:,2)*ysign; z=fort(:,3);
            xu=unique(x); yu=unique(y);
            odx=xu(2)-xu(1); ody=yu(2)-yu(1);
            dlg_title = 'Set general parameters for ploting fort.35 or fort.63 files';
            prompt{1} = [char(13,10)','\fontsize{12}','The sample interval (km) of distance and depth?',char(13,10)',...
                '(\color{red}Use "0 0" to keep the original spacing.)',char(13,10)',...
                '\color{blue}The fort.',tag,' file has DISTANCE: ',num2str(xu(1)),' : ',num2str(odx),' : ',num2str(xu(end)),char(13,10)',...
                'and DEPTH: ',num2str(yu(1)),' : ',num2str(ody),' : ',num2str(yu(end))];
            prompt{2} = [char(13,10)','\fontsize{12}','Overlay the layer boundary lines? (\color{red}1=Yes, 0=No)'];
            prompt{3} = [char(13,10)','\fontsize{12}','Label the layer boundary number? (\color{red}1=Yes, 0=No)'];
            num_lines = [1,80];
            def = {num2str([DX DY]) num2str(overlayboundary) num2str(labelboundary)};
            options.Interpreter='tex';
            answer = inputdlg(prompt,dlg_title,num_lines,def,options);
            if ~isempty(answer);  % 这是为了检查是否点了cancel或者关闭窗口，此时返回的是空cell（不是空字符串！）
                tt=str2num(answer{1});
                DX=tt(1); DY=tt(2);
                if DX==0 || DY==0;
                    DX=odx; DY=ody;
                end
                overlayboundary=answer{2};
                labelboundary=answer{3};
                fun_color_fort_files(x,y,z,tag,DX,DY,xx,ZZ,overlayboundary,labelboundary);
            end
        end
    end

    function S_plot_callback(src,event)
        [pois,poisbl,selectL,zmin,zmax,DX,DY,slswitch,bselect]=fun_vin_Swave_plot(pois,poisbl,LN,model,xmin,xmax,zmin,zmax,xx,ZZ,selectL,DX,DY,slswitch,blocks,bselect,loadpath,precision);
    end

    function createnew_callback(src,event)
        prompt = {'Minimum x coordinate (km):','Maximum x coordinate (km):','Bottom depth (km):',...
            'Seawater velocity (km/s)','Precision (7 for ''low'', 8 for ''high''):'};
        dlg_title = 'Model Frame Setting';
        num_lines = [1,40];
        def = {'0',num2str(xmax),num2str(zmax),'1.485','8'};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        if ~isempty(answer)
            LN=2;
            xmin=str2num(answer{1});
            xmax=str2num(answer{2});
            zmin=0;
            zmax=str2num(answer{3});
            vw=str2num(answer{4});
            switch answer{5}
                case '7'
                    precision='low';
                case '8'
                    precision='high';
            end
            % use structure to store model, bd=layer top boundary, tv=top velocity, bv=bottom velocity
            % each cell is a 3xNodes matrix for (1) x, (2) z or v, and (3) partial derivative for each node
            model=struct('bd',{},'tv',{},'bv',{});
            model(1).bd=[xmin xmax; zmin zmin; 0 0];
            model(1).tv=[xmin xmax; vw vw; 0 0];
            model(1).bv=[xmin xmax; vw vw; 0 0];
            model(2).bd=[xmin xmax; zmax zmax];
            xx=xmin:(xmax-xmin)/100:xmax;
            ZZ=zeros(LN,length(xx));
            ZZ(1,:)=zmin;
            ZZ(2,:)=zmax;
            update_block_coordinates;
            selectL=1:LN;
            plotzmin=zmin;
            plotzmax=zmax;
            slswitch={true,true,false,true,false,false,true,false,true};
            bselect={false false};
            fun_plot_model(veditorh,model,xmin,xmax,plotzmin,plotzmax,xx,ZZ,selectL,DX,DY,blocks,bselect,X1D,plot1D,output1D,loadpath,slswitch);
            set (ch11,'Enable','off'); set (ch12,'Enable','off'); set (ch13,'Enable','on'); set (ch14,'Enable','on');
            set (ch21,'Enable','on'); set (ch22,'Enable','on'); set (ch23,'Enable','on'); set (ch24,'Enable','on'); set (ch25,'Enable','on');
            set (ch33,'Enable','on'); set (ch36,'Enable','on');
            set (ch41,'Enable','on');
        end
    end

    function editlayer_callback(src,event)
        [model,LN,zmin,zmax,ZZ,replot]=fun_edit_vin_model(model,LN,zmin,zmax,xx,ZZ);
        update_block_coordinates;
        if replot;
            selectL=1:LN;
%             plotzmin=zmin;
%             plotzmax=zmax;
            slswitch={true,true,false,true,false,false,true,false,true};
            plot_callback(src,event);
        end
    end

    function update_block_coordinates
        blocks={};
        fn=fieldnames(model);
        for i=1:LN-1;
            xnodes=[];
            for j=1:length(fn)
                vvv=getfield(model,{i},fn{j});
                xnodes=[xnodes vvv(1,:)];
            end
            vvv=getfield(model,{i+1},fn{1});
            xnodes=[xnodes vvv(1,:)];
            xnodes=unique(xnodes);
            znodes1=interp1(xx,ZZ(i,:),xnodes,'linear');
            znodes2=interp1(xx,ZZ(i+1,:),xnodes,'linear');
            blocks{i}=[xnodes' znodes1' znodes2'];
        end
    end


end  % end of tool_v_in_editor
