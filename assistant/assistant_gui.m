function mfh = assistant_gui(varargin)
% RayinvrAssitant Brief description of GUI.
%       Comments displayed at the command line in response
%       to the help command.

% (Leave a blank line following the help.)

%  Initialization
% make the assistant_gui the graphic handler 1 and make sure no repeat components produeced
if ishandle(100);
    mfh = 100;
    set(mfh,'Visible','on');
else
    mfh = figure(100);
    set(mfh,'Visible','off','Name','Rayinvr Assitant','MenuBar','none',...
        'NumberTitle','off','Position',[350,300,450,285]);

    %  Construct the components
    % 1. Task selection radio buttons
    bgh = uibuttongroup('Parent',mfh,'visible','off','Title','1. Select a task',...
        'Position',[.05 .25 .9 .7],'SelectionChangeFcn',@bgh_SelectionChangeFcn);
    rbh1 = uicontrol(bgh,'Style','radiobutton','String','v.in editor',...
        'Tag','1','Units','normalized',...
        'Position',[.1 .85 .8 .1]);
    rbh2 = uicontrol(bgh,'Style','radiobutton','String','r.in editor',...
        'Tag','2','Units','normalized',...
        'Position',[.1 .75 .8 .1]);
    rbh3 = uicontrol(bgh,'Style','radiobutton','String','tx manager',...
        'Tag','3','Units','normalized',...
        'Position',[.1 .65 .8 .1]);
    rbh4 = uicontrol(bgh,'Style','radiobutton','String','Run rayinvr model in "current" folder',...
        'Tag','4','Units','normalized',...
        'Position',[.1 .55 .8 .1]);
    rbh5 = uicontrol(bgh,'Style','radiobutton','String','Copy rayinvr model to "current" folder and Run',...
        'Tag','5','Units','normalized',...
        'Position',[.1 .45 .8 .1]);
    rbh6 = uicontrol(bgh,'Style','radiobutton','String','Make a backup of "current" folder',...
        'Tag','6','Units','normalized',...
        'Position',[.1 .35 .8 .1]);
    % Initialize some button group properties.
    set(bgh,'SelectedObject',[]);  % No selection
    set(bgh,'Visible','on');
    % 2. Push buttons
    pbh1 = uicontrol(mfh,'Style','pushbutton','String','2. Run selected task',...
        'Position',[50 20 160 40],'Callback',@pbh1_callback);
    pbh2 = uicontrol(mfh,'Style','pushbutton','String','Exit Rayinvr Assistant',...
        'Position',[240 20 160 40],'Callback',@pbh2_callback);

    set(mfh,'CloseRequestFcn',@pbh2_callback);
    % make the window visable
    set(mfh,'Visible','on');
end

task=0;

%----- Callback Functions ------%
    function bgh_SelectionChangeFcn(hObject,eventdata)
        switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
            case '1'
                task=1;
            case '2'
                task=2;
            case '3'
                task=3;
            case '4'
                task=4;
            case '5'
                task=5;
            case '6'
                task=6;
            otherwise
                task=0;
        end
    end

    function pbh1_callback(hObject, eventdata)
        switch task
            case 1
                tool_v_in_editor
            case 2
                tool_r_in_editor
            case 3
                tool_tx_manager
            case 4
                tool_current
            case 5
                tool_copy
            case 6
                tool_backup
        end
    end

    function pbh2_callback(hObject, eventdata)
        selection = questdlg('Do you want to exit ?',...
            'Close Request Function',...
            'Yes','No','Yes');
        switch selection,
            case 'Yes',
                delete(mfh)
            case 'No'
        end
    end

end % end the assistant_gui function
