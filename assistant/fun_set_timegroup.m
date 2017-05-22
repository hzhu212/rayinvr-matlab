function [newOBS,newSCS,newtimegroup,newphasegroup]=fun_set_timegroup(OBS,SCS,timegroup,phasegroup)
% for test UI
% function [newOBS,newSCS,newtimegroup,newphasegroup]=fun_set_timegroup
% allsurvey={'tt'};

% -- begin 
[newOBS,newSCS,newtimegroup,newphasegroup]=deal(OBS,SCS,timegroup,phasegroup);
allsurvey=[fun_make_popup_strings(OBS,'OBS') fun_make_popup_strings(SCS,'SCS')];
obsend=length(OBS);
depthnodes=NaN(2,obsend);

totalphase=NaN(1,6); % n-by-6 , columns are (1) phaseID; (2) group; (3) survey; (4) phase; (5) ray; (6) wave
count=0;
for i=1:length(SCS);
    for j=1:length(SCS(i).phase);
        count=count+1;
        totalphase(count,:)=[SCS(i).phaseID(1:2,j)' -i j SCS(i).phase{j}(1,8:9)];
    end
end
for i=1:obsend;
    for j=1:length(OBS(i).phase);
        count=count+1;
        totalphase(count,:)=[OBS(i).phaseID(1:2,j)' i j OBS(i).phase{j}(1,8:9)];
    end
    depthnodes(:,i)=[OBS(i).moffset;OBS(i).XYZ(3)/OBS(i).XYZ(4)/1000];  % from m to km
end

radio_status=[true false false];
% PL,PR,SL: P-wave reflection, P-wave refraction/headwave, S-wave reflection
% [plgroup,prgroup,slgroup]=deal({NaN(1,5)}); % each time group is a cell element, which for is a n-by-5 matrix, columns are
                                            % (1)Time group number; (2) phase ID; (3)survey number(negative is SCS), (4) phase number, (5) base (1) or orphan (0)
[plgroup,prgroup,slgroup]=fun_sort_timegroup(timegroup,totalphase);
current={};  % hold one of plgroup,prgroup,slgroup depend on radio_status
allgroup={plgroup,prgroup,slgroup};

% [basepod,orphanpod]=deal([]); % basepod is a 1-by-n vector, store the timegroup number only; but the orphanpod is 3-by-n with rows: groupID,survey,phase
[basepod,orphanpod]=fun_sort_base_orphan(allgroup);
% survey_orphan=cell(1,length(allsurvey));
survey_orphan=fun_make_survey_orphan(allsurvey,obsend,orphanpod);

temp_added_orphan=[]; % 3-by-n: rows are (1) timegroup ID (2) survey (3) phase
temp_added_base=[]; % 1-by-n: timegroup ID 
temp_removed_basephase=[]; % 2-by-n: (1) phaseID (2) timegroup ID 

phaseplotted=[]; % 2-by-n: (1) phaseID (2) line handle
overlaybase=[]; % 2-by-n: 
overlayorphan=[]; % 2-by-1
[xmin,xmax,ymin,ymax]=deal([]);
vreduce=0;
colorcount=0;
needreset=false;
        
%---- UI
if ishandle(340);
    makeh = 340;
    set(makeh,'Visible','on');
else
    makeh = figure(340);
    set(makeh,'Visible','off','Name','Set Time Group Tool','NumberTitle','off','Position',[50,10,1200,680]);  % 'MenuBar','none',
    %---------- right control panel: from bottom to up
    rightph=uipanel(makeh,'Visible','off','Position',[.85 .0 .15 1],'FontSize',12);
    %--- save and plot panel
    rph0=uipanel(rightph,'Visible','on','Title','','Position',[.0 .00 1 0.1],'FontSize',12);
    uicontrol(rph0,'Style','pushbutton','String','Plot/Update','Tag','updateplot','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@updateplot_callback,'Units','normalized','Position',[.03 .52 .94 .43],'ForegroundColor','blue');
    uicontrol(rph0,'Style','pushbutton','String','Save current','Tag','savecurrent','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@save_callback,'Units','normalized','Position',[.03 .05 .94 .43],'ForegroundColor','red');
    %---- velocity
    rph1=uipanel(rightph,'Visible','on','Title','Reduced Velocity','TitlePosition','centertop','FontWeight','bold','Position',[.0 .10 1 0.15],'FontSize',12);
    depthcheck=uicontrol(rph1,'Style','checkbox','String','Use depth','Tag','usedepth','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@checkbox_callback,'Units','normalized','Position',[.1 .6 .8 .4],'ForegroundColor','blue');
    vedit3=uicontrol(rph1,'Style','edit','String','5','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.675 .3 0.3 .3]);
    vedit2=uicontrol(rph1,'Style','edit','String','0','Tag','vreduced','HorizontalAlignment','center','FontSize',10,'Units','normalized',...
        'Position',[.35 .3 0.3 .3],'Callback',@slider_callback);
    vedit1=uicontrol(rph1,'Style','edit','String','0','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.025 .3 0.3 .3]);
    sliderh=uicontrol(rph1,'Style','slider','String','','Tag','slider','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@slider_callback,'Units','normalized','Position',[.03 .05 .94 .2],'ForegroundColor','blue','Max',1,'Min',0,'Value',0);
    %--- x and t range panel
    rph2=uipanel(rightph,'Visible','on','Title','','TitlePosition','centertop','FontWeight','bold','Position',[.0 .25 1 0.1],'FontSize',12);
    xedit2=uicontrol(rph2,'Style','edit','String','','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.72 .55 0.25 .35]);
    uicontrol(rph2,'Style','text','String','Xmax','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.47 .55 0.25 .35],'FontWeight','bold');% ,'BackgroundColor',''
    xedit1=uicontrol(rph2,'Style','edit','String','','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.21 .55 0.25 .35]);
    uicontrol(rph2,'Style','text','String','Xmin','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.0 .55 0.2 .35],'FontWeight','bold'); %,'BackgroundColor',''
    tedit2=uicontrol(rph2,'Style','edit','String','','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.72 .1 0.25 .35]);
    uicontrol(rph2,'Style','text','String','Tmax','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.47 .1 0.25 .35],'FontWeight','bold');% ,'BackgroundColor',''
    tedit1=uicontrol(rph2,'Style','edit','String','','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.21 .1 0.25 .35]);
    uicontrol(rph2,'Style','text','String','Tmin','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.0 .1 0.2 .35],'FontWeight','bold'); %,'BackgroundColor',''
    %--- selection panel
    rph3=uipanel(rightph,'Visible','on','Title','Selection','TitlePosition','centertop','FontWeight','bold','Position',[.0 .35 1 0.65],'FontSize',12);
    uicontrol(rph3,'Style','text','String','OBS/SCS','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .96 0.9 .04],'FontWeight','bold','BackgroundColor','y');
    survey=uicontrol(rph3,'Style','listbox','String',allsurvey,'Tag','survey','Value',1,'Callback',@survey_callback,'HorizontalAlignment','center',...
        'FontSize',10,'Units','normalized','Position',[.05 .73 0.9 .23],'Max',1,'FontWeight','bold');
    uicontrol(rph3,'Style','text','String','Orphan Time Group','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .685 0.9 .04],'FontWeight','bold','BackgroundColor','y');
    orphanlist=uicontrol(rph3,'Style','listbox','String',num2cell(survey_orphan{1}),'Tag','orphan','HorizontalAlignment','center','FontSize',10,...
        'Units','normalized','Position',[.05 .15 0.9 .535],'Max',1,'FontWeight','bold','Callback',@survey_callback);
    orphancheck=uicontrol(rph3,'Style','checkbox','String','Overlay plot','Tag','orphancheckbox','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Units','normalized','Position',[.05 .1 .9 .04],'ForegroundColor','blue','Callback',@checkbox_callback);
    uicontrol(rph3,'Style','pushbutton','String','Add to current','Tag','orphan','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@addphase_callback,'Units','normalized','Position',[.05 .01 .9 .08],'ForegroundColor','red');
%     ---------- left panels: from top to bottom
%     ----- plot area
    left1=uipanel(makeh,'Visible','off','Position',[.0 .3 .7 0.7],'FontSize',12);
    axesh=subplot(1,1,1,'Parent',left1);   % create axes for plot
    %----- middle table
    left2=uipanel(makeh,'Visible','off','Title','Base Time Groups','TitlePosition','centertop','FontWeight','bold','Position',[.7 .3 .15 0.7],'FontSize',12);
    baselist=uicontrol(left2,'Style','listbox','String',num2cell(basepod),'HorizontalAlignment','center','FontSize',10,'Units','normalized',...
        'Position',[.05 .12 0.9 .88],'Max',1,'FontWeight','bold','Callback',@baselist_callback);
    basecheck=uicontrol(left2,'Style','checkbox','String','Overlay plot','Tag','basecheckbox','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Units','normalized','Position',[.05 .075 .9 .04],'ForegroundColor','blue','Callback',@checkbox_callback);
    uicontrol(left2,'Style','pushbutton','String','Add to current','Tag','base','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@addphase_callback,'Units','normalized','Position',[.05 .00 .9 .07],'ForegroundColor','red');
    
    %----- bottom table
    left3=uipanel(makeh,'Visible','off','Title','Current Selection','TitlePosition','centertop','FontWeight','bold','Position',[.0 .05 .85 0.25],'FontSize',10);
    symbollist={'.','x','o','+','*','s','d'};
    colorlist={'blue','green','red','cyan','magenta','yellow','black'};
    selectioncolname={'Survey','Name','Phase','ID','Group','Layer','Ray','Wave','Symbol','Color','Remarks','Select'};
    columnformat={'char', 'char', 'numeric', 'numeric','numeric', 'numeric','numeric','numeric',symbollist,colorlist,'char','logical'};
    columneditable=[false false false false false false false false true true false true];
    columnwidth={50 100 45 30 50 50 40 40 55 60 400 50};
    table1=uitable(left3,'Units','normalized','Position',[.0 .0 1 1],'ColumnName',selectioncolname,'ColumnFormat',columnformat,...
            'ColumnWidth',columnwidth,'ColumnEditable',columneditable,'FontSize',8,'CellEditCallback',@changeline_callback);
    %---- bottom buttons
    radiogroup = uibuttongroup(makeh,'visible','off','Title','','Position',[.0 .0 .85 .05],'SelectionChangeFcn',@selectionChange_callback);
    rbh1 = uicontrol(radiogroup,'Style','radiobutton','String','P-wave Reflection','FontWeight','bold','FontSize',12,...
        'Tag','1','Units','normalized','Position',[.025 .0 .2 1]);
    rbh2 = uicontrol(radiogroup,'Style','radiobutton','String','P-wave Refraction/Head wave','FontWeight','bold','FontSize',12,...
        'Tag','2','Units','normalized','Position',[.275 .0 .3 1]);
    rbh3 = uicontrol(radiogroup,'Style','radiobutton','String','S-wave Reflection','FontWeight','bold','FontSize',12,...
        'Tag','3','Units','normalized','Position',[.575 .0 .2 1]);
    uicontrol(radiogroup,'Style','pushbutton','String','Remove from current','Tag','removeitem','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@remove_callback,'Units','normalized','Position',[.825 .0 .15 1],'ForegroundColor','red');
    %------
    set(rightph,'Visible','on');
    set(left1,'Visible','on');
    set(left2,'Visible','on');
    set(left3,'Visible','on');
    set(radiogroup,'Visible','on');
    set(makeh,'Visible','on');
    set(makeh,'CloseRequestFcn',@my_closerequest)
end

uiwait(makeh);


%----- Callback Functions ------%
    function my_closerequest(hObject, eventdata)
        selection = questdlg('Do you want to save the changes to the database and exit?',...
            'Close Request Function','Yes','No','Cancel','Cancel');
        switch selection,
            case 'Yes'
                [newOBS,newSCS,newtimegroup,newphasegroup]=deal(OBS,SCS,timegroup,phasegroup);
                delete(makeh);
            case 'No'
                delete(makeh);
            case 'Cancel'
        end
    end

    function selectionChange_callback(hObject, eventdata)
        isclear=true;
        if ~isempty(get(table1,'Data'));
            selection = questdlg('You are changing to differnt ray or wave type. The current selection will be cleared! Will you save the current work?',...
                'Change ray/wave type','Yes','No','Cancel','Cancel');
            switch selection,
                case 'Yes'
                    save_callback;
                case 'No'
                case 'Cancel'
                    isclear=false;
                    set(hObject,'SelectedObject',eventdata.OldValue);
            end
        end
        if isclear;
            switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
                case '1'
                    radio_status=[true false false];
                case '2'
                    radio_status=[false true false];
                case '3'
                    radio_status=[false false true];
            end
            [temp_added_orphan,temp_added_base,tem_removed_basephase]=deal([]);
            set(table1,'Data',[]);
            [basepod,orphanpod]=fun_sort_base_orphan(allgroup);
            survey_orphan=fun_make_survey_orphan(allsurvey,obsend,orphanpod);
            set(baselist,'String',num2cell(basepod),'Value',1);
            set(orphanlist,'String',num2cell(survey_orphan{get(survey,'Value')}),'Value',1);
            [phaseplotted,overlaybase,overlayorphan]=deal([]);
            delete(axesh);
            axesh=subplot(1,1,1,'Parent',left1);
        end
    end

    function updateplot_callback(src,event)
        if isempty(get(xedit1,'String'))
            xmin=[];
        else
            xmin=eval(get(xedit1,'String'));
        end
        if isempty(get(xedit2,'String'))
            xmax=[];
        else
            xmax=eval(get(xedit2,'String'));
        end
        if isempty(get(tedit1,'String'));
            ymin=[];
        else
            ymin=eval(get(tedit1,'String'));
        end
        if isempty(get(tedit2,'String'));
            ymax=[];
        else
            ymax=eval(get(tedit2,'String'));
        end
        if isempty(get(vedit2,'String'));
            vreduce=0;
        else
            vreduce=eval(get(vedit2,'String'));
        end
        tabledata=get(table1,'Data');
        if isempty(tabledata);
            [phaseplotted,overlaybase,overlayorphan]=deal([]); % 2-by-n: (1) phaseID (2) line handle
            delete(axesh);
            axesh=subplot(1,1,1,'Parent',left1);
        else
            if needreset;
                [phaseplotted,overlaybase,overlayorphan]=deal([]); % 2-by-n: (1) phaseID (2) line handle
                delete(axesh);
                axesh=subplot(1,1,1,'Parent',left1);
            end
            for i=1:size(tabledata,1); % selectioncolname: 'Survey','Name','Phase','ID','Group','Layer','Ray','Wave','Symbol','Color','Remarks','Select';
                phaseID=tabledata{i,4};
                plotit=false;
                if isempty(phaseplotted)
                    plotit=true;
                elseif isempty(find(phaseplotted(1,:)==phaseID))
                    plotit=true;
                end
                if plotit;
                    hold (axesh,'on');
                    lh=fun_plot_phase(phaseID,tabledata{i,9},tabledata{i,10},tabledata{i,end});
                    set(lh,'DisplayName',[tabledata{i,2},':',num2str(tabledata{i,3})]);
                    phaseplotted=[phaseplotted [phaseID;lh]];
                end
            end
        end
        if ~isempty(xmin) && ~isempty(xmax)
            set(axesh,'XLim',[xmin xmax]);
        end
        if ~isempty(ymin) && ~isempty(ymax)
            set(axesh,'YLim',[ymin ymax]);
        end
        set(axesh,'YDir','reverse');
        grid(axesh,'minor');
        needreset=false;
    end

    function changeline_callback(src,event)
        row=event.Indices(1);
        data=get(src,'Data');
        lh=phaseplotted(2,phaseplotted(1,:)==data{row,4});
        if data{row,end}
            set(lh,'Marker',data{row,9},'Color',data{row,10},'Visible','on');
        else
            set(lh,'Marker',data{row,9},'Color',data{row,10},'Visible','off');
        end
    end

    function baselist_callback(src,event)
        if get(basecheck,'Value')==get(basecheck,'Max');
            index=get(baselist,'Value');
            if ~isempty(index)
                groupID=get(baselist,'String');
                groupID=eval(groupID{index});
                plotnew=true;
                if ~isempty(overlaybase)
                    if groupID==overlaybase(1,1);
                        plotnew=false;
                    else
                        delete(overlaybase(2,:));
                        overlaybase=[];
                    end
                end
                if plotnew;
                    index2=find(totalphase(:,2)==groupID);
                    hold (axesh,'on');
                    for i=1:length(index2);
                        phaseID=totalphase(index2(i),1);
                        colorcount=colorcount+1;
                        if colorcount>7;
                            colorcount=1;
                        end
                        overlaybase(1,i)=phaseID;
                        overlaybase(2,i)=fun_plot_phase(phaseID,'x',colorlist{colorcount},true);
                        set(overlaybase(2,i),'DisplayName',['Survey ',num2str(totalphase(index2(i),3)),':',num2str(totalphase(index2(i),4))]);
                    end
                    set(axesh,'YDir','reverse');
                    grid(axesh,'minor');
                end
            end
        end
    end

    function save_callback(src,event)
        needsave=true;
        newtotalphase=totalphase; % n-by-6 , columns are (1) phaseID; (2) group; (3) survey; (4) phase; (5) ray; (6) wave
        tabledata=get(table1,'Data'); % selectioncolname: 'Survey','Name','Phase','ID','Group','Layer','Ray','Wave','Symbol','Color','Remarks','Select';
        if isempty(tabledata)
            needsave=false;
        else
            tabledata=cell2mat(tabledata(:,[4 5]));
            availableID=[];
            for i=1:length(timegroup); 
                if isempty(timegroup{i})
                    availableID=[availableID i];
                end
            end
            if isempty(availableID)
                availableID=length(timegroup)+1;
            else
                availableID=min(availableID);
            end
            minID=min(tabledata(:,2));
            if availableID<minID
                minID=availableID;
            end
            for i=1:size(tabledata,1);
                newtotalphase(newtotalphase(:,1)==tabledata(i,1),2)=minID;
            end
            if ~isempty(temp_removed_basephase);
                for i=1:length(temp_removed_basephase(1,:));
                    newtotalphase(newtotalphase(:,1)==temp_removed_basephase(1,i),2)=length(timegroup)+i;
                end
            end
            if isempty(find(~(newtotalphase(:,2)==totalphase(:,2))))
                needsave=false;
            end
        end
        if needsave
            selection = questdlg('You are going to put the current selected phases (both checked and unchecked) into a same timegroup. Continue?',...
                'Save request','Yes','Cancel','Cancel');
            switch selection,
                case 'Yes'
                    index=find(~(newtotalphase(:,2)==totalphase(:,2)));
                    for i=1:length(index);
                        phaseID=newtotalphase(index(i),1);
                        surveyID=newtotalphase(index(i),3);
                        phasenumber=newtotalphase(index(i),4);
                        if surveyID>0;  % 属于OBS的走时
%                             OBS(surveyID).phase{phasenumber}(:,5)=OBS(surveyID).phase{phasenumber}(:,4);
                            OBS(surveyID).phase{phasenumber}(:,4)=newtotalphase(index(i),2);
                            OBS(surveyID).phaseID(2,newtotalphase(index(i),4))=newtotalphase(index(i),2);
                            for j=1:length(phasegroup);
                                if ~isempty(phasegroup(j).OBS);
                                    kkk=find(phasegroup(j).OBS(1,:)==phaseID);
                                    if ~isempty(kkk);
                                        phasegroup(j).OBS(2,kkk)=newtotalphase(index(i),2);
                                    end
                                end
                            end
                        else  % 属于SCS的走时
%                             SCS(-surveyID).phase{phasenumber}(:,5)=SCS(-surveyID).phase{phasenumber}(:,4);
                            SCS(-surveyID).phase{phasenumber}(:,4)=newtotalphase(index(i),2);
                            SCS(-surveyID).phaseID(2,newtotalphase(index(i),4))=newtotalphase(index(i),2);
                            for j=1:length(phasegroup);
                                if ~isempty(phasegroup(j).SCS);
                                    kkk=find(phasegroup(j).SCS(1,:)==phaseID);
                                    if ~isempty(kkk);
                                        phasegroup(j).SCS(2,kkk)=newtotalphase(index(i),2);
                                    end
                                end
                            end
                        end
                        if newtotalphase(index(i),2)>length(timegroup);
                            timegroup{newtotalphase(index(i),2)}=phaseID;
                        else
                            timegroup{minID}=[timegroup{minID} phaseID];
                        end
                        timegroup{totalphase(index(i),2)}(timegroup{totalphase(index(i),2)}==phaseID)=[];
                    end
                    totalphase=newtotalphase;
                    radio_status=[true false false];
                    set(radiogroup,'SelectedObject',rbh1);
                    % PL,PR,SL: P-wave reflection, P-wave refraction/headwave, S-wave reflection
                    % [plgroup,prgroup,slgroup]=deal({NaN(1,5)}); % each time group is a cell element, which for is a n-by-5 matrix, columns are
                    % (1)Time group number; (2) phase ID; (3)survey number(negative is SCS), (4) phase number, (5) base (1) or orphan (0)
                    [plgroup,prgroup,slgroup]=fun_sort_timegroup(timegroup,totalphase);
                    current={};  % hold one of plgroup,prgroup,slgroup depend on radio_status
                    allgroup={plgroup,prgroup,slgroup};
                    % [basepod,orphanpod]=deal([]); % basepod is a 1-by-n vector, store the timegroup number only; but the orphanpod is 3-by-n with rows: groupID,survey,phase
                    [basepod,orphanpod]=fun_sort_base_orphan(allgroup);
                    % survey_orphan=cell(1,length(allsurvey));
                    survey_orphan=fun_make_survey_orphan(allsurvey,obsend,orphanpod);
                    [temp_added_orphan,temp_added_base,temp_removed_basephase]=deal([]);
                    set(table1,'Data',[]);
                    set(baselist,'String',num2cell(basepod),'Value',1);
                    set(orphanlist,'String',num2cell(survey_orphan{get(survey,'Value')}),'Value',1);
                case 'Cancel'
            end
        end
    end

    function checkbox_callback(src,event)
        switch get(src,'Tag');
            case 'usedepth'
                needreset=true;
                updateplot_callback;
            case 'orphancheckbox'
                if get(src,'Value')==get(src,'Min');
                    if ~isempty(overlayorphan)
                        delete(overlayorphan(2));
                        overlayorphan=[];
                    end
                else
                    index=get(orphanlist,'Value');
                    if ~isempty(index)
                        groupID=get(orphanlist,'String');
                        groupID=eval(groupID{index});
                        index2=totalphase(:,2)==groupID;
                        overlayorphan(1)=totalphase(index2,1);
                        hold (axesh,'on');
                        overlayorphan(2)=fun_plot_phase(overlayorphan(1),'d','r',true);
                        set(overlayorphan(2),'DisplayName',['Survey ',num2str(totalphase(index2,3)),':',num2str(totalphase(index2,4))]);
                        set(axesh,'YDir','reverse');
                        grid(axesh,'minor');
                    end
                end
            case 'basecheckbox'
                if get(src,'Value')==get(src,'Min');
                    if ~isempty(overlaybase)
                        delete(overlaybase(2,:));
                        overlaybase=[];
                    end
                else
                    index=get(baselist,'Value');
                    if ~isempty(index)
                        groupID=get(baselist,'String');
                        groupID=eval(groupID{index});
                        index2=find(totalphase(:,2)==groupID);
                        hold (axesh,'on');
                        for i=1:length(index2);
                            phaseID=totalphase(index2(i),1);
                            colorcount=colorcount+1;
                            if colorcount>7;
                                colorcount=1;
                            end
                            overlaybase(1,i)=groupID;
                            overlaybase(2,i)=fun_plot_phase(phaseID,'x',colorlist{colorcount},true);
                            set(overlaybase(2,i),'DisplayName',['Survey ',num2str(totalphase(index2(i),3)),':',num2str(totalphase(index2(i),4))]);
                        end
                        set(axesh,'YDir','reverse');
                        grid(axesh,'minor');
                    end
                end
        end
    end

    function slider_callback(src,event)
        vmin=eval(get(vedit1,'String'));
        vmax=eval(get(vedit3,'String'));
        switch get(src,'Tag');
            case 'slider'
                ratio=get(src,'Value');
                vreduce=vmin+(vmax-vmin)*ratio;
                set(vedit2,'String',num2str(vreduce));
            case 'vreduced'
                vreduce=eval(get(src,'String'));
                if vreduce>100;
                    vreduce=vreduce/1000;
                end
                ratio=(vreduce-vmin)/(vmax-vmin);
                set(sliderh,'Value',ratio);
        end
        needreset=true;
    end

    function survey_callback(src,event)
        switch get(src,'Tag');
            case 'survey'
                set(orphanlist,'String',num2cell(survey_orphan{get(src,'Value')}),'Value',1);
            case 'orphan'
                if get(orphancheck,'Value')==get(orphancheck,'Max');
                    index=get(orphanlist,'Value');
                    if ~isempty(index)
                        groupID=get(orphanlist,'String');
                        groupID=eval(groupID{index});
                        index2=totalphase(:,2)==groupID;
                        phaseID=totalphase(index2,1);
                        plotnew=true;
                        if ~isempty(overlayorphan);
                            if phaseID==overlayorphan(1);
                                plotnew=false;
                            else
                                delete(overlayorphan(2));
                            end
                        end
                        if plotnew
                            overlayorphan(1)=phaseID;
                            hold (axesh,'on');
                            overlayorphan(2)=fun_plot_phase(phaseID,'d','r',true);
                            set(overlayorphan(2),'DisplayName',['Survey ',num2str(totalphase(index2,3)),':',num2str(totalphase(index2,4))]);
                            set(axesh,'YDir','reverse');
                            grid(axesh,'minor');
                        end
                    end
                end
        end
    end

    function addphase_callback(src,event)
        switch get(src,'Tag');
            case 'base'
                ss=get(baselist,'String');
                if ~isempty(ss);
                    ss=eval(ss{get(baselist,'Value')});
                    set(table1,'Data',fun_add_phase_to_table(ss));
                    temp_added_base=[temp_added_base ss];
                    basepod(basepod==ss)=[];
                    set(baselist,'String',num2cell(basepod),'Value',1);
                end
            case 'orphan'
                ss=get(orphanlist,'String');
                if ~isempty(ss);
                    ss=eval(ss{get(orphanlist,'Value')});
                    set(table1,'Data',fun_add_phase_to_table(ss));
                    index=orphanpod(1,:)==ss;
                    temp_added_orphan=[temp_added_orphan orphanpod(:,index)];
                    orphanpod(:,index)=[];
                    survey_orphan=fun_make_survey_orphan(allsurvey,obsend,orphanpod);
                    set(orphanlist,'String',num2cell(survey_orphan{get(survey,'Value')}),'Value',1);
                end
        end
        needreset=true;
        updateplot_callback;
    end

    function remove_callback(src,event)
        isremove=true;
        tabledata=get(table1,'Data');
        selection = questdlg('What items are you going to remove from current selection?',...
            'Remove phases','Checked','Unchecked','Cancel','Cancel');
        switch selection,
            case 'Checked'
                selected=find(cell2mat(tabledata(:,end)));
            case 'Unchecked'
                selected=find(~cell2mat(tabledata(:,end)));
            case 'Cancel'
                isremove=false;
        end
        if isremove;
            if ~isempty(selected);
                changed_base=[];
                for i=1:length(selected);
                    groupid=tabledata{selected(i),5};
                    frombase=find(temp_added_base==groupid);
                    if isempty(frombase);  % from orphan
                        index=temp_added_orphan(1,:)==groupid;
                        orphanpod=[orphanpod temp_added_orphan(:,index)];
                        temp_added_orphan(:,index)=[];
                    else  % from base
                        if isempty(changed_base==groupid);
                            changed_base=[changed_base groupid];
                        end
                    end
                end
                temp_removed_basephase=[temp_removed_basephase cell2mat(tabledata(selected,[4 5]))'];
                for k=1:length(selected)
                    whichphase=phaseplotted(1,:)==tabledata{selected(k),4};
                    delete(phaseplotted(2,whichphase));
                    phaseplotted(:,whichphase)=[];
                end
                tabledata(selected,:)=[];
                restgroup=cell2mat(tabledata(:,5));
                for i=1:length(changed_base);
                    if isempty(find(changed_base(i)==restgroup));  % all phases removed, so this group should return basepod
                        index=temp_added_base==changed_base(i);
                        basepod=[basepod temp_added_base(index)];
                        temp_removed_basephase(:,temp_removed_basephase(2,:)==temp_added_base(index))=[];
                        temp_added_base(index)=[];
                    end
                end
                survey_orphan=fun_make_survey_orphan(allsurvey,obsend,orphanpod);
                set(baselist,'String',num2cell(basepod),'Value',1);
                set(orphanlist,'String',num2cell(survey_orphan{get(survey,'Value')}),'Value',1);
                set(table1,'Data',tabledata);
            end
        end
    end

%------ tool functions ------
    function [plgroup,prgroup,slgroup]=fun_sort_timegroup(timegroup,totalphase)
        [plgroup,prgroup,slgroup]=deal([]);
        for i=1:length(timegroup)
            groupcopy=timegroup{i};
            if ~isempty(groupcopy);
                phasecount=length(groupcopy);
                if phasecount==1;
                    isbase=0;
                else
                    isbase=1;
                end
                phasecopy=totalphase(totalphase(:,2)==i,:);
                raytype=phasecopy(1,5);
                wavetype=phasecopy(1,6);
                temp=[phasecopy(:,[2 1 3 4]) ones(phasecount,1)*isbase];
                if raytype==2 && wavetype==1;
                    plgroup=[plgroup {temp}];
                elseif raytype==2 && wavetype==2;
                    slgroup=[slgroup {temp}];
                else
                    prgroup=[prgroup {temp}];
                end
            end
        end
    end

    function [basepod,orphanpod]=fun_sort_base_orphan(allgroup)
        current=allgroup{find(radio_status)};
        [basepod,orphanpod]=deal([]);
        for i=1:length(current)
            switch current{i}(1,5)
                case 1
                    basepod=[basepod current{i}(1,1)];
                case 0
                    orphanpod=[orphanpod current{i}(1,[1 3 4])'];  % rows are (1) timegroup ID (2) survey (3) phase
            end
        end
    end

    function survey_orphan=fun_make_survey_orphan(allsurvey,obsend,orphanpod)
        survey_orphan={};
        if size(orphanpod,2)>0
            for i=1:length(allsurvey);
                if i<=obsend;
                    survey_orphan{i}=orphanpod(1,orphanpod(2,:)==i);
                else
                    survey_orphan{i}=orphanpod(1,orphanpod(2,:)==obsend-i);
                end
            end
        else
            survey_orphan{length(allsurvey)}=[];
        end
    end

    function tabledata=fun_add_phase_to_table(groupID)
        tabledata=get(table1,'Data');
        phaselist=totalphase(totalphase(:,2)==groupID,:);  % n-by-6 , columns are (1) phaseID; (2) group; (3) survey; (4) phase; (5) ray; (6) wave
        for i=1:size(phaselist,1);
            % selectioncolname: 'Survey','Name','Phase','ID','Group','Layer','Ray','Wave','Symbol','Color','Remarks','Select';
            if phaselist(i,3)>0;
                currentsurvey=OBS(phaselist(i,3));
                ss=['OBS #',num2str(phaselist(i,3))];
            else
                currentsurvey=SCS(-phaselist(i,3));
                ss=['SCS #',num2str(-phaselist(i,3))];
            end
            colorcount=colorcount+1;
            if colorcount>7;
                colorcount=1;
            end
            row={ss, currentsurvey.name, phaselist(i,4), phaselist(i,1), groupID, currentsurvey.phase{phaselist(i,4)}(1,7), currentsurvey.phase{phaselist(i,4)}(1,8),...
                currentsurvey.phase{phaselist(i,4)}(1,9), '.', colorlist{colorcount}, currentsurvey.remarks{phaselist(i,4)}, true};
            tabledata=[tabledata; row];
        end
    end

    function handle=fun_plot_phase(ID,marker,color,visible)
        [offset,source]=deal([]);
        phasedetail=totalphase(totalphase(:,1)==ID,:); % n-by-6 , columns are (1) phaseID; (2) group; (3) survey; (4) phase; (5) ray; (6) wave
        if phasedetail(3)>0;
            data=OBS(phasedetail(3));
            source=data.moffset;
        else
            data=SCS(-phasedetail(3));
            offset=0;
        end
        x=data.phase{phasedetail(4)}(:,1);
        y=data.phase{phasedetail(4)}(:,2);
        depths=zeros(length(x),1);
        if get(depthcheck,'Max')==get(depthcheck,'Value');
            if size(depthnodes,2)==1;
                depths(:)=depthnodes(2,1);
            else
                if offset==0;
                    depths=interp1(depthnodes(1,:),depthnodes(2,:),x,'nearest','extrap');
                else
                    depths(:)=depthnodes(2,phasedetail(3));
                end
            end
        end
        if vreduce>0;
            if offset==0; % SCS case
                y=y-2*depths/vreduce;
            else
                offset=abs(x-source);
                y=y-sqrt(depths.^2+offset.^2)/vreduce;
            end
        end
        if visible
            handle=plot(axesh,x,y,[marker color]);
        else
            handle=plot(axesh,x,y,[marker color],'Visible','off');
        end
    end

end % function