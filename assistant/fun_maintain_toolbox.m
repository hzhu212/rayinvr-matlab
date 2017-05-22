function [newOBS,newSCS,newtimegroup,newphasegroup,newphasecollection]=fun_maintain_toolbox...
    (OBS,SCS,origin,strike,timegroup,phasegroup,phasecollection)

% variables valid for whole function
[newOBS,newSCS,newtimegroup,newphasegroup,newphasecollection]=deal(OBS,SCS,timegroup,phasegroup,phasecollection);
allsurvey=[fun_make_popup_strings(OBS,'OBS') fun_make_popup_strings(SCS,'SCS')];
obsend=length(OBS);
                    
lookup=[]; % columns are (1) phase ID, (2) survey number(negative is SCS), (3) phase number, (4) selection
table1data={};
table2data=[];
phasecount=0;
timegrouppod=[];

%---- UI
if ishandle(320);
    mth = 320;
    set(mth,'Visible','on');
else
    mth = figure(320);
    set(mth,'Visible','off','Name','Database Maintain Tool','MenuBar','none','NumberTitle','off','Position',[10,10,1200,720]);
    %---------- right control panel: from bottom to up
    rightph=uipanel(mth,'Visible','on','Position',[.82 .0 .18 1],'FontSize',12);
    %--- check all/clear all panel
    rph1=uipanel(rightph,'Visible','on','Title','','Position',[.0 .00 1 0.2],'FontSize',12);
    uicontrol(rph1,'Style','pushbutton','String','Check All','Tag','checkall','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.03 .76 .94 .2],'ForegroundColor','blue');
    uicontrol(rph1,'Style','pushbutton','String','Clear All Checks','Tag','clearall','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.03 .52 .94 .2],'ForegroundColor','blue');
    uicontrol(rph1,'Style','pushbutton','String','Flip Checks','Tag','flip','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.03 .28 .94 .2],'ForegroundColor','blue');
    uicontrol(rph1,'Style','pushbutton','String','Remove Selected Items','Tag','removechecked','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.03 .04 .94 .2],'ForegroundColor','red');
    %--- set single column value panel
    rph2=uipanel(rightph,'Visible','on','Title','Batch change','TitlePosition','centertop','FontWeight','bold','Position',[.0 .20 1 0.15],'FontSize',12);
    pop1=uicontrol(rph2,'Style','popup','String',{'Pick uncertainty (s)','Model layer','Ray type (1 refraction, 2 refelction, 3 head wave)','Wave type (1 P-wave, 2 S-wave)',...
        'Time correction (s)','And phase remarks in front','Append phase remarks at end','(Carefull!) Replace phase remarks'},'FontWeight','bold','FontSize',10,'Units','normalized','Position',[.03 .82 0.94 .15],'Callback','');
    edit1=uicontrol(rph2,'Style','edit','String','','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.03 .4 0.94 .25]);
    uicontrol(rph2,'Style','pushbutton','String','Set','Tag','column','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setvalue_callback,'Units','normalized','Position',[.03 .05 .94 .3],'ForegroundColor','red');
    %--- selection panel
    rph3=uipanel(rightph,'Visible','on','Title','Selection','TitlePosition','centertop','FontWeight','bold','Position',[.0 .35 1 0.65],'FontSize',12);
    uicontrol(rph3,'Style','text','String','OBS/SCS','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .96 0.9 .04],'FontWeight','bold','BackgroundColor','y');
    survey=uicontrol(rph3,'Style','listbox','String',allsurvey,'Tag','survey','Value',1,'Callback',@survey_callback,'HorizontalAlignment','center',...
        'FontSize',10,'Units','normalized','Position',[.05 .68 0.9 .28],'Max',100,'FontWeight','bold');
    timegrouppod=fun_make_timegrouppod;
    uicontrol(rph3,'Style','text','String','Time Group','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .64 0.9 .04],'FontWeight','bold','BackgroundColor','y');
    timelist=uicontrol(rph3,'Style','listbox','String',num2cell(timegrouppod),'HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .22 0.9 .42],'Max',1000,'FontWeight','bold');
    checkbox=uicontrol(rph3,'Style','checkbox','String','All time groups','Tag','checkbox','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@checkbox_callback,'Units','normalized','Position',[.05 .17 .9 .04],'ForegroundColor','red');
    uicontrol(rph3,'Style','text','String','Example line number','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .125 0.9 .04],'FontWeight','bold');
    edit2=uicontrol(rph3,'Style','edit','String','','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .07 0.9 .05]);
    uicontrol(rph3,'Style','pushbutton','String','Select','Tag','column','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@select_callback,'Units','normalized','Position',[.05 .005 .9 .055],'ForegroundColor','red');
%     ---------- left panels: from top to bottom
%     ----- top buttons
    left1=uipanel(mth,'Visible','on','Position',[.0 .95 .82 0.05],'FontSize',12);
    uicontrol(left1,'Style','pushbutton','String','Delete...','Tag','delete','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@pb_callback,'Units','normalized','Position',[.05 .05 .14 .9],'ForegroundColor','red');
    uicontrol(left1,'Style','pushbutton','String','Split','Tag','split','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@pb_callback,'Units','normalized','Position',[.23 .05 .14 .9],'ForegroundColor','red');
    uicontrol(left1,'Style','pushbutton','String','Combine','Tag','combine','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@pb_callback,'Units','normalized','Position',[.41 .05 .14 .9],'ForegroundColor','red');
    uicontrol(left1,'Style','pushbutton','String','Calculate shot-offset table','Tag','shotoffset','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@pb_callback,'Units','normalized','Position',[.59 .05 .18 .9],'ForegroundColor','blue');
    uicontrol(left1,'Style','pushbutton','String','Smart fill','Tag','sfill','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@pb_callback,'Units','normalized','Position',[.81 .05 .14 .9],'ForegroundColor','blue');
    %----- middle table
    left2=uipanel(mth,'Visible','on','Title','Selected Phases','TitlePosition','centertop','FontWeight','bold','Position',[.0 .475 .82 0.475],'FontSize',12);
%     selectioncolname={'OBS/SCS','Name','Phase','ID','Group','Offset Table','Layer','Ray','Wave','Remarks','Select'};
    selectioncolname={'OBS/SCS','Name','Phase','ID','Group','Offset Table','Layer','Ray','Wave','Remarks',''};
    columnformat={'char', 'char', 'numeric', 'numeric','numeric','char', 'numeric','numeric', 'numeric','char','logical'};
    columneditable=[false false false false false false false false false true true];
    columnwidth={'auto' 80 50 40 50 'auto' 50 40 40 400 20};
    table1=uitable(left2,'Units','normalized','Position',[.0 .0 1 1],'ColumnName',selectioncolname,'ColumnFormat',columnformat,...
            'ColumnWidth',columnwidth,'ColumnEditable',columneditable,'FontSize',10);
    %----- bottom table
    left3=uipanel(mth,'Visible','on','Title','Example Lines','TitlePosition','centertop','FontWeight','bold','Position',[.0 .0 .82 0.475],'FontSize',12);
    phasecolname={'Receiver (km)','Travel time (s)','Uncertainty','Group','Orig. group','Direction','Model layer','Ray type','Wave type',...
        'Shot number','Orig. pick','Time correct'};
    table2=uitable(left3,'Units','normalized','Position',[.0 .0 1 1],'ColumnName',phasecolname);
    
    set(mth,'Visible','on');
    set(mth,'CloseRequestFcn',@my_closerequest)
end

uiwait(mth);


%----- Callback Functions ------%
    function my_closerequest(hObject, eventdata)
        selection = questdlg('Do you want to save the changes and exit?',...
            'Close Request Function',...
            'Yes','No','Cancel','Cancel');
        switch selection,
            case 'Yes'
                [newOBS,newSCS,newtimegroup,newphasegroup,newphasecollection]=deal(OBS,SCS,timegroup,phasegroup,phasecollection);
                delete(mth);
            case 'No'
                delete(mth);
            case 'Cancel'
        end
    end

    function survey_callback(src,event)
        timegrouppod=fun_make_timegrouppod;
        set(timelist,'String',num2cell(timegrouppod));
        set(timelist,'Value',1);
        checkbox_callback;
    end

    function checkbox_callback(src,event)
        src=checkbox;
        switch get(src,'Value')
            case  get(src,'Max'); % selected
                set(timelist,'Value',1:length(get(timelist,'String')));
            case get(src,'Min'); % unselected
                set(timelist,'Value',1);
        end
    end

    function pb_callback(src,event)
        switch get(src,'Tag')
            case 'delete'
                fun_delete;
                allsurvey=[fun_make_popup_strings(OBS,'OBS') fun_make_popup_strings(SCS,'SCS')];
                obsend=length(OBS);
                set(table1,'Data',[]);
                set(table2,'Data',[]);
                set(survey,'String',allsurvey);
                set(survey,'Value',1);
                survey_callback;
            case 'split'
            case 'combine'
            case 'shotoffset'
                selection = questdlg('You need .ahl or ASCII file have shot number, X and Y coordinates, as well as model orgin and strike. Do you want to go on ?',...
                    'Request confirm','Yes','No','Yes');
                switch selection,
                    case 'Yes'
                        fun_shotoffset();                        
                    case 'No'
                end
            case 'sfill'
                selection = questdlg('"Smart Fill" will replace NaN based on exist information. Do you want to go on ?','Request confirm','Yes','No','No');
                switch selection,
                    case 'Yes'
                        fun_smartfill();
                    case 'No'
                end
        end
    end

    function select_callback(src,event)
        index1=get(survey,'Value');
        index2=get(timelist,'Value');
        if ~isempty(index1) && ~isempty(index2)
            selection = questdlg('Have you made the dicision ?','Request confirm','Yes','No','No');
            switch selection;
                case 'Yes';
                    totalID=[];
                    phasecount=0;
                    phaseid=0;
                    line=sscanf(get(edit2,'String'),'%f');
                    if isempty(line);
                        line=1;
                    end
                    for i=1:length(index2);
                        totalID=[totalID timegroup{timegrouppod(index2(i))}];
                    end
                    totalID=sort(totalID);
                    lookup=NaN(length(totalID),4); % (1) phase ID, (2) survey number(negative is SCS), (3) phase number, (4) selection
                    table1data=cell(length(totalID),length(selectioncolname));
                    table2data=NaN(length(totalID),length(phasecolname));
                    obsselect=find(index1<=obsend);
                    scsselect=find(index1>obsend);
                    if ~isempty(obsselect);
                        obsselect=index1(obsselect);
                        for i=1:length(obsselect);
                            obsnumber=obsselect(i);
                            for j=1:length(OBS(obsnumber).phase);
                                phaseid=OBS(obsnumber).phaseID(1,j);
                                if ~isempty(find(totalID==phaseid));
                                    phasecount=phasecount+1;
                                    lookup(phasecount,:)=[phaseid obsnumber j 1];
                                    table2data(phasecount,:)=OBS(obsnumber).phase{j}(line,:);
                                    if isempty(OBS(obsnumber).offsettable)
                                        offsettable='No';
                                    else
                                        offsettable='Yes';
                                    end
                                    if isempty(OBS(obsnumber).remarks)
                                        remarks='';
                                    else
                                        remarks=OBS(obsnumber).remarks{j};
                                    end
                                    % {'OBS/SCS','Name','Phase number','Phase ID','Group','Offset Table','Model layer','Ray type','Wave type','Select'};
                                    table1data(phasecount,:)={['OBS #',num2str(obsnumber)], OBS(obsnumber).name, j, phaseid, table2data(phasecount,4), offsettable, ...
                                        table2data(phasecount,7), table2data(phasecount,8), table2data(phasecount,9), remarks, true};
                                end
                            end
                        end
                    end
                    if ~isempty(scsselect);
                        scsselect=index1(scsselect)-obsend;
                        for i=1:length(scsselect);
                            scsnumber=scsselect(i);
                            for j=1:length(SCS(scsnumber).phase);
                                phaseid=SCS(scsnumber).phaseID(1,j);
                                if ~isempty(find(totalID==phaseid));
                                    phasecount=phasecount+1;
                                    lookup(phasecount,:)=[phaseid -scsnumber j 1];
                                    table2data(phasecount,:)=SCS(scsnumber).phase{j}(line,:);
                                    if isempty(SCS(scsnumber).offsettable)
                                        offsettable='No';
                                    else
                                        offsettable='Yes';
                                    end
                                    if isempty(SCS(scsnumber).remarks)
                                        remarks='';
                                    else
                                        remarks=SCS(scsnumber).remarks{j};
                                    end
                                    % {'OBS/SCS','Name','Phase number','Phase ID','Group','Offset Table','Model layer','Ray type','Wave type','Select'};
                                    table1data(phasecount,:)={['SCS #',num2str(scsnumber)], SCS(scsnumber).name, j, phaseid, table2data(phasecount,4), offsettable, ...
                                        table2data(phasecount,7), table2data(phasecount,8), table2data(phasecount,9), remarks, true};
                                end
                            end
                        end
                    end
                    lookup=lookup(1:phasecount,:);
                    table1data=table1data(1:phasecount,:);
                    table2data=table2data(1:phasecount,:);
                    set(table1,'Data',table1data);
                    set(table2,'Data',table2data);
                    case 'No';
            end
        end
    end

    function setvalue_callback(src,event)
        pop1value=get(pop1,'Value');
        ss=strtrim(get(edit1,'String'));
        if pop1value<6;
            ss=sscanf(get(edit1,'String'),'%f');
        end
        if ~isempty(ss);
            selection = questdlg('Do you want to make the change ?','Request confirm','Yes','No','No');
            switch selection,
                case 'Yes'
                    table1data=get(table1,'Data');
                    for i=1:phasecount;
                        if table1data{i,end}
                            lookup(i,end)=1;
                            if lookup(i,2)>0;
                                sname='OBS';
                                snumber=lookup(i,2);
                            else
                                sname='SCS';
                                snumber=abs(lookup(i,2));
                            end
                            pnumber=lookup(i,3);
                            switch pop1value;
                                case 1; % 'Pick uncertainty (s)'
                                    if ss>1;
                                        ss=ss/1000;
                                    end
                                    eval([sname,'(',num2str(snumber),').phase{',num2str(pnumber),'}(:,3)=ss;']);
                                    table2data(i,3)=ss;
                                case 2; % 'Model layer'
                                    eval([sname,'(',num2str(snumber),').phase{',num2str(pnumber),'}(:,7)=ss;']);
                                    table2data(i,7)=ss;
                                case 3; % 'Ray type (1 refraction, 2 refelction, 3 head wave'
                                    eval([sname,'(',num2str(snumber),').phase{',num2str(pnumber),'}(:,8)=ss;']);
                                    table2data(i,8)=ss;
                                case 4; % 'Wave type (1 P-wave, 2 S-wave)'
                                    eval([sname,'(',num2str(snumber),').phase{',num2str(pnumber),'}(:,9)=ss;']);
                                    table2data(i,9)=ss;
                                case 5; % 'Time correction (s)'},
                                    if ss>1;
                                        ss=ss/1000;
                                    end
                                    eval([sname,'(',num2str(snumber),').phase{',num2str(pnumber),'}(:,12)=ss;']);
                                    table2data(i,12)=ss;
                                case 6; % 'And phase remarks in front'
                                    eval([sname,'(',num2str(snumber),').remarks{',num2str(pnumber),'}=[ss,'' '',',...
                                        sname,'(',num2str(snumber),').remarks{',num2str(pnumber),'}];']);
                                    table1data(i,10)=eval([sname,'(',num2str(snumber),').remarks(',num2str(pnumber),');']);
                                case 7; % 'Append phase remarks'
                                    eval([sname,'(',num2str(snumber),').remarks{',num2str(pnumber),'}=['...
                                        sname,'(',num2str(snumber),').remarks{',num2str(pnumber),'},'' '',ss;]']);
                                    table1data(i,10)=eval([sname,'(',num2str(snumber),').remarks(',num2str(pnumber),');']);
                                case 8; % 'Replace phase remarks'
                                    eval([sname,'(',num2str(snumber),').remarks{',num2str(pnumber),'}=get(edit1,''String'');']);
                                    table1data(i,10)=eval([sname,'(',num2str(snumber),').remarks(',num2str(pnumber),');']);
                            end
                        else
                            lookup(i,end)=0;
                        end
                    end
                    set(table1,'Data',table1data(1:phasecount,:));
                    set(table2,'Data',table2data(1:phasecount,:));
                case 'No'
            end
        end
    end

    function setcheck_callback(src,event)
        table1data=get(table1,'Data');
        table2data=get(table2,'Data');
        lookup(:,end)=cell2mat(table1data(:,end));
        switch get(src,'Tag')
            case 'checkall'
                lookup(:,end)=1;
                table1data(:,end)={true};
                set(table1,'Data',table1data);
            case 'clearall'
                lookup(:,end)=0;
                table1data(:,end)={false};
                set(table1,'Data',table1data);
            case 'flip'
                lookup(:,end)=~lookup(:,end);
                table1data(:,end)=num2cell(logical(lookup(:,end)));
                set(table1,'Data',table1data);
            case 'removechecked'
                table1data(logical(lookup(:,end)),:)=[];
                table2data(logical(lookup(:,end)),:)=[];
                set(table1,'Data',table1data);
                set(table2,'Data',table2data);
                lookup(logical(lookup(:,end)),:)=[];
        end
    end

    function timegrouppod=fun_make_timegrouppod
        surveylist=get(survey,'Value');
        timegrouppod=[];
        for i=1:length(surveylist)
            if surveylist(i)>obsend; % SCS
                if ~isempty(SCS)
                    s=SCS(surveylist(i)-obsend);
                else
                    s.phase=[];
                end
            else
                s=OBS(surveylist(i));
            end
            for j=1:size(s.phase,2)
                if isempty(find(timegrouppod==s.phaseID(2,j)));
                    timegrouppod=[timegrouppod s.phaseID(2,j)];
                end
            end
        end
        timegrouppod=sort(timegrouppod);
    end

    function fun_delete
        selection = questdlg('Are you sure you want to delete?','Delete request',...
            'Selected phases','OBS/SCS if phase empty','Cancel','Cancel');
        switch selection,
            case 'Selected phases'
                deletelist=lookup(logical(lookup(:,end)),1:3); % columns are (1) phase ID, (2) survey number(negative is SCS), (3) phase number, (4) selection
                deletelist=sortrows(deletelist,[2 3]); % now from SCS to OBS, and phase number increasing
                scspart=deletelist(deletelist(:,2)<0,:);
                if ~isempty(scspart);
                    SCS.phase(scspart(:,3))=[];
                    IDcopy=SCS.phaseID(:,scspart(:,3));
                    SCS.phaseID(:,scspart(:,3))=[];
                    SCS.phasefile(scspart(:,3))=[];
                    SCS.remarks(scspart(:,3))=[];
                    for j=1:length(IDcopy(1,:))
                        index=timegroup{IDcopy(2,j)}==IDcopy(1,j);
                        timegroup{IDcopy(2,j)}(index)=[];
                    end
                    if isempty(SCS.phase);
                        warndlg('There is no phases in SCS database any more!');
                    end
                end
                for i=1:length(OBS);
                    obspart=deletelist(deletelist(:,2)==i,:);
                    if ~isempty(obspart);
                        OBS(i).phase(obspart(:,3))=[];
                        IDcopy=OBS(i).phaseID(:,obspart(:,3));
                        OBS(i).phaseID(:,obspart(:,3))=[];
                        OBS(i).phasefile(obspart(:,3))=[];
                        OBS(i).remarks(obspart(:,3))=[];
                        for j=1:length(IDcopy(1,:))
                            index=timegroup{IDcopy(2,j)}==IDcopy(1,j);
                            timegroup{IDcopy(2,j)}(index)=[];
                        end
                        if isempty(OBS(i).phase);
                            warndlg(['There is no phases in OBS #',num2str(i),' any more!']);
                        end
                    end
                end
                for i=1:size(deletelist,1);
                    phasecollection(phasecollection==deletelist(i,1))=[];
                end
                for i=1:size(phasegroup,2);
                    for j=1:size(deletelist,1);
                        if ~isempty(phasegroup(i).OBS)
                            index=phasegroup(i).OBS(1,:)==deletelist(j,1);
                            phasegroup(i).OBS(:,index)=[];
                        end
                        if ~isempty(phasegroup(i).SCS)
                            index=phasegroup(i).SCS(1,:)==deletelist(j,1);
                            phasegroup(i).SCS(:,index)=[];
                        end
                    end
                end
            case 'OBS/SCS if phase empty'
                obsdelete= false(1,length(OBS));
                for i=1:length(OBS);
                    if isempty(OBS(i).phase);
                        obsdelete(i)=true;
                    end
                end
                OBS(obsdelete)=[];
                if isempty(OBS);
                    warndlg('There is no OBS survey in the database any more!');
                    OBS=struct('name','','XYZ',NaN(1,4),'LatLon',NaN(1,2),'moffset',NaN,'phase',{},'phaseID',{},'phasefile',{},'remarks',{},'offsettable',{},'tablefile','');
                end
                scsdelete= false(1,length(SCS));
                for i=1:length(SCS);
                    if isempty(SCS(i).phase);
                        scsdelete(i)=true;
                    end
                end
                SCS(scsdelete)=[];
                if isempty(SCS);
                    warndlg('There is no Single Channel Survey in the database any more!');
                    SCS=struct('name','','shot_rec',NaN,'phase',{},'phaseID',{},'phasefile',{},'remarks',{},'offsettable',{},'tablefile','');
                end
            case 'Cancel'
        end
    end

    function fun_smartfill
        table1data=get(table1,'Data');
        line=sscanf(get(edit2,'String'),'%f');
        if isempty(line);
            line=1;
        end
        for i=1:phasecount;
            if table1data{i,end}
                lookup(i,end)=1;
                if lookup(i,2)>0;
                    sname='OBS';
                    snumber=lookup(i,2);
                else
                    sname='SCS';
                    snumber=abs(lookup(i,2));
                end
                pnumber=lookup(i,3);
                switch sname;
                    case 'OBS'
                        if ~isempty(OBS(snumber).offsettable);
                            if isnan(OBS(snumber).phase{pnumber}(1,10)) && ~isnan(OBS(snumber).phase{pnumber}(1,1));
                                OBS(snumber).phase{pnumber}(:,10)=round(interp1(OBS(snumber).offsettable(:,2),OBS(snumber).offsettable(:,1),OBS(snumber).phase{pnumber}(:,1)));
                                table2data(i,10)=OBS(snumber).phase{pnumber}(line,10);
                            elseif ~isnan(OBS(snumber).phase{pnumber}(1,10)) && isnan(OBS(snumber).phase{pnumber}(1,1));
                                OBS(snumber).phase{pnumber}(:,1)=interp1(OBS(snumber).offsettable(:,1),OBS(snumber).offsettable(:,2),OBS(snumber).phase{pnumber}(:,10));
                                table2data(i,1)=OBS(snumber).phase{pnumber}(line,1);
                            end
                        end
                        if isnan(OBS(snumber).phase{pnumber}(1,6)) && ~isnan(OBS(snumber).phase{pnumber}(1,1));
                            middle=find(OBS(snumber).phase{pnumber}(:,1)>=OBS(snumber).moffset);
                            OBS(snumber).phase{pnumber}(1:middle-1,6)=-1;
                            OBS(snumber).phase{pnumber}(middle:end,6)=1;
                            table2data(i,6)=OBS(snumber).phase{pnumber}(line,6);
                        end
                        if ~isnan(OBS(snumber).phase{pnumber}(1,12));
                            if isnan(OBS(snumber).phase{pnumber}(1,11)) && ~isnan(OBS(snumber).phase{pnumber}(1,2));
                                OBS(snumber).phase{pnumber}(:,11)=OBS(snumber).phase{pnumber}(:,2)-OBS(snumber).phase{pnumber}(:,12);
                                table2data(i,11)=OBS(snumber).phase{pnumber}(line,11);
                            elseif ~isnan(OBS(snumber).phase{pnumber}(1,11)) && isnan(OBS(snumber).phase{pnumber}(1,2));
                                OBS(snumber).phase{pnumber}(:,2)=OBS(snumber).phase{pnumber}(:,11)+OBS(snumber).phase{pnumber}(:,12);
                                table2data(i,2)=OBS(snumber).phase{pnumber}(line,2);
                            end
                        end
                    case 'SCS'
                        if ~isempty(SCS(snumber).offsettable);
                            if isnan(SCS(snumber).phase{pnumber}(1,10)) && ~isnan(SCS(snumber).phase{pnumber}(1,1));
                                SCS(snumber).phase{pnumber}(:,10)=round(interp1(SCS(snumber).offsettable(:,2),SCS(snumber).offsettable(:,1),SCS(snumber).phase{pnumber}(:,1)));
                                table2data(i,10)=SCS(snumber).phase{pnumber}(line,10);
                            elseif ~isnan(SCS(snumber).phase{pnumber}(1,10)) && isnan(SCS(snumber).phase{pnumber}(1,1));
                                SCS(snumber).phase{pnumber}(:,1)=interp1(SCS(snumber).offsettable(:,1),SCS(snumber).offsettable(:,2),SCS(snumber).phase{pnumber}(:,10));
                                table2data(i,1)=SCS(snumber).phase{pnumber}(line,1);
                            end
                        end
                        if isnan(SCS(snumber).phase{pnumber}(1,6));
                            SCS(snumber).phase{pnumber}(:,6)=1;
                            table2data(i,6)=SCS(snumber).phase{pnumber}(line,6);
                        end
                        if ~isnan(SCS(snumber).phase{pnumber}(1,12));
                            if isnan(SCS(snumber).phase{pnumber}(1,11)) && ~isnan(SCS(snumber).phase{pnumber}(1,2));
                                SCS(snumber).phase{pnumber}(:,11)=SCS(snumber).phase{pnumber}(:,2)-SCS(snumber).phase{pnumber}(:,12);
                                table2data(i,11)=SCS(snumber).phase{pnumber}(line,11);
                            elseif ~isnan(SCS(snumber).phase{pnumber}(1,11)) && isnan(SCS(snumber).phase{pnumber}(1,2));
                                SCS(snumber).phase{pnumber}(:,2)=SCS(snumber).phase{pnumber}(:,11)+SCS(snumber).phase{pnumber}(:,12);
                                table2data(i,2)=SCS(snumber).phase{pnumber}(line,2);
                            end
                        end
                end
            else
                lookup(i,end)=0;
            end
        end
        set(table2,'Data',table2data);
    end

    function fun_shotoffset
        [pickname,pickpath]=uigetfile(fullfile('*.ahl'));
        if ~isscalar(pickname)  % when cacel, name==0
            pickfull=fullfile(pickpath,pickname);
            imdata=importdata(pickfull);
            if isstruct(imdata);
                imdata=imdata.data(:,[1 3 4 5]);
                if imdata(1,end)>0;
                    imdata(:,2:3)=imdata(:,2:3)*imdata(1,end);
                else
                    imdata(:,2:3)=imdata(:,2:3)/abs(imdata(1,end));
                end
                imdata=imdata(:,1:3);
            end
            selection = questdlg('The file is for calculating ','Request confirm','SCS','OBS','Cancel','SCS');
            switch selection
                case 'SCS'
                    offset=cosd(fun_azimuth(origin,imdata(:,2:3))-strike).*sqrt((imdata(:,2)-origin(1)).^2+(imdata(:,3)-origin(2)).^2);
                    SCS(1).offsettable=[imdata(:,1) offset/1000]; % unit: km and assume vetical incident
                    SCS(1).tablefile='Calculated by "Maintain" tool.';
                    msgbox('Calculation done!');
                case 'OBS'
                    for i=1:length(OBS);
                        xy=OBS(i).XYZ([1 2])/OBS(i).XYZ(4);
                        if size(xy,2)<2;
                            xy=xy';
                        end
                        offset=sqrt((imdata(:,2)-xy(1)).^2+(imdata(:,3)-xy(2)).^2)/1000;  % unit: km
                        offset=OBS(i).moffset+offset.*sign(cosd(fun_azimuth(xy,imdata(:,2:3))-strike));
                        OBS(i).offsettable=[imdata(:,1) offset];
                        OBS(i).tablefile='Calculated by "Maintain" tool.';
                    end
                    msgbox('Calculation done!');
                case 'Cancel'
            end
        end
    end

end % function