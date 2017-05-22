function tool_copy
%  disp ('5.copy and run');

% initial file path and names 
[pathname,filename,fullname]=deal(cell(7,1));
currentfolder='current';
sourcefolder='';
namelist={'v','r','tx','d','vm','s','f'};
if exist('current','dir')==7
else
    system('mkdir current')
end

% load last run information 
if exist('history_copy.mat','file');
    s=load ('history_copy.mat');
    filename=s.filename;
    pathname=s.pathname;
    fullname=s.fullname;
    for i=length(fullname)+1:length(namelist);
        fullname{i}='';
    end
    sourcefolder=s.sourcefolder;
end
% for i=1:length(namelist)
%     if isempty(fullname{i})
%         if ~isempty(pathname{i})
%             fullname{i}=[pathname{i},filename{i}];
%         end
%     end
% end

%  Construct the components
if ishandle(5);
    copyh = 5;
    set(copyh,'Visible','on');
else
    copyh=figure(5);
    set(copyh,'Visible','off','Name','Copy .in files to "Current" folder','MenuBar','none',...
        'NumberTitle','on','Position',[100,100,1020,455]);
     
    clear1 = uicontrol(copyh,'Style','pushbutton','String','Clear',...
        'Tag','1','Position',[5 270 40 30],'Callback',@clear_callback);
    clear2 = uicontrol(copyh,'Style','pushbutton','String','Clear',...
        'Tag','2','Position',[5 230 40 30],'Callback',@clear_callback);
    clear3 = uicontrol(copyh,'Style','pushbutton','String','Clear',...
        'Tag','3','Position',[5 190 40 30],'Callback',@clear_callback);
    clear4 = uicontrol(copyh,'Style','pushbutton','String','Clear',...
        'Tag','4','Position',[5 150 40 30],'Callback',@clear_callback);
    clear5 = uicontrol(copyh,'Style','pushbutton','String','Clear',...
        'Tag','5','Position',[5 110 40 30],'Callback',@clear_callback);
    clear6 = uicontrol(copyh,'Style','pushbutton','String','Clear',...
        'Tag','6','Position',[5 70 40 30],'Callback',@clear_callback);
    clear7 = uicontrol(copyh,'Style','pushbutton','String','Clear',...
        'Tag','7','Position',[5 30 40 30],'Callback',@clear_callback);
    
    text_1 = uicontrol(copyh,'Style','text','String','v.in','FontWeight','bold','FontSize',12,...
        'BackgroundColor','yellow','ForegroundColor','red','Position',[50 275 45 20]);
    text_2 = uicontrol(copyh,'Style','text','String','r.in','FontWeight','bold','FontSize',12,...
        'BackgroundColor','yellow','ForegroundColor','red','Position',[50 235 45 20]);
    text_3 = uicontrol(copyh,'Style','text','String','tx.in','FontWeight','bold','FontSize',12,...
        'BackgroundColor','yellow','ForegroundColor','red','Position',[50 195 45 20]);
    text_4 = uicontrol(copyh,'Style','text','String','d.in','FontWeight','bold','FontSize',12,...
        'BackgroundColor','yellow','ForegroundColor','red','Position',[50 155 45 20]);
    text_5 = uicontrol(copyh,'Style','text','String','vm.in','FontWeight','bold','FontSize',12,...
        'BackgroundColor','yellow','ForegroundColor','red','Position',[50 115 45 20]);
    text_6 = uicontrol(copyh,'Style','text','String','s.in','FontWeight','bold','FontSize',12,...
        'BackgroundColor','yellow','ForegroundColor','red','Position',[50 75 45 20]);
    text_7 = uicontrol(copyh,'Style','text','String','f.in','FontWeight','bold','FontSize',12,...
        'BackgroundColor','yellow','ForegroundColor','red','Position',[50 35 45 20]);
    
    check{1} = uicontrol(copyh,'Style','checkbox','Position',[100 275 15 20]);
    check{2} = uicontrol(copyh,'Style','checkbox','Position',[100 235 15 20]);
    check{3} = uicontrol(copyh,'Style','checkbox','Position',[100 195 15 20]);
    check{4} = uicontrol(copyh,'Style','checkbox','Position',[100 155 15 20]);
    check{5} = uicontrol(copyh,'Style','checkbox','Position',[100 115 15 20]);
    check{6} = uicontrol(copyh,'Style','checkbox','Position',[100 75 15 20]);
    check{7} = uicontrol(copyh,'Style','checkbox','Position',[100 35 15 20]);
    
    edit1 = uicontrol(copyh,'Style','edit','String',fullname{1},'Position',[120 270 800 30]);
    edit2 = uicontrol(copyh,'Style','edit','String',fullname{2},'Position',[120 230 800 30]);
    edit3 = uicontrol(copyh,'Style','edit','String',fullname{3},'Position',[120 190 800 30]);
    edit4 = uicontrol(copyh,'Style','edit','String',fullname{4},'Position',[120 150 800 30]);
    edit5 = uicontrol(copyh,'Style','edit','String',fullname{5},'Position',[120 110 800 30]);
    edit6 = uicontrol(copyh,'Style','edit','String',fullname{6},'Position',[120 70 800 30]);
    edit7 = uicontrol(copyh,'Style','edit','String',fullname{7},'Position',[120 30 800 30]);
    
    select1 = uicontrol(copyh,'Style','pushbutton','String','Select file ...',...
        'Tag','1','Position',[930 270 80 30],'Callback',@select_callback);
    select2 = uicontrol(copyh,'Style','pushbutton','String','Select file ...',...
        'Tag','2','Position',[930 230 80 30],'Callback',@select_callback);
    select3 = uicontrol(copyh,'Style','pushbutton','String','Select file ...',...
        'Tag','3','Position',[930 190 80 30],'Callback',@select_callback);
    select4 = uicontrol(copyh,'Style','pushbutton','String','Select file ...',...
        'Tag','4','Position',[930 150 80 30],'Callback',@select_callback);
    select5 = uicontrol(copyh,'Style','pushbutton','String','Select file ...',...
        'Tag','5','Position',[930 110 80 30],'Callback',@select_callback);
    select6 = uicontrol(copyh,'Style','pushbutton','String','Select file ...',...
        'Tag','6','Position',[930 70 80 30],'Callback',@select_callback);
    select7 = uicontrol(copyh,'Style','pushbutton','String','Select file ...',...
        'Tag','7','Position',[930 30 80 30],'Callback',@select_callback);
    
    next = uicontrol(copyh,'Style','pushbutton','String','or, CHECK  the files specified below, then click this button','FontWeight','bold','FontSize',12,...
        'Position',[270 320 500 50],'Callback',@next_callback);
    oneclick = uicontrol(copyh,'Style','pushbutton','String','One click to copy all .in files from one folder to "current" folder','FontWeight','bold','FontSize',12,...
        'Position',[270 390 500 50],'Callback',@oneclick_callback);
    
    set(copyh,'CloseRequestFcn',@pbh2_callback)
    % make the window visable
    set(copyh,'Visible','on');
end

%----- Callback Functions ------%
    function pbh2_callback(hObject, eventdata)
        selection = questdlg('Do you want to exit ?',...
            'Close Request Function',...
            'Yes','No','Yes');
        switch selection,
            case 'Yes',
                delete(copyh)
            case 'No'
        end
    end
    function clear_callback(hObject,eventdata)
        editname=['edit',get(hObject,'tag')];
        eval(['set (',editname,',''String'',[])']);  % run Matlab statement: set (edit1,'string',[])
        fullname{str2num(get(hObject,'tag'))}='';
    end

    function select_callback(hObject,eventdata)
        editname=['edit',get(hObject,'tag')];
        i=str2num(get(hObject,'tag'));
        textname=eval(['get (text_',num2str(i),',''String'')']);
        [ff, pp] = uigetfile('*.in', ['Pick the ',textname,' file'],[pathname{i},textname]);
        if ff~=0;
            filename{i}=ff; pathname{i}=pp;
            fullname{i}=[pathname{i},filename{i}];
            eval(['set (',editname,',''String'',''',fullname{i},''')']);  % run Matlab statement: set (edit1,'string','...')
            for j=i+1:length(namelist);
                if isempty(fullname{j})
                    pathname{j}=pathname{i};
                end
            end
        end
    end

    function oneclick_callback(hObject,eventdata)
        sourcefolder=uigetdir(sourcefolder,'Select the source folder');
        if sourcefolder==0;
            errordlg('User didn''t Select a folder! No action will made.');
            sourcefolder=s.sourcefolder;
        else
            if ispc
                [s1,r1]=system(['dir ',currentfolder,'\*.in']);
                command_copy='copy ';
            end
            if isunix
                [s1,r1]=system(['ls ',currentfolder,'/*.in']);
                command_copy='cp -f -p ';
            end
            if s1==0;
                qstring(1)={['\bf\fontsize{12}\color{blue}','The current files will be overlapped. Do you want to make a copy?']};
                qoptions.Interpreter = 'tex';
                qoptions.Default = 'Yes';
                choice= questdlg(qstring,'-*-*-*-   Backup request   -*-*-*-','Yes','No',qoptions);
                switch choice
                    case 'Yes'
                        hh=tool_backup('move');
                        uiwait(hh);
                    case 'No'
                        % no action need
                end
            end
            [status,result]=system ([command_copy,sourcefolder,filesep,'*.in ',currentfolder,filesep]);
            % save information for later use
            save history_copy.mat
            % show result and continue
            if status==0 && isempty(result); % for Linux
                qstring(1)={['\bf\fontsize{12}\color{blue}','Files are sucessfully copied.']};
            else
                qstring(1)={['\fontsize{10}\color{blue}',strrep(strrep(result,'\','\\'),'_','\_')]};
            end
            qoptions.Interpreter = 'tex';
            qoptions.Default = 'No';
            choice= questdlg(qstring,'-*-*-*-   Copy results   -*-*-*-','Continue to run rayinvr','No',qoptions);
            switch choice
                case 'Continue to run rayinvr'
                    tool_current
                case 'No'
        end
        end
    end

    function next_callback(hObject,eventdata)
        % update fullname based on edit strings
        n=0;
        for i=1:length(namelist);
            fullname{i}=eval(['get (edit',num2str(i),',''String'')']);
            if (~isempty(fullname{i}))&&(get(check{i},'value')==get(check{i},'max'))
                n=n+1;
                if n==1;
                    if ispc
                        [s1,r1]=system(['dir ',currentfolder,'\*.in']);
                        command_copy='copy ';
                    end
                    if isunix
                        [s1,r1]=system(['ls ',currentfolder,'/*.in']);
                        command_copy='cp -f -p ';
                    end
                    if s1==0;
                        qstring(1)={['\bf\fontsize{12}\color{blue}','The current files will be overlapped. Do you want to make a copy?']};
                        qoptions.Interpreter = 'tex';
                        qoptions.Default = 'Yes';
                        choice= questdlg(qstring,'-*-*-*-   Backup request   -*-*-*-','Yes','No',qoptions);
                        switch choice
                            case 'Yes'
                                hh=tool_backup('move');
                                uiwait(hh);
                            case 'No'
                                % no action need
                        end
                    end
                end
                [status(i),result{i}]=system ([command_copy,fullname{i},' ',currentfolder,filesep,namelist{i},'.in']);
            end
        end
        
        % save information for later use
        save history_copy.mat
        % show result and continue
%         n=0;
%         for i=1:length(status);
%             if status(i)==0
%                 if isempty(result{i})
%                 else
%                     n=n+1;
%                 end
%             end
%         end
        qstring(1)={['\bf\fontsize{12}\color{blue}Total ',num2str(n),' files are successfully copied.']};
        qstring(2)={''};
        if sum(status)>0;
            qstring(3)={['\bf\fontsize{12}\color{red}',num2str(sum(status)),' files failed copying.']};
            qstring(4)={''};
        end
        qoptions.Interpreter = 'tex';
        qoptions.Default = 'No';
        choice= questdlg(qstring,'-*-*-*-   Copy results   -*-*-*-','Continue to run rayinvr','No',qoptions);
        switch choice
            case 'Continue to run rayinvr'
                tool_current
            case 'No'
        end
    end


end % END function tool_copy