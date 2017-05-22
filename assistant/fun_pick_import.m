function [newOBS,newSCS,newphaseIDused,newphasecollection,newtimegroup]=fun_pick_import(pickfile,OBS,SCS,phaseIDused,phasecollection,timegroup)

% pickfile='e:\Researches\CanadaWorks\work1\PGC2010_005\Rayinvr_tao_work\Parallel_Margin\Kingdom picks\line4A_all_picks.dat';
% pickfile='e:\Researches\CanadaWorks\work1\PGC2010_005\Rayinvr_tao_work\Parallel_Margin\Kingdom picks\OBS33a_P1-P8_S1-S10.dat';

[newOBS,newSCS,newphaseIDused,newphasecollection,newtimegroup]=deal(OBS,SCS,phaseIDused,phasecollection,timegroup);
obsend=length(OBS);
popstring=[{'Choose a survey...'} fun_make_popup_strings(OBS,'OBS') fun_make_popup_strings(SCS,'SCS')];
phase={};
phasename={};
phasecount=0;
remarks={};
phasesource={};

% read file part
fid=fopen(pickfile);
tline = fgetl(fid);
while ischar(tline)
    if strfind(tline,'PROFILE');
        phasecount=phasecount+1;
        value=NaN(1,7);
        count=1;
        tline=fgetl(fid);
        tline=fgetl(fid);
    end
    value(count,:)=sscanf(tline,'%f %f %f %f %f %f %f', [1, inf]);
    %     value(count,:)=temp;
    survey=sscanf(tline,'%*s %*s %*s %*s %*s %*s %*s %s');
    tline = fgetl(fid);
    if strfind(tline,'EOD');
        phasename{phasecount}=sscanf(tline,'%*s %s');
        temp=NaN(size(value,1),12);
        temp(:,10:11)=value(:,5:6);
        phase{phasecount}=temp;
        tline = fgetl(fid);
    end
    count=count+1;
end
fclose(fid);

% UT part
if ishandle(315);
    pih = 315;
    set(pih,'Visible','on');
else
    pih = figure(315);
    set(pih,'Visible','off','Name','Import phase picks','MenuBar','none','NumberTitle','off','Position',[50,10,1200,700]);
    %---------- right control panel: from bottom to up
    rightph=uipanel(pih,'Visible','on','Position',[.85 .0 .15 1],'FontSize',12);
    %--- save, cancel, OBS/SCS panel
    rph1=uipanel(rightph,'Visible','on','Title','Import to','TitlePosition','centertop','FontWeight','bold','Position',[.0 .00 1 0.2],'FontSize',12);
    pop1=uicontrol(rph1,'Style','popup','String',popstring,'FontWeight','bold','FontSize',10,'Units','normalized','Position',[.05 .55 0.9 .35],'Callback','');
    uicontrol(rph1,'Style','pushbutton','String','Save & Exit','Tag','save','HorizontalAlignment','center','FontWeight','bold','FontSize',14,...
        'Callback',@save_callback,'Units','normalized','Position',[.05 .15 .9 .35],'ForegroundColor','red');
%     uicontrol(rph1,'Style','pushbutton','String','Cancel','Tag','Cancel','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
%         'Callback',@save_callback,'Units','normalized','Position',[.05 .05 .9 .25],'ForegroundColor','blue');
    %--- selection panel
    rph3=uipanel(rightph,'Visible','on','Title','Selection','TitlePosition','centertop','FontWeight','bold','Position',[.0 .2 1 0.8],'FontSize',12);
    uicontrol(rph3,'Style','text','String','Phase list','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.05 .96 0.9 .03],'FontWeight','bold','BackgroundColor','y');
    phaselist=uicontrol(rph3,'Style','listbox','String',phasename,'HorizontalAlignment','center','FontSize',10,'Units','normalized',...
        'Position',[.05 .1 0.9 .86],'FontWeight','bold','Callback',@preview_callback);
    uicontrol(rph3,'Style','pushbutton','String','Preview','Tag','preview','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@preview_callback,'Units','normalized','Position',[.05 .02 .9 .06],'ForegroundColor','blue');
    %---------- left panels: from top to bottom
    %----- phase list table
    left2=uipanel(pih,'Visible','on','Title','Phase Information','TitlePosition','centertop','FontWeight','bold','Position',[.0 .4 .85 0.6],'FontSize',12);
    selectioncolname={'Phase','Name','Ray','Wave','Pick uncertainty (ms)','Time correct (ms)','Remarks'};
    columnformat={'numeric', 'char', {'(1)Refraction','(2)Reflection','(3)Head wave'}, {'(1)P-wave','(2)S-wave'},'numeric', 'numeric','char'};
    columnwidth={50 130 100 80 'auto' 'auto' 470 };
    columneditable=[false false true true true true true];
    table1data=cell(length(phase),7);
    for i=1:length(phase);
        if strfind(lower(phasename{i}),'_s');
            wave='(2)S-wave';
        else
            wave='(1)P-wave';
        end
        table1data(i,:)={i, phasename{i}, '(2)Reflection', wave, [], [],['HORIZON: ',phasename{i},'; SURVEY: ',survey]};
    end
    table1=uitable(left2,'Tag','table1','Units','normalized','Position',[.0 .0 1 1],'ColumnName',selectioncolname,'ColumnFormat',columnformat,...
        'ColumnWidth',columnwidth,'ColumnEditable',columneditable,'FontSize',8,'Data',table1data,'CellEditCallback',@preview_callback);
    %----- selected phase table
    left3=uipanel(pih,'Visible','on','Title','','TitlePosition','centertop','FontWeight','bold','Position',[.0 .0 .85 0.4],'FontSize',12);
    tbtitle=uicontrol(left3,'Style','text','String',phasename{1},'HorizontalAlignment','center','FontSize',10,'Units','normalized',...
        'Position',[.0 .95 1 .05],'FontWeight','bold','BackgroundColor','y','ForegroundColor','blue');
    phasecolname={'Receiver (km)','Travel time (s)','Uncertainty','Group','Orig. group','Direction','Model layer','Ray type','Wave type',...
        'Shot number','Orig. pick','Time correct'};
    table2=uitable(left3,'Units','normalized','Position',[.0 .0 1 0.95],'ColumnName',phasecolname);
    
    set(pih,'Visible','on');
    set(pih,'CloseRequestFcn',@my_closerequest)
end
uiwait(pih);

%----- Callback Functions ------%
    function my_closerequest(hObject, eventdata)
        selection = questdlg('Leave without save?',...
            'Close Request Function',...
            'Yes','No','No');
        switch selection,
            case 'Yes'
                delete(pih);
            case 'No'
        end
    end

    function preview_callback(src,event)
        if strcmpi(get(src,'Tag'),'table1');
            set(phaselist,'Value',event.Indices(1));
        end
        phasenumber=get(phaselist,'Value');
        table2data=phase{phasenumber};
        table1data=get(table1,'Data');
        current=table1data(phasenumber,:);
        switch current{3}; % ray type
            case '(1)Refraction'
                table2data(:,8)=1;
            case '(2)Reflection'
                table2data(:,8)=2;
            case '(3)Head wave'
                table2data(:,8)=3;
        end
        switch current{4}; % wave type
            case '(1)P-wave'
                table2data(:,9)=1;
            case '(2)S-wave'
                table2data(:,9)=2;
        end
        if ~isempty(current{5}); % uncertainty
            if current{5}>=1;
                table2data(:,3)=current{5}/1000;
            else
                table2data(:,3)=current{5};
            end
        end
        if ~isempty(current{6}); % Time correct
            if current{6}>=1;
                table2data(:,12)=current{6}/1000;
            else
                table2data(:,12)=current{6};
            end
        end
        set(table2,'Data',table2data);
        set(tbtitle,'String',phasename{phasenumber});
    end

    function save_callback(src,event)
        index=get(pop1,'Value');
        if index==1;
            msgh=msgbox('Please choose a survey to import the picks!');
            uiwait(msgh);
        else
            newphase=length(phase);
            newID=phaseIDused+(1:newphase);
            phasecollection=[phasecollection; newID'];
            phaseIDused=phaseIDused+newphase;
            newtimegroup=length(timegroup)+(1:newphase);
            timegroup(newtimegroup)=num2cell(newID);
            table1data=get(table1,'Data');
            for i=1:newphase;
                current=table1data(i,:);
                remarks(i)=current(end);
                phasesource{i}=pickfile;
                switch current{3}; % ray type
                    case '(1)Refraction'
                        phase{i}(:,8)=1;
                    case '(2)Reflection'
                        phase{i}(:,8)=2;
                    case '(3)Head wave'
                        phase{i}(:,8)=3;
                end
                switch current{4}; % wave type
                    case '(1)P-wave'
                        phase{i}(:,9)=1;
                    case '(2)S-wave'
                        phase{i}(:,9)=2;
                end
                if ~isempty(current{5}); % uncertainty
                    if current{5}>=1;
                        phase{i}(:,3)=current{5}/1000;
                    else
                        phase{i}(:,3)=current{5};
                    end
                end
                if ~isempty(current{6}); % Time correct
                    if current{6}>=1;
                        phase{i}(:,12)=current{6}/1000;
                    else
                        phase{i}(:,12)=current{6};
                    end
                end
                phase{i}(:,4)=newtimegroup(i);
                phase{i}(:,5)=newtimegroup(i);
            end
            if index-1>obsend; % SCS
                SCS.phase=[SCS.phase phase];
                SCS.phaseID=[SCS.phaseID [newID;newtimegroup]];
                SCS.phasefile=[SCS.phasefile phasesource];
                SCS.remarks=[SCS.remarks remarks];
            else   % OBS
                obsnumber=index-1;
                OBS(obsnumber).phase=[OBS(obsnumber).phase phase];
                OBS(obsnumber).phaseID=[OBS(obsnumber).phaseID [newID;newtimegroup]];
                OBS(obsnumber).phasefile=[OBS(obsnumber).phasefile phasesource];
                OBS(obsnumber).remarks=[OBS(obsnumber).remarks remarks];
            end
            selection = questdlg(['You select to import horizon picks into ',popstring{index}],...
                'Confirm Request','Confirm','Cancel','Cancel');
            switch selection,
                case 'Confirm'
                    [newOBS,newSCS,newphaseIDused,newphasecollection,newtimegroup]=deal(OBS,SCS,phaseIDused,phasecollection,timegroup);
                    delete(pih);
                case 'Cancel'
            end
        end
    end

end