function [newmodel,newLN,newzmin,newzmax,newZZ,replot]=fun_edit_vin_model(model,LN,zmin,zmax,xx,ZZ)

replot=false;
[newmodel,newLN,newzmin,newzmax,newZZ]=deal(model,LN,zmin,zmax,ZZ);
xmin=xx(1);
xmax=xx(end);

%---- UI
if ishandle(133);
    elh = 133;  % edit layer handle
    set(elh,'Visible','on');
else
    elh = figure(133);
    set(elh,'Visible','off','Name','Model Layer Editor','MenuBar','none','NumberTitle','off','Position',[100,50,1000,600]); 
    %----------- depth panel
    depthp = uipanel(elh,'visible','on','Title','Depth Nodes','Position',[.0 .0 .25 1],'TitlePosition','centertop','FontWeight','bold','FontSize',12,'ForegroundColor','blue');
    depthtb = uitable(depthp,'Tag','depth','Units','normalized','Position',[.025 .185 0.95 0.815],'ColumnName',{'X','Z','Change','Select'},'ColumnFormat',{'numeric','numeric','numeric','logical'},...
        'ColumnEditable',[true true true true],'ColumnWidth',{50 50 50 50},'FontSize',9,'Data',fun_form_depth_table(1),'CellEditCallback',@cell_callback);
    uicontrol(depthp,'Style','pushbutton','String','Batch Set ...','Tag','depth','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@batchset_callback,'Units','normalized','Position',[.025 .13 0.95 .05],'ForegroundColor','blue');
    adddepthpb=uicontrol(depthp,'Style','pushbutton','String','Add Depth Nodes','Tag','depth','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@addnode_callback,'Units','normalized','Position',[.025 .07 0.95 .05],'ForegroundColor','blue');
    deldepthpb=uicontrol(depthp,'Style','pushbutton','String','Delete Selected Nodes !','Tag','depth','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@delnode_callback,'Units','normalized','Position',[.025 .01 0.95 .05],'ForegroundColor','r');
    %----------- velocity 1 panel
    velp1 = uipanel(elh,'visible','on','Title','Top Velocity Nodes','Position',[.25 .0 .25 1],'TitlePosition','centertop','FontWeight','bold','FontSize',12,'ForegroundColor','m');
    veltb1 = uitable(velp1,'Tag','V1','Units','normalized','Position',[.025 .185 0.95 0.815],'ColumnName',{'X','V1','Change','Select'},'ColumnFormat',{'numeric','numeric','numeric','logical'},...
        'ColumnEditable',[true true true true],'ColumnWidth',{50 50 50 50},'FontSize',9,'Data',fun_form_velocity_table(1,1),'CellEditCallback',@cell_callback);
    uicontrol(velp1,'Style','pushbutton','String','Batch Set ...','Tag','V1','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@batchset_callback,'Units','normalized','Position',[.025 .13 0.95 .05],'ForegroundColor','m');
    addvelpb1=uicontrol(velp1,'Style','pushbutton','String','Add Top Velocity Nodes','Tag','V1','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@addnode_callback,'Units','normalized','Position',[.025 .07 0.95 .05],'ForegroundColor','m');
    delvelpb1=uicontrol(velp1,'Style','pushbutton','String','Delete Selected Nodes !','Tag','V1','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@delnode_callback,'Units','normalized','Position',[.025 .01 0.95 .05],'ForegroundColor','r');
    %----------- velocity 2 panel
    velp2 = uipanel(elh,'visible','on','Title','Bottom Velocity Nodes','Position',[.5 .0 .25 1],'TitlePosition','centertop','FontWeight','bold','FontSize',12,'ForegroundColor','g');
    veltb2 = uitable(velp2,'Tag','V2','Units','normalized','Position',[.025 .185 0.95 0.815],'ColumnName',{'X','V2','Change','Select'},'ColumnFormat',{'numeric','numeric','numeric','logical'},...
        'ColumnEditable',[true true true true],'ColumnWidth',{50 50 50 50},'FontSize',9,'Data',fun_form_velocity_table(1,2),'CellEditCallback',@cell_callback);
    uicontrol(velp2,'Style','pushbutton','String','Batch Set ...','Tag','V2','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@batchset_callback,'Units','normalized','Position',[.025 .13 0.95 .05],'ForegroundColor','g');
    addvelpb2=uicontrol(velp2,'Style','pushbutton','String','Add Bottom Velocity Nodes','Tag','V2','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@addnode_callback,'Units','normalized','Position',[.025 .07 0.95 .05],'ForegroundColor','g');
    delvelpb2=uicontrol(velp2,'Style','pushbutton','String','Delete Selected Nodes !','Tag','V2','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@delnode_callback,'Units','normalized','Position',[.025 .01 0.95 .05],'ForegroundColor','r');
    % right push buttons
    uicontrol(elh,'Style','text','String','Select a layer','Units','normalized','Position',[.755 .95 .24 .05],'FontWeight','bold','FontSize',16,'ForegroundColor','blue','BackgroundColor','y');
    poph=uicontrol(elh,'Style','popup','String',cellstr(num2str((1:LN)')),'Tag','layer','Units','normalized','Position',[.755 .9 .24 .05],...
        'FontWeight','bold','FontSize',12,'Callback',@pop_callback);
    uicontrol(elh,'Style','text','String','Insert layers within current layer (NOT BOTTOM LAYER!) by automatically calculating the node depths and velocities',...
        'Units','normalized','Position',[.755 .72 .24 .13],'FontWeight','bold','FontSize',12,'ForegroundColor','blue','BackgroundColor','y');
    insertpb=uicontrol(elh,'Style','pushbutton','String','Insert layers','Tag','insert','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@insert_callback,'Units','normalized','Position',[.755 .65 0.24 .06]);
    uicontrol(elh,'Style','text','String','Add a layer into the model by manually input the nodes'' information',...
        'Units','normalized','Position',[.755 .5 .24 .1],'FontWeight','bold','FontSize',12,'ForegroundColor','blue','BackgroundColor','y');
    manualpb=uicontrol(elh,'Style','pushbutton','String','Add a layer within model','Tag','manual','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@manual_callback,'Units','normalized','Position',[.755 .43 0.24 .06]);
    dellayerpb=uicontrol(elh,'Style','pushbutton','String','!!! Delete Current Layer !!!','Tag','del layer','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@dellayer_callback,'Units','normalized','Position',[.755 .25 0.24 .1],'ForegroundColor','r');
    savepb=uicontrol(elh,'Style','pushbutton','String','Save & Exit','Tag','save','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@save_callback,'Units','normalized','Position',[.755 .11 0.24 .06]);
    cancelpb=uicontrol(elh,'Style','pushbutton','String','Cancel','Tag','Cancel','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@cancel_callback,'Units','normalized','Position',[.755 .03 0.24 .06]);
    %------ others
    set(elh,'Visible','on');
    set(elh,'CloseRequestFcn',@my_closerequest)
end

uiwait(elh);

%----- Callback Functions ------%
    function my_closerequest(hObject, eventdata)
        selection = questdlg('Do you want to save the changes before exit?',...
            'Close Request Function','Yes','No','Cancel','Cancel');
        switch selection,
            case 'Yes'
                save_callback(savepb);
            case 'No'
                cancel_callback(cancelpb);
            case 'Cancel'
        end
    end

    function pop_callback(src,event)
        layernumber=get(src,'Value');
        if layernumber==LN;
            set(insertpb,'Enable','off');
            set(velp1,'Visible','off');
            set(velp2,'Visible','off');
            value=model(layernumber).bd;
            depthtbdata={};
            for i=1:size(value,2);
                depthtbdata(i,:)={value(1,i) value(2,i) [] false};
            end
            set(depthtb,'ColumnEditable',[true true false true]);
            set(depthtb,'Data',depthtbdata);
        else
            set(depthtb,'ColumnEditable',[true true true true]);
            set(depthtb,'Data',fun_form_depth_table(layernumber));
            set(veltb1,'Data',fun_form_velocity_table(layernumber,1));
            set(veltb2,'Data',fun_form_velocity_table(layernumber,2));
            set(velp1,'Visible','on');
            set(velp2,'Visible','on');
            set(insertpb,'Enable','on');
        end
    end

    function cell_callback(src,event)
        if event.Indices(2)~=4;
            switch get(src,'Tag');
                case 'depth'
                    tbsrc=depthtb;
                    fn='bd';
                case 'V1'
                    tbsrc=veltb1;
                    fn='tv';
                case 'V2'
                    tbsrc=veltb2;
                    fn='bv';
            end
            layernumber=get(poph,'Value');
            tbdata=get(tbsrc,'Data');
            tbdata=cell2mat(tbdata(:,1:3));
            model=setfield(model,{layernumber},fn,tbdata');
        end
    end

    function batchset_callback(src,event)
        choice = menu('Choose an operation to go on','Set all changeable label to -1','Set all changeable label to 0','Set all changeable label to 1',...
            'Select all','Uncheck all','Flip selection');
        if choice~=0;
            switch get(src,'Tag');
                case 'depth'
                    tbsrc=depthtb;
                    fn='bd';
                case 'V1'
                    tbsrc=veltb1;
                    fn='tv';
                case 'V2'
                    tbsrc=veltb2;
                    fn='bv';
            end
            layernumber=get(poph,'Value');
            tbdata=get(tbsrc,'Data');
            if choice<4 && layernumber~=LN;
                tbdata=cell2mat(tbdata(:,1:3));
                tbdata(:,end)=choice-2;
                model=setfield(model,{layernumber},fn,tbdata');
                pop_callback(poph,event);
            end
            if choice==4;
                tbdata(:,end)={true};
                set(tbsrc,'Data',tbdata);
            end
            if choice==5;
                tbdata(:,end)={false};
                set(tbsrc,'Data',tbdata);
            end
            if choice==6;
                tbdata(:,end)=num2cell(logical(~cell2mat(tbdata(:,end))));
                set(tbsrc,'Data',tbdata);
            end
        end
    end

    function addnode_callback(src,event)
        switch get(src,'Tag');
            case 'depth'
                nodename='TOP BOUNDARY DEPTH (km)';
                fn='bd';
                tbsrc=depthtb;
            case 'V1'
                nodename='TOP VELOCITY (km/s)';
                tbsrc=veltb1;
                fn='tv';
            case 'V2'
                nodename='BOTTOM VELOCITY (km/s)';
                tbsrc=veltb2;
                fn='bv';
        end
        layernumber=get(poph,'Value');
        updatemodel=true;
        prompt = {['Add multiple new nodes for LAYER: ',num2str(layernumber),char(13,10)',char(13,10)','Input x coordinates (km) between ',num2str(xmin),' and ',num2str(xmax)],...
            ['Input corresponding ', nodename,' (single value for all new nodes, or leave blank for automatic interpolation)'],...
            'Input corresponding changeable labe of -1, 0 or 1 (single value for all new nodes, or leave blank for automatic interpolation; this line will be ignored for model bottom layer)'};
        dlg_title = 'Add Layer Nodes';
        num_lines = [1,80];
        answer = inputdlg(prompt,dlg_title,num_lines);
        if isempty(answer)
            updatemodel=false;
        else
            coord=str2num(answer{1});
            value=str2num(answer{2});
            change=str2num(answer{3});
            if isempty(find(coord<=xmin)) && isempty(find(coord>=xmax));
                xout=false;
            else
                xout=true;
                err='The x coordinates of some new nodes are out of model boundary!';
            end
            while xout;
                selection = questdlg([err,char(13,10)','Do you want to fix the problem?',char(13,10)','Note: Cancel will return to the main window and lose all input data!'],...
                    'Error !','Fix them','Cancel','Fix them');
                switch selection,
                    case 'Fix them'
                        prompt = {['Add multiple new nodes for LAYER: ',num2str(layernumber),char(13,10)',char(13,10)','Input x coordinates (km) between ',num2str(xmin),' and ',num2str(xmax)],...
                            ['Input corresponding ', nodename,' (single value for all new nodes, or leave blank for automatic interpolation)'],...
                            'Input corresponding changeable labe of -1, 0 or 1 (single value for all new nodes, or leave blank for automatic interpolation; this line will be ignored for model bottom layer)'};
                        dlg_title = 'Add Layer Nodes';
                        num_lines = [1,80];
                        answer = inputdlg(prompt,dlg_title,num_lines,answer);
                        if isempty(answer)
                            updatemodel=false;
                            xout=false;
                        else
                            coord=str2num(answer{1});
                            value=str2num(answer{2});
                            change=str2num(answer{3});
                            if isempty(find(coord<=xmin)) && isempty(find(coord>=xmax));
                                xout=false;
                            else
                                xout=true;
                            end
                            if ~xout;
                                if (length(value)>1 && length(value)~=length(coord)) || (length(change)>1 && length(change)~=length(coord));
                                    xout=true;
                                    err='The number of node inputs are not match for each other!';
                                else
                                    xout=false;
                                end
                            end
                        end
                    case 'Cancel'
                        updatemodel=false;
                        xout=false;
                end
            end
            if updatemodel;
                tbdata=get(tbsrc,'Data');
                tbdata=cell2mat(tbdata(:,1:3));
                if isempty(value);
                    value=interp1(tbdata(:,1),tbdata(:,2),coord,'linear');
                elseif length(value)==1;
                    value=ones(size(coord))*value;
                end
                if isempty(change);
                    change=interp1(tbdata(:,1),tbdata(:,3),coord,'nearest');
                elseif length(value)==1;
                    change=ones(size(coord))*change;
                end
                tbdata=[tbdata; [coord;value;change]'];
                tbdata=sortrows(tbdata,1);
                model=setfield(model,{layernumber},fn,tbdata');
                pop_callback(poph,event);
            end
        end
    end

    function delnode_callback(src,event)
        switch get(src,'Tag');
            case 'depth'
                nodename='TOP BOUNDARY DEPTH';
                fn='bd';
                tbsrc=depthtb;
            case 'V1'
                nodename='TOP VELOCITY';
                tbsrc=veltb1;
                fn='tv';
            case 'V2'
                nodename='BOTTOM VELOCITY';
                tbsrc=veltb2;
                fn='bv';
        end
        tbdata=get(tbsrc,'Data');
        index=cell2mat(tbdata(:,end));
        index([1 end])=false;
        index=find(index);
        if ~isempty(index)
            selection = questdlg(['Are you sure to delete selected ',nodename,' nodes?',char(13,10)','Note: the nodes at Xmin/Xmax cannot be deleted.'],...
                'Delete Request Function','Yes','Cancel','Cancel');
            switch selection,
                case 'Yes'
                    tbdata(index,:)=[];
                    model=setfield(model,{get(poph,'Value')},fn,cell2mat(tbdata(:,1:3))');
                    pop_callback(poph,event);
                case 'Cancel'
            end
        end
    end

    function insert_callback(src,event)
        layernumber=get(poph,'Value');
        updatemodel=true;
        prompt = {['\fontsize{10}Insert multiple new layers into LAYER ',num2str(layernumber),' and the rules as following:',char(13,10)',...
            '(1) If only layer number m is set, m layers will be equally inserted.',char(13,10)',...
            '(2) If only n vertical ratios are set, n layers will be inserted according the specified ratios.',char(13,10)',...
            '(3) If both layer number m and n vertical ratios are set and m>n, the rest m-n layers will equally insert after n layers. For the case of m<n, only m layers will be inserted. If n=1, the ratio will be used for all layers.',char(13,10)',...
            'Note: only the preceding layers with ratio summation less than 1 will be inserted, the exceeded layers will be abandoned!',char(13,10)',char(13,10)',...
            'Layer number (How many layer boundaries will be inserted?)'],'\fontsize{10}Vertical ratios for the inserted layers (between 0 and 1)'};
        dlg_title = 'Insert multiple layers';
        num_lines = [1,80];
        options.Interpreter='tex';
        def={'' ''};
        answer = inputdlg(prompt,dlg_title,num_lines,def,options);
        if ~(isempty(answer)||(isempty(answer{1})&&isempty(answer{2})));
            nlayer=str2num(answer{1});
            ratios=str2num(answer{2});
            if isempty(nlayer);
                for i=1:length(ratios)
                    layerratios(i)=sum(ratios(1:i));
                end
                layerratios(layerratios>=1)=[];
                nlayer=length(layerratios);
            elseif isempty(ratios)
                layerratios=(1:nlayer)/(nlayer+1);
            elseif length(ratios)==1;
                ratios=ones(1,nlayer)*ratios;
                for i=1:length(ratios)
                    layerratios(i)=sum(ratios(1:i));
                end
                layerratios(layerratios>=1)=[];
                nlayer=length(layerratios);
            else
                for i=1:length(ratios)
                    layerratios(i)=sum(ratios(1:i));
                end
                layerratios(layerratios>=1)=[];
                if length(layerratios)>nlayer;
                    layerratios(nlayer+1:end)=[];
                end
                if length(layerratios)<nlayer;
                    nn=nlayer-length(layerratios);
                    rr=(1-layerratios(end))*(1:nn)/(nn+1);
                    layerratios=[layerratios layerratios(end)+rr];
                end
            end
            xdepth=union(model(layernumber).bd(1,:),model(layernumber+1).bd(1,:));
            d1=interp1(model(layernumber).bd(1,:),model(layernumber).bd(2,:),xdepth,'linear');
            d2=interp1(model(layernumber+1).bd(1,:),model(layernumber+1).bd(2,:),xdepth,'linear');
            xv=union(model(layernumber).tv(1,:),model(layernumber).bv(1,:));
            v1=interp1(model(layernumber).tv(1,:),model(layernumber).tv(2,:),xv,'linear');
            v2=interp1(model(layernumber).bv(1,:),model(layernumber).bv(2,:),xv,'linear');
            for i=1:nlayer;
                newlayer(i).bd=[xdepth; d1+(d2-d1)*layerratios(i); zeros(size(xdepth))];
                newlayer(i).tv=[xv; v1+(v2-v1)*layerratios(i); zeros(size(xv))];
                if i==nlayer;
                    newlayer(i).bv=[xv; v2; zeros(size(xv))];
                else
                    newlayer(i).bv=[xv; v1+(v2-v1)*layerratios(i+1); zeros(size(xv))];
                end
            end
            model(layernumber).bv=[xv; v1+(v2-v1)*layerratios(1); zeros(size(xv))];
            model(layernumber+1+nlayer:end+nlayer)=model(layernumber+1:end);
            LN=LN+nlayer;
            model(layernumber+1:layernumber+nlayer)=newlayer;
            set(poph,'Value',layernumber,'String',cellstr(num2str((1:LN)')));
            pop_callback(poph,event);
        end
    end

    function manual_callback(src,event)
        updatemodel=true;
        haveerr=true;
        def={'','','','','','','','',''};
        while haveerr;
            prompt = {['\fontsize{10}Note: (1) The new layer MUST NOT be the top/bottom layer. (2) The first and last nodes must be at x coordinates of ',num2str(xmin), ' and ',num2str(xmax),' km.',char(13,10)',char(13,10)','x coordinates of DEPTH nodes'],...
                '\fontsize{10}Input corresponding TOP BOUNDARY DEPTH (km) (single value for all nodes)',...
                '\fontsize{10}Input corresponding changeable labe of -1, 0 or 1 (single value for all nodes)',...
                '\fontsize{10}x coordinates of TOP VELOCITY nodes (leave blank if identical to depth nodes)',...
                '\fontsize{10}Input corresponding TOP VELOCITY (km/s) (single value for all nodes)',...
                '\fontsize{10}Input corresponding changeable labe of -1, 0 or 1 (single value for all nodes)',...
                '\fontsize{10}x coordinates of BOTTOM VELOCITY nodes (leave blank if identical to depth nodes)',...
                '\fontsize{10}Input corresponding BOTTOM VELOCITY (km/s) (single value for all nodes)',...
                '\fontsize{10}Input corresponding changeable labe of -1, 0 or 1 (single value for all nodes)'};
            dlg_title = 'Add A New Layer';
            num_lines = [1,120];
            options.Interpreter='tex';
            answer = inputdlg(prompt,dlg_title,num_lines,def,options);
            if isempty(answer)
                updatemodel=false;
                haveerr=false;
            else
                coordD=str2num(answer{1});
                valueD=str2num(answer{2});
                changeD=str2num(answer{3});
                if isempty(answer{4})
                    coordV1=coordD;
                else
                    coordV1=str2num(answer{4});
                end
                valueV1=str2num(answer{5});
                changeV1=str2num(answer{6});
                if isempty(answer{7})
                    coordV2=coordD;
                else
                    coordV2=str2num(answer{7});
                end
                valueV2=str2num(answer{8});
                changeV2=str2num(answer{9});
                if (length(coordD)<2)||(length(coordV1)<2)||(length(coordV2)<2)||isempty(valueD)||isempty(valueV1)||isempty(valueV2)||isempty(changeD)||isempty(changeV1)||isempty(changeV2)
                    haveerr=true;
                    errstring='The input data are less than mininum requirement!';
                else
                    haveerr=false;
                end
                if ~haveerr;
                    if (coordD(1)~=xmin)||(coordD(end)~=xmax)||(coordV1(1)~=xmin)||(coordV1(end)~=xmax)||(coordV2(1)~=xmin)||(coordV2(end)~=xmax)
                        haveerr=true;
                        errstring=['The first and/or last nodes are not at x coordinates of ',num2str(xmin), ' and ',num2str(xmax),' km!'];
                    else
                        haveerr=false;
                    end
                end
                if ~haveerr;
                    if isempty(find(coordD<xmin)) && isempty(find(coordD>xmax)) && isempty(find(coordV1<xmin)) && isempty(find(coordV1>xmax)) && isempty(find(coordV2<xmin)) && isempty(find(coordV2>xmax));
                        haveerr=false;
                    else
                        haveerr=true;
                        errstring='The x coordinates of some nodes are out of model boundary!';
                    end
                end
                if ~haveerr;
                    if (length(valueD)>1 && length(valueD)~=length(coordD)) || (length(changeD)>1 && length(changeD)~=length(coordD)) ||...
                            (length(valueV1)>1 && length(valueV1)~=length(coordV1)) || (length(changeV1)>1 && length(changeV1)~=length(coordV1)) ||...
                            (length(valueV2)>1 && length(valueV2)~=length(coordV2)) || (length(changeV2)>1 && length(changeV2)~=length(coordV2));
                        haveerr=true;
                        errstring='The number of node inputs are not match for each other!';
                    else
                        haveerr=false;
                    end
                end
                if ~haveerr;
                    if length(valueD)==1;
                        valueD=ones(size(coordD))*valueD;
                    end
                    if length(changeD)==1;
                        changeD=ones(size(coordD))*changeD;
                    end
                    bddata=sortrows([coordD;valueD;changeD]',1)';
                    [depthmatrix,above,below]=deal([]);
                    for i=1:LN;
                        depthmatrix(i,:)=interp1(model(i).bd(1,:),model(i).bd(2,:),bddata(1,:));
                    end
                    for i=1:length(coordD);
                        index=find(depthmatrix(:,i)<=bddata(2,i));
                        if isempty(index);
                            above(i)=NaN;
                        else
                            above(i)=index(end);
                        end
                        index=find(depthmatrix(:,i)>=bddata(2,i));
                        if isempty(index);
                            below(i)=NaN;
                        else
                            below(i)=index(1);
                        end
                    end
                    if (~isempty(find(isnan(above)))) || (~isempty(find(isnan(below)))) || (~isempty(find((below-above)~=1))) || (~isempty(find((below(2:end)-below(1:end-1))~=0))) || (~isempty(find((above(2:end)-above(1:end-1))~=0))) ;
                        haveerr=true;
                        errstring=[];
                        for i=1:length(coordD);
                            errstring=[errstring,char(13,10)',num2str(bddata(1,i)),'                              ',num2str(above(i)),'                            ',num2str(below(i))];
                        end
                        errstring=['Node depths vary too much! Check the following table:',char(13,10)',char(13,10)','x-coordnate    above layer number    below layer number',errstring];                            
                    else
                        layernumber=below(1);
                        haveerr=false;
                    end
                end
                if haveerr;
                    selection = questdlg([errstring,char(13,10)',char(13,10)','Do you want to fix the problem?',char(13,10)','Note: Cancel will return to the main window and lose all input data!'],...
                        'Error !','Fix them','Cancel','Fix them');
                    switch selection,
                        case 'Fix them'
                            def=answer;
                        case 'Cancel'
                            haveerr=false;
                            updatemodel=false;
                    end
                end
            end
        end
        if updatemodel;
            if length(valueV1)==1;
                valueV1=ones(size(coordV1))*valueV1;
            end
            if length(changeV1)==1;
                changeV1=ones(size(coordV1))*changeV1;
            end
            if length(valueV2)==1;
                valueV2=ones(size(coordV2))*valueV2;
            end
            if length(changeV2)==1;
                changeV2=ones(size(coordV2))*changeV2;
            end
            model(layernumber+1:end+1)=model(layernumber:end);
            LN=LN+1;
            model(layernumber).bd=[coordD; valueD; changeD];
            model(layernumber).tv=[coordV1; valueV1; changeV1];
            model(layernumber).bv=[coordV2; valueV2; changeV2];
            set(poph,'Value',layernumber,'String',cellstr(num2str((1:LN)')));
            pop_callback(poph,event);
        end
    end

    function dellayer_callback(src,event)
        selection = questdlg(['Are you sure to delete current layer?',char(13,10)','This operation is permanent!'],...
            'Delete Request Function','Yes','Cancel','Cancel');
        switch selection,
            case 'Yes'
                layernumber=get(poph,'Value');
                model(layernumber)=[];
                if layernumber==LN;
                    model(end).bd(3,:)=[];
                    model(end).tv=[];
                    model(end).bv=[];
                end
                LN=LN-1;
                set(poph,'Value',1,'String',cellstr(num2str((1:LN)')));
                pop_callback(poph,event);
            case 'Cancel'
        end
    end

    function save_callback(src,event)
        ZZ=[];
        for i=1:LN;
            ZZ(i,:)=interp1(model(i).bd(1,:),model(i).bd(2,:),xx,'linear');
        end
        zmin=min(min(ZZ));
        zmax=max(max(ZZ));
        replot=true;
        [newmodel,newLN,newzmin,newzmax,newZZ]=deal(model,LN,zmin,zmax,ZZ);
        delete(elh);
    end

    function cancel_callback(src,event)
        selection = questdlg('Are you sure to exit without saving model? All changes you made will be lost!',...
            'Exit Request Function','Yes','Cancel','Cancel');
        switch selection,
            case 'Yes'
                delete(elh);
        end
    end

%----- Tool Functions ------%    

    function depthtbdata=fun_form_depth_table(layernumber)
        value=model(layernumber).bd;
        depthtbdata={};
        for i=1:size(value,2);
            depthtbdata(i,:)={value(1,i) value(2,i) value(3,i) false};
        end
    end

    function veltbdata=fun_form_velocity_table(layernumber,velposition)
        switch velposition
            case 1
                value=model(layernumber).tv;
            case 2 
                value=model(layernumber).bv;
        end
        veltbdata={};
        for i=1:size(value,2);
            veltbdata(i,:)={value(1,i) value(2,i) value(3,i) false};
        end
    end
    
        
end % of [model,LN,zmin,zmax,ZZ,replot]=fun_edit_vin_model(model,LN,zmin,zmax,xx,ZZ);