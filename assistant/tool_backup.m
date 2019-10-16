function backuph=tool_backup(varargin)
%  disp ('6.backup "current" folder');

if isempty(varargin);  % varargin: Variable length input argument list
    mode='copy';  % no input
else
    mode=varargin{1};  % have input
end
currentfolder='current';
backupfolder='backup';
if ispc
    command_copy='copy ';
    command_move='move ';
end
if isunix
    command_copy='cp ';
    command_move='mv ';
end
ss=dir(currentfolder);
switch length(ss);  % 0: folder doesn't exist; 2: empty folder
    case 0
        msgbox('The "current" folder does not exist !   Program stopped.');
        return;
    case 2
        msgbox('The "current" folder is empty !   Program stopped.');
        return;
end
  
% systime=num2str([num2str(year(now)),sprintf('_%02d',month(now),day(now),hour(now),minute(now),round(second(now)))]);
systime=round(clock);
systime=[num2str(systime(1)),sprintf('_%02d',systime(2:end))];
shortwords='backup';
finalname='';

% load last run information 
if exist('history_backup.mat','file');
    s=load ('history_backup.mat');
    shortwords=s.shortwords;
    finalname=s.finalname;
end

%  Construct the components from bottom to top
if ishandle(6);
    backuph = 6;
    set(backuph,'Visible','on');
else
    backuph=figure(6);
    set(backuph,'Visible','off','Name','Make a backup of "Current" folder','MenuBar','none',...
        'NumberTitle','on','Position',[300,200,700,365]);
    
    pbh1 = uicontrol(backuph,'Style','pushbutton','String','Do it !','FontWeight','bold','FontSize',12,...
        'Position',[150 20 160 40],'Callback',@pbh1_callback);
    pbh2 = uicontrol(backuph,'Style','pushbutton','String','No, bye.','FontWeight','bold','FontSize',12,...
       'Position',[390 20 160 40],'Callback',@pbh2_callback);
    
    preview = uicontrol(backuph,'Style','text','String',['Folder name preview :  ',systime],'FontWeight','bold','FontSize',12,...
        'ForegroundColor','blue','Position',[50 70 600 20]);
    
    bgh = uibuttongroup('Parent',backuph,'visible','off','Title','Select a format','FontWeight','bold','FontSize',12,...
         'Position',[.1 .28 .8 .35],'SelectionChangeFcn',@bgh_SelectionChangeFcn);
    rbh1 = uicontrol(bgh,'Style','radiobutton','String','System time only','FontWeight','bold','FontSize',12,...
        'Tag','1','Units','normalized',...
        'Position',[.1 .75 .8 .2]);
    rbh2 = uicontrol(bgh,'Style','radiobutton','String','System time + words','FontWeight','bold','FontSize',12,...
        'Tag','2','Units','normalized',...
        'Position',[.1 .45 .8 .2]);
    rbh3 = uicontrol(bgh,'Style','radiobutton','String','Words + system time','FontWeight','bold','FontSize',12,...
        'Tag','3','Units','normalized',...
        'Position',[.1 .15 .8 .2]);
    
    edit_tag = uicontrol(backuph,'Style','text','String','Simple explanation words (optional):','FontWeight','bold','FontSize',12,...
        'ForegroundColor','blue','Position',[50 250 300 20]);
    edit = uicontrol(backuph,'Style','edit','String',shortwords,'FontWeight','bold','FontSize',12,'Position',[350 249 250 22]);
    
    line1='This program will backup the "current" folder into "backup" folder,';
    line2='with the folder name of system time, or optionally plus simple explanation words.';
    line3='Choose one of following folder name formant, then click "Do it" button.';
    text = uicontrol(backuph,'Style','text','String',[line1,char(13,10)',line2,char(13,10)',line3],'FontWeight','bold','FontSize',12,...
        'BackgroundColor','yellow','ForegroundColor','red','Position',[25 290 650 60]);
    
    set(backuph,'CloseRequestFcn',@pbh2_callback)
    % make the window visable
    set(bgh,'Visible','on');
    set(backuph,'Visible','on');
end

%----- Callback Functions ------%
    function bgh_SelectionChangeFcn(hObject,eventdata)
        shortwords=strtrim(get(edit,'string'));
        switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
            case '1'
                finalname=systime;
            case '2'
                finalname=[systime,'_',strrep(shortwords,' ','_')];
            case '3'
                finalname=[strrep(shortwords,' ','_'),'_',systime];
        end
        set(preview,'string',['Folder name preview :  ',finalname]);
    end

    function pbh1_callback(hObject, eventdata)
        if exist(backupfolder)~=7;
            mkdir(backupfolder);
        end
        finalname=strrep(get(preview,'string'),'Folder name preview :  ','');
        finalpath=fullfile(backupfolder,finalname);
        mkdir(finalpath);
        switch mode
            case 'copy'
                [status,result]=system([command_copy,currentfolder,filesep,'*.* ',finalpath,filesep]);
            case 'move'
                [status,result]=system([command_move,currentfolder,filesep,'*.* ',finalpath,filesep]);
        end
        % save information for later use
        selected=get(bgh,'SelectedObject');
        save history_backup.mat
        % show result and continue
        if status==0 && isempty(result); % for Linux
            result='Backup job is sucessfully finished.';
        end
        hh=msgbox(result);
        uiwait(hh);
        close(backuph);
    end

    function pbh2_callback(hObject, eventdata)
        selection = questdlg('Do you want to exit ?',...
            'Close Request Function',...
            'Yes','No','Yes');
        switch selection,
            case 'Yes',
                delete(backuph)
            case 'No'
        end
    end

end