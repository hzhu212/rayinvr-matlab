function [newOBS,newSCS,newphasegroup]=fun_txin_maker(OBS,SCS,phasegroup,timegroup)

%--- phase group
% "phasegroup" is a 1xn structure array, used to store phases selected to plot travel time and output tx.in file
% name: user defined name for each group
% OBS: a 6-by-phase number matrix, the rows are (1) phase ID, (2) time group, (3) OBS#, (4) OBS#.moffset, (5) phase number in OBS#, (6) direction: left -1, right 1, both 2
% SCS: a 5-by-phase number matrix, the rows are (1) phase ID, (2) time group, (3) SCS#, (4) shot_rec offset, (5) phase number in SCS#
% phasegroup=struct('name',{},'OBS',{},'SCS',{});
if isempty(phasegroup);
    phasegroup=struct('name','new','OBS',{},'SCS',{});
end
[newOBS,newSCS,newphasegroup]=deal(OBS,SCS,phasegroup);

obsend=length(OBS);
depthnodes=NaN(2,obsend);
totalphase=NaN(1,6); % n-by-6 , columns are (1) phaseID; (2) time group; (3) survey; (4) phase; (5) ray; (6) wave
timegrouptype=NaN(1,2); % n-by-2, columns are (1) time group ID (2) tyep of 1: P refraction/head wave; 2: P reflection; 3: S reflection
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
count=0;
for i=1:length(timegroup)
    if ~isempty(timegroup{i})
        count=count+1;
        type=totalphase(timegroup{i}(1)==totalphase(:,1),5:6);
        if type(1)==2 && type(2)==1;
            timegrouptype(count,:)=[i 2];
        elseif type(1)==2 && type(2)==2;
            timegrouptype(count,:)=[i 3];
        else
            timegrouptype(count,:)=[i 1];
        end
    end
end
% define the colors for itcol & ircol
itcol_ircol=[1:6 10:16 20:26 30:36 40:46 50:56];

templatenames=fun_update_templatenames(1);
previewtypelist=fun_sort_ray_and_wave(phasegroup(1)); % 1-by-3 cell for timegroups of type 1, 2 and 3
previewtabledata=fun_form_table_preview(phasegroup(1));

tgintemplate={'2'}; % time group in template
notintemplate={'3'}; % time group not in template

radio_status=[false false true]; % panel switch

[xmin,xmax,ymin,ymax, lockedtemplateID,lockedtemplateTable, txfilepath,txfilename]=deal([]);
vreduce=0;
colorcount=0;



%---- UI
if ishandle(360);
    txh = 360;
    set(txh,'Visible','on');
else
    txh = figure(360);
    set(txh,'Visible','off','Name','Compose tx.in Tool','MenuBar','none','NumberTitle','off','Position',[100,15,1200,700]); 
    %----------- bottom: left and right stable panels & middel changable button panel
    radiogroup = uibuttongroup(txh,'visible','on','Title','','Position',[.0 .0 .18 0.12],'SelectionChangeFcn',@selectionChange_callback);
    rbh1 = uicontrol(radiogroup,'Style','radiobutton','String','Compare Templates','FontWeight','bold','FontSize',12,...
        'Tag','1','Units','normalized','Position',[.1 .7 0.9 0.3]);
    rbh2 = uicontrol(radiogroup,'Style','radiobutton','String','Compare & Modify','FontWeight','bold','FontSize',12,...
        'Tag','2','Units','normalized','Position',[.1 .35 0.9 0.3]);
    rbh3 = uicontrol(radiogroup,'Style','radiobutton','String','Template Preview','FontWeight','bold','FontSize',12,...
        'Tag','3','Units','normalized','Position',[.1 .0 0.9 0.3]);
    set(radiogroup,'SelectedObject',rbh3);
    %---- plot controls
    plotp=uipanel(txh,'Position',[.6 .0 0.4 0.12]);
    %--- x and t range 
    rph2=uipanel(plotp,'Visible','off','Title','','TitlePosition','centertop','FontWeight','bold','Position',[.0 .0 0.4 1],'FontSize',12);
    xedit2=uicontrol(rph2,'Style','edit','String','','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.72 .55 0.25 .35]);
    uicontrol(rph2,'Style','text','String','Xmax','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.47 .55 0.25 .35],'FontWeight','bold');
    xedit1=uicontrol(rph2,'Style','edit','String','','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.21 .55 0.25 .35]);
    uicontrol(rph2,'Style','text','String','Xmin','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.0 .55 0.2 .35],'FontWeight','bold'); 
    tedit2=uicontrol(rph2,'Style','edit','String','','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.72 .1 0.25 .35]);
    uicontrol(rph2,'Style','text','String','Tmax','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.47 .1 0.25 .35],'FontWeight','bold');
    tedit1=uicontrol(rph2,'Style','edit','String','','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.21 .1 0.25 .35]);
    uicontrol(rph2,'Style','text','String','Tmin','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.0 .1 0.2 .35],'FontWeight','bold'); 
    %---- velocity
    rph1=uipanel(plotp,'Visible','off','Title','','TitlePosition','centertop','FontWeight','bold','Position',[.4 .0 0.3 1],'FontSize',12);
    vedit3=uicontrol(rph1,'Style','edit','String','5','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.675 .55 0.3 .35]);
    vedit2=uicontrol(rph1,'Style','edit','String','0','Tag','vreduced','HorizontalAlignment','center','FontSize',10,'Units','normalized',...
        'Position',[.35 .55 0.3 .35],'Callback',@slider_callback);
    vedit1=uicontrol(rph1,'Style','edit','String','0','HorizontalAlignment','center','FontSize',10,'Units','normalized','Position',[.025 .55 0.3 .35]);
    sliderh=uicontrol(rph1,'Style','slider','String','','Tag','slider','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@slider_callback,'Units','normalized','Position',[.03 .1 .94 .3],'ForegroundColor','blue','Max',1,'Min',0,'Value',0);
    %--- depth and plot
    rph0=uipanel(plotp,'Visible','off','Title','','Position',[.7 .0 0.3 1],'FontSize',12);
    depthcheck=uicontrol(rph0,'Style','checkbox','String','Depth','Tag','usedepth','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@checkbox_callback,'Units','normalized','Position',[.0 .6 .5 .4],'ForegroundColor','blue');
    instantcheck=uicontrol(rph0,'Style','checkbox','String','Instant','Tag','instant','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@checkbox_callback,'Units','normalized','Position',[.5 .6 .5 .4],'ForegroundColor','blue');
    uicontrol(rph0,'Style','pushbutton','String','Plot/Update','Tag','updateplot','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@updateplot_callback,'Units','normalized','Position',[.1 .1 .8 .4],'ForegroundColor','blue');
    %------------------------- 1. compare part
    % bottom panel
    bottomp1=uipanel(txh,'Visible','off','Position',[.18 .0 0.42 0.2]);
    bottomp11=uipanel(bottomp1,'Visible','on','Title','Top Table','TitlePosition','centertop','Position',[.0 .00 0.25 1],'FontWeight','bold','FontSize',8);
    uicontrol(bottomp11,'Style','pushbutton','String','Check All','Tag','checkalltop','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.03 .7 .94 .3],'ForegroundColor','blue');
    uicontrol(bottomp11,'Style','pushbutton','String','Uncheck All','Tag','clearalltop','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.03 .35 .94 .3],'ForegroundColor','blue');
    uicontrol(bottomp11,'Style','pushbutton','String','Flip Checks','Tag','fliptop','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.03 .0 .94 .3],'ForegroundColor','blue');
    bottomp12=uipanel(bottomp1,'Visible','on','Title','Bottom Table','TitlePosition','centertop','Position',[.25 .00 0.25 1],'FontWeight','bold','FontSize',8);
    uicontrol(bottomp12,'Style','pushbutton','String','Check All','Tag','checkallbottom','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.03 .7 .94 .3],'ForegroundColor','blue');
    uicontrol(bottomp12,'Style','pushbutton','String','Uncheck All','Tag','clearallbottom','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.03 .35 .94 .3],'ForegroundColor','blue');
    uicontrol(bottomp12,'Style','pushbutton','String','Flip Checks','Tag','flipbottom','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.03 .0 .94 .3],'ForegroundColor','blue');
    bottomp13=uipanel(bottomp1,'Visible','on','Title','Plot Color','TitlePosition','centertop','Position',[.5 .00 0.2 1],'FontWeight','bold','FontSize',8);
    uicontrol(bottomp13,'Style','text','String','Top only','Units','normalized','Position',[.03 .7 .94 .3],'FontWeight','bold','FontSize',10,'BackgroundColor','red');
    uicontrol(bottomp13,'Style','text','String','Bottom only','Units','normalized','Position',[.03 .35 .94 .3],'FontWeight','bold','FontSize',10,'BackgroundColor','blue');
    uicontrol(bottomp13,'Style','text','String','Same phases','Units','normalized','Position',[.03 .0 .94 .3],'FontWeight','bold','FontSize',10,'BackgroundColor','green');
    bottomp14=uipanel(bottomp1,'Visible','on','Title','Checked Items','TitlePosition','centertop','Position',[.7 .00 0.3 1],'FontWeight','bold','FontSize',8);
    uicontrol(bottomp14,'Style','pushbutton','String','Add to preview','Tag','compareaddto','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@addto_callback,'Units','normalized','Position',[.03 .55 .94 .4],'ForegroundColor','blue');
    uicontrol(bottomp14,'Style','pushbutton','String','Remove from preview','Tag','compareremovefrom','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@removefrom_callback,'Units','normalized','Position',[.03 .05 .94 .4],'ForegroundColor','blue');
    % top pannel
    topp1=uipanel(txh,'Visible','off','Title','Compare Templates','TitlePosition','lefttop','FontWeight','bold','FontSize',12,'Position',[.0 .15 1 0.85],'ForegroundColor','red','BackgroundColor','g');
    topp11=uipanel(topp1,'Visible','on','Title','Only Template 1 have','TitlePosition','centertop','FontWeight','bold','FontSize',12,'Position',[.0 .5 1 0.5],'ForegroundColor','red','BackgroundColor','y');
    topp11right=uipanel(topp11,'Visible','on','Title','','TitlePosition','centertop','FontWeight','bold','FontSize',12,'Position',[.875 .0 0.125 1]);
    uicontrol(topp11right,'Style','text','String','Template Name','Units','normalized','Position',[.05 .95 .9 .05],'FontWeight','bold','FontSize',10,'ForegroundColor','red');
    comparepop1=uicontrol(topp11right,'Style','popup','String',templatenames,'Tag','comparepop1','Units','normalized','Position',[.05 .85 .9 .1],...
        'FontWeight','bold','FontSize',10,'Callback',@comparepop_callback);
    comparetb12=uitable(topp11right,'Units','normalized','Position',[.05 .0 .9 .85],'FontWeight','bold','FontSize',12,'ColumnName','Time Groups');
    selectioncolname={'Survey','Name','Phase','ID','Group','Layer','Ray','Wave','In preview','Remarks','Select'};
    columnformat={'char', 'char', 'numeric', 'numeric','numeric', 'numeric','numeric','numeric','logical','char','logical'};
    columneditable=[false false false false false false false false false true true];
    columnwidth={50 100 45 30 50 50 40 40 70 450 50};
    comparetb11=uitable(topp11,'Tag','comparetb11','Units','normalized','Position',[.0 .0 .875 1],'ColumnName',selectioncolname,'ColumnFormat',columnformat,...
            'ColumnWidth',columnwidth,'ColumnEditable',columneditable,'FontSize',8,'CellEditCallback',@changeline_callback);
    topp12=uipanel(topp1,'Visible','on','Title','Only Template 2 have','TitlePosition','centertop','FontWeight','bold','FontSize',12,'Position',[.0 .0 1 0.5],'ForegroundColor','blue','BackgroundColor','y');
    topp12right=uipanel(topp12,'Visible','on','Title','','TitlePosition','centertop','FontWeight','bold','FontSize',12,'Position',[.875 .0 0.125 1]);
    uicontrol(topp12right,'Style','text','String','Template Name','Units','normalized','Position',[.05 .95 .9 .05],'FontWeight','bold','FontSize',10,'ForegroundColor','blue');
    comparepop2=uicontrol(topp12right,'Style','popup','String',templatenames,'Tag','comparepop2','Units','normalized','Position',[.05 .85 .9 .1],...
        'FontWeight','bold','FontSize',10,'Callback',@comparepop_callback);
    comparetb22=uitable(topp12right,'Units','normalized','Position',[.05 .0 .9 .85],'FontWeight','bold','FontSize',12,'ColumnName','Time Groups');
    comparetb21=uitable(topp12,'Tag','comparetb21','Units','normalized','Position',[.0 .0 .875 1],'ColumnName',selectioncolname,'ColumnFormat',columnformat,...
            'ColumnWidth',columnwidth,'ColumnEditable',columneditable,'FontSize',8,'CellEditCallback',@changeline_callback);    
    %------------------------- 2. compose part
    % bottom panel
    bottomp2=uipanel(txh,'Visible','off','Position',[.18 .0 0.42 0.12]);
    bottomp21=uipanel(bottomp2,'Visible','on','Title','Top Table','TitlePosition','centertop','Position',[.0 .00 0.25 1],'FontWeight','bold','FontSize',8);
    uicontrol(bottomp21,'Style','pushbutton','String','Check All','Tag','checkalltop','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.03 .7 .94 .3],'ForegroundColor','blue');
    uicontrol(bottomp21,'Style','pushbutton','String','Uncheck All','Tag','clearalltop','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.03 .35 .94 .3],'ForegroundColor','blue');
    uicontrol(bottomp21,'Style','pushbutton','String','Flip Checks','Tag','fliptop','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.03 .0 .94 .3],'ForegroundColor','blue');
    bottomp22=uipanel(bottomp2,'Visible','on','Title','Bottom Table','TitlePosition','centertop','Position',[.25 .00 0.25 1],'FontWeight','bold','FontSize',8);
    uicontrol(bottomp22,'Style','pushbutton','String','Check All','Tag','checkallbottom','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.03 .7 .94 .3],'ForegroundColor','blue');
    uicontrol(bottomp22,'Style','pushbutton','String','Uncheck All','Tag','clearallbottom','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.03 .35 .94 .3],'ForegroundColor','blue');
    uicontrol(bottomp22,'Style','pushbutton','String','Flip Checks','Tag','flipbottom','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@setcheck_callback,'Units','normalized','Position',[.03 .0 .94 .3],'ForegroundColor','blue');
%     bottomp23=uipanel(bottomp2,'Visible','on','Title','Template','TitlePosition','centertop','Position',[.5 .00 0.2 1],'FontWeight','bold','FontSize',8);
%     uicontrol(bottomp23,'Style','pushbutton','String','Rename','Tag','rename','Units','normalized','Position',[.03 .55 .94 .4],...
%         'Callback',@name_callback,'FontWeight','bold','FontSize',10,'BackgroundColor','green');
%     uicontrol(bottomp23,'Style','pushbutton','String','Create New','Tag','createnew','Units','normalized','Position',[.03 .05 .94 .4],...
%         'Callback',@name_callback,'FontWeight','bold','FontSize',10,'BackgroundColor','green');
    bottomp23=uipanel(bottomp2,'Visible','on','Title','Plot Color','TitlePosition','centertop','Position',[.5 .00 0.2 1],'FontWeight','bold','FontSize',8);
    uicontrol(bottomp23,'Style','text','String','Top only','Units','normalized','Position',[.03 .7 .94 .3],'FontWeight','bold','FontSize',10,'BackgroundColor','red');
    uicontrol(bottomp23,'Style','text','String','Unasigned','Units','normalized','Position',[.03 .35 .94 .3],'FontWeight','bold','FontSize',10,'BackgroundColor','blue');
    uicontrol(bottomp23,'Style','text','String','In preview','Units','normalized','Position',[.03 .0 .94 .3],'FontWeight','bold','FontSize',10,'BackgroundColor','green');
    bottomp24=uipanel(bottomp2,'Visible','on','Title','Checked Items','TitlePosition','centertop','Position',[.7 .00 0.3 1],'FontWeight','bold','FontSize',8);
    addtobt=uicontrol(bottomp24,'Style','pushbutton','String','Add to preview','Tag','selectaddto','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@addto_callback,'Units','normalized','Position',[.03 .55 .94 .4],'ForegroundColor','blue');
    removefrombt=uicontrol(bottomp24,'Style','pushbutton','String','Remove from preview','Tag','selectemovefrom','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@removefrom_callback,'Units','normalized','Position',[.03 .05 .94 .4],'ForegroundColor','blue');
    % top pannel
    topp2=uipanel(txh,'Visible','off','Title','Compare & Modify','TitlePosition','centertop','FontWeight','bold','FontSize',12,'Position',[.0 .12 1 0.88],'ForegroundColor','red','BackgroundColor','g');
    topp21=uipanel(topp2,'Visible','on','Title','In This Template','TitlePosition','centertop','FontWeight','bold','FontSize',12,'Position',[.0 .5 1 0.5],'ForegroundColor','red','BackgroundColor','y');
    topp21right=uipanel(topp21,'Visible','on','Title','','TitlePosition','centertop','FontWeight','bold','FontSize',12,'Position',[.875 .0 0.125 1]);
    uicontrol(topp21right,'Style','text','String','Template Name','Units','normalized','Position',[.05 .94 .9 .06],'FontWeight','bold','FontSize',10,'ForegroundColor','red');
    selectpop=uicontrol(topp21right,'Style','popup','String',templatenames,'Tag','selectpop','Units','normalized','Position',[.05 .82 .9 .1],...
        'FontWeight','bold','FontSize',10,'Callback',@selectpop_callback);
    selectlist1=uicontrol(topp21right,'Style','listbox','Tag','selectlist1','String',tgintemplate,'Units','normalized','Position',[.05 .0 .9 .81],...
        'FontWeight','bold','FontSize',12,'Callback',@selectlist_callback,'Max',100);
    selecttb1=uitable(topp21,'Tag','selecttb1','Units','normalized','Position',[.0 .0 .875 1],'ColumnName',selectioncolname,'ColumnFormat',columnformat,...
            'ColumnWidth',columnwidth,'ColumnEditable',columneditable,'FontSize',8,'CellEditCallback',@changeline_callback);
    topp22=uipanel(topp2,'Visible','on','Title','Unassigned Phases','TitlePosition','centertop','FontWeight','bold','FontSize',12,'Position',[.0 .0 1 0.5],'ForegroundColor','blue','BackgroundColor','y');
    topp22right=uipanel(topp22,'Visible','on','Title','','TitlePosition','centertop','FontWeight','bold','FontSize',12,'Position',[.875 .0 0.125 1]);
    uicontrol(topp22right,'Style','text','String','Unassigned','Units','normalized','Position',[.05 .94 .9 .06],'FontWeight','bold','FontSize',10,'ForegroundColor','blue');
    selectlist2=uicontrol(topp22right,'Style','listbox','Tag','selectlist2','String',notintemplate,'Units','normalized','Position',[.05 .0 .9 .93],...
        'FontWeight','bold','FontSize',12,'Callback',@selectlist_callback,'Max',100);
    selecttb2=uitable(topp22,'Tag','selecttb2','Units','normalized','Position',[.0 .0 .875 1],'ColumnName',selectioncolname,'ColumnFormat',columnformat,...
            'ColumnWidth',columnwidth,'ColumnEditable',columneditable,'FontSize',8,'CellEditCallback',@changeline_callback); 
    %------------------------- 3. preview part
    % bottom panel
    bottomp3=uipanel(txh,'Visible','on','Position',[.18 .0 0.42 0.12]);
    tempremovebt=uicontrol(bottomp3,'Style','pushbutton','String','Temporarily Remove','Tag','remove','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@tempremove_callback,'Units','normalized','Position',[.01 .525 .35 .425],'ForegroundColor','blue');
    restorebt=uicontrol(bottomp3,'Style','pushbutton','String','Restore','Tag','restore','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@restore_callback,'Units','normalized','Position',[.01 .05 .35 .425],'ForegroundColor','blue');
    selectbt=uicontrol(bottomp3,'Style','pushbutton','String','Lock Template','Tag','select','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@select_callback,'Units','normalized','Position',[.375 .525 .3 .425],'ForegroundColor','blue');
    namebt=uicontrol(bottomp3,'Style','pushbutton','String','Rename / New /Delete','Tag','name','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@name_callback,'Units','normalized','Position',[.375 .05 .3 .425],'ForegroundColor','blue');
    savebt=uicontrol(bottomp3,'Style','pushbutton','String','Save Template','Tag','save','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@save_callback,'Units','normalized','Position',[.69 .525 .3 .425],'ForegroundColor','blue');
    writebt=uicontrol(bottomp3,'Style','pushbutton','String','Write tx.in','Tag','write','HorizontalAlignment','center','FontWeight','bold','FontSize',12,...
        'Callback',@writetxin_callback,'Units','normalized','Position',[.69 .05 .3 .425],'ForegroundColor','blue');
    % top pannel
    topp3=uipanel(txh,'Visible','on','Title','Template Preview','TitlePosition','righttop','FontWeight','bold','FontSize',12,'Position',[.0 .12 1 0.88],'ForegroundColor','red','BackgroundColor','g');
    topp3right=uipanel(topp3,'Position',[.875 .0 0.125 1]);
    uicontrol(topp3right,'Style','text','String','Name','Units','normalized','Position',[.05 .96 .9 .03],'FontWeight','bold','FontSize',12,'ForegroundColor','red');
    previewpop=uicontrol(topp3right,'Style','popup','String',templatenames,'Tag','previewpop','Units','normalized','Position',[.05 .93 .9 .03],...
        'FontWeight','bold','FontSize',10,'Callback',@previewpop_callback);
    prcheck=uicontrol(topp3right,'Style','checkbox','String','P Refract/Head','Tag','prcheck','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@checkbox_callback,'Units','normalized','Position',[.05 .89 .9 .03],'ForegroundColor','blue','BackgroundColor','y');
    prlist=uicontrol(topp3right,'Style','listbox','Tag','prlist','String',num2cell(previewtypelist{1}),'Units','normalized','Position',[.05 .63 .9 .26],...
        'FontWeight','bold','FontSize',12,'Callback',@previewlist_callback,'Max',100);
    plcheck=uicontrol(topp3right,'Style','checkbox','String','P Reflection','Tag','plcheck','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@checkbox_callback,'Units','normalized','Position',[.05 .6 .9 .03],'ForegroundColor','blue','BackgroundColor','y');
    pllist=uicontrol(topp3right,'Style','listbox','Tag','pllist','String',num2cell(previewtypelist{2}),'Units','normalized','Position',[.05 .32 .9 .28],...
        'FontWeight','bold','FontSize',12,'Callback',@previewlist_callback,'Max',100);
    slcheck=uicontrol(topp3right,'Style','checkbox','String','S Reflection','Tag','slcheck','HorizontalAlignment','center','FontWeight','bold','FontSize',10,...
        'Callback',@checkbox_callback,'Units','normalized','Position',[.05 .29 .9 .03],'ForegroundColor','blue','BackgroundColor','y');
    sllist=uicontrol(topp3right,'Style','listbox','Tag','sllist','String',num2cell(previewtypelist{3}),'Units','normalized','Position',[.05 .0 .9 .29],...
        'FontWeight','bold','FontSize',12,'Callback',@previewlist_callback,'Max',100);
    topp3left1=uipanel(topp3,'Visible','on','Title','Phases to output','TitlePosition','centertop','FontWeight','bold','FontSize',12,'Position',[.0 .3 0.875 0.7],'ForegroundColor','red','BackgroundColor','y');
    previewcolname={'Survey','Name','Phase','ID','Group','Layer','Ray','Wave','Template source','Remarks','Select'};
    previewcolumnformat={'char', 'char', 'numeric', 'numeric','numeric', 'numeric','numeric','numeric','char','char','logical'};
    previewcolumneditable=[false false false false false false false false false true true];
    previewcolumnwidth={50 100 45 30 50 50 40 40 120 400 50};
    previewtb1=uitable(topp3left1,'Tag','previewtb1','Units','normalized','Position',[.0 .0 1 1],'ColumnName',previewcolname,'ColumnFormat',previewcolumnformat,...
            'ColumnWidth',previewcolumnwidth,'ColumnEditable',previewcolumneditable,'FontSize',8,'CellEditCallback',@changeline_callback);
    set(previewtb1,'Data',previewtabledata);
    topp3left2=uipanel(topp3,'Visible','on','Title','Temporarily Removed','TitlePosition','centertop','FontWeight','bold','FontSize',12,'Position',[.0 .0 0.875 0.3],'ForegroundColor','blue','BackgroundColor','y');
    previewtb2=uitable(topp3left2,'Tag','previewtb2','Units','normalized','Position',[.0 .0 1 1],'ColumnName',previewcolname,'ColumnFormat',previewcolumnformat,...
            'ColumnWidth',previewcolumnwidth,'ColumnEditable',previewcolumneditable,'FontSize',8,'CellEditCallback',@changeline_callback); 
        
    %------ others
    if isempty(lockedtemplateID);
        set(rbh1,'Enable','off');
        set(rbh2,'Enable','off');
%         set(addtobt,'Enable','off');
%         set(removefrombt,'Enable','off');
    end
    set(txh,'Visible','on');
    set(txh,'CloseRequestFcn',@my_closerequest)
end

uiwait(txh);

%----- Callback Functions ------%
    function my_closerequest(hObject, eventdata)
        selection = questdlg('Do you want to save the changes to the database and exit?',...
            'Close Request Function','Yes','No','Cancel','Cancel');
        switch selection,
            case 'Yes'
                [newOBS,newSCS,newphasegroup]=deal(OBS,SCS,phasegroup);
                delete(txh);
            case 'No'
                delete(txh);
            case 'Cancel'
        end
    end

    function selectionChange_callback(src, event)
        switch get(event.NewValue,'Tag') % Get Tag of selected object.
            case '1'
                radio_status=[true false false];
                fun_batch_ui_switch({bottomp1,topp1},'Visible','on');
                fun_batch_ui_switch({bottomp2,topp2,bottomp3,topp3},'Visible','off');
            case '2'
                radio_status=[false true false];
                fun_batch_ui_switch({bottomp2,topp2},'Visible','on');
                fun_batch_ui_switch({bottomp1,topp1,bottomp3,topp3},'Visible','off');
            case '3'
                radio_status=[false false true];
                fun_batch_ui_switch({bottomp3,topp3},'Visible','on');
                fun_batch_ui_switch({bottomp2,topp2,bottomp1,topp1},'Visible','off');
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
    end

    function checkbox_callback(src,event)
        if get(src,'Value')==get(src,'Max');
            ischecked=true;
            isenable='inactive';
        else
            ischecked=false;
            isenable='on';
        end
        tabledata=get(previewtb1,'Data');
        switch get(src,'Tag');
            case 'prcheck'
                index=(cell2mat(tabledata(:,8))==1)&(cell2mat(tabledata(:,7))~=2);
                listname=prlist;
            case 'plcheck'
                index=(cell2mat(tabledata(:,8))==1)&(cell2mat(tabledata(:,7))==2);
                listname=pllist;
            case 'slcheck'
                index=(cell2mat(tabledata(:,8))==2)&(cell2mat(tabledata(:,7))==2);
                listname=sllist;
        end
        tabledata(index,end)={ischecked};
        set(previewtb1,'Data',tabledata);
        set(listname,'Enable',isenable);
    end

    function comparepop_callback(src,event)
        
    end


    function updateplot_callback(src,event)
    end

    function selectpop_callback(src,event)
        given=phasegroup(get(src,'Value'));
        selectliststring=' ';
        selectTable1=fun_form_table_selection(given);
        if ~isempty(selectTable1);
            selectTable1=fun_check_inpreview(selectTable1);
            selectliststring=fun_make_select_list(cell2mat(selectTable1(:,5)));
        end
        set(selectlist1,'String',selectliststring,'Value',1);
        set(selecttb1,'Data',selectTable1);
        selectTable2=fun_form_table_unassigned;
        selectliststring=' ';
        if ~isempty(selectTable2);
            selectTable2=fun_check_inpreview(selectTable2);
            selectliststring=fun_make_select_list(cell2mat(selectTable2(:,5)));
        end
        set(selectlist2,'String',selectliststring,'Value',1);
        set(selecttb2,'Data',selectTable2);
    end

    function selectlist_callback(src,event)
        timegroupstring=get(src,'string');
        index=get(src,'Value');
        switch get(src,'Tag');
            case 'selectlist1'
                tbsrc=selecttb1;
            case 'selectlist2'
                tbsrc=selecttb2;
        end
        tabledata=get(tbsrc,'Data');
        groupcol=cell2mat(tabledata(:,5));
        for i=1:length(timegroupstring);
            groupid=str2num(timegroupstring{i});
            index2=groupcol==groupid;
            if isempty(find(index==i));
                tabledata(index2,end)={false};
            else
                tabledata(index2,end)={true};
            end
        end
        set(tbsrc,'Data',tabledata);
    end

    function setcheck_callback(src,event)
        srctag=get(src,'Tag');
        if isempty(strfind(srctag,'top'));
            tbsrc=selecttb2;
        else
            tbsrc=selecttb1;
        end
        if ~isempty(strfind(srctag,'clear'));
            method='clear';
        elseif ~isempty(strfind(srctag,'flip'));
            method='flip';
        else
            method='checkall';
        end
        table1data=get(tbsrc,'Data');
        switch method
            case 'checkall'
                table1data(:,end)={true};
            case 'clear'
                table1data(:,end)={false};
            case 'flip'
                table1data(:,end)=num2cell(logical(~cell2mat(table1data(:,end))));
        end
        set(tbsrc,'Data',table1data);
    end

    function addto_callback(src,event)
        selection = questdlg('It will add selected phases to the preview window.','','Yes','Cancel','Cancel');
        switch selection;
            case 'Yes'
                tb=get(selecttb1,'Data'); 
                if ~isempty(tb)
                    index=~cell2mat(tb(:,9)) & cell2mat(tb(:,end));
                    addto=cell2mat(tb(index,4)); % addto: the valid phaseID array will be added to preview window
                    if ~isempty(addto);
                        st=fun_form_table_addto(addto,phasegroup(get(selectpop,'Value')).name);
                        set(previewtb1,'Data',[get(previewtb1,'Data'); st]);
                        tb(cell2mat(tb(:,end)),9)={true};
                        set(selecttb1,'Data',tb);
                    end
                end
                tb=get(selecttb2,'Data');
                if ~isempty(tb)
                    index=~cell2mat(tb(:,9)) & cell2mat(tb(:,end));
                    addto=cell2mat(tb(index,4)); % addto: the valid phaseID array will be added to preview window
                    if ~isempty(addto);
                        st=fun_form_table_addto(addto,' ');
                        set(previewtb1,'Data',[get(previewtb1,'Data'); st]);
                        tb(cell2mat(tb(:,end)),9)={true};
                        set(selecttb2,'Data',tb);
                    end
                end
        end
    end

    function removefrom_callback(src,event)
        tb=[get(selecttb1,'Data');get(selecttb2,'Data')];
        index=cell2mat(tb(:,9)) & cell2mat(tb(:,end));
        removeID=cell2mat(tb(index,4));
        if ~isempty(removeID)
            doremove=true;
            selection = questdlg('Will you protect the original phases of locked template in preview window, i.e., those phases will not be removed?','','Yes, protect locked.','No, remove all selected.','Cancel','Cancel');
            switch selection;
                case 'Yes, protect locked.'
                    lockedID=cell2mat(lockedtemplateTable(:,4));
                    if ~isempty(lockedID);
                        index=[];
                        for i=1:length(removeID)
                            if ~isempty(find(lockedID==removeID(i)));
                                index=[index i];
                            end
                        end
                        if ~isempty(index);
                            removeID(index)=[];
                        end
                    end
                    if isempty(removeID);
                        doremove=false;
                    end
                case 'No, remove all selected.'
                case 'Cancel'
                    doremove=false;
            end
            if doremove;
                for i=1:2;
                    tbsrc=previewtb1;
                    if i==2;
                        tbsrc=previewtb2;
                    end
                    tb=get(tbsrc,'Data');
                    if ~isempty(tb);
                        phaseID=cell2mat(tb(:,4));
                        index=[];
                        for j=1:length(removeID);
                            sameID=find(phaseID==removeID(j));
                            if ~isempty(sameID);
                                index=[index sameID];
                            end
                        end
                        tb(index,:)=[];
                        set(tbsrc,'Data',tb);
                    end
                end
                selectpop_callback(selectpop,event);
            end
        end
    end

    function previewpop_callback(src,event)
        given=phasegroup(get(src,'Value'));
        previewtypelist=fun_sort_ray_and_wave(given);
        lockedtemplateTable=fun_form_table_preview(given);
        set(prlist,'String',num2cell(previewtypelist{1}),'Value',1);
        set(pllist,'String',num2cell(previewtypelist{2}),'Value',1);
        set(sllist,'String',num2cell(previewtypelist{3}),'Value',1);
        set(previewtb1,'Data',lockedtemplateTable);
        set(previewtb2,'Data',[]);
    end

    function previewlist_callback(src,event)
        timegroupstring=get(src,'string');
        index=get(src,'Value');
        tabledata=get(previewtb1,'Data');
        groupcol=cell2mat(tabledata(:,5));
        for i=1:length(timegroupstring);
            groupid=str2num(timegroupstring{i});
            index2=groupcol==groupid;
            if isempty(find(index==i));
                tabledata(index2,end)={false};
            else
                tabledata(index2,end)={true};
            end
        end
        set(previewtb1,'Data',tabledata);
    end

    function changeline_callback(src,event)
        if event.Indices(2)==10;
            tb=get(src,'Data');
            phaseID=tb{event.Indices(1),4};
            index=totalphase(:,1)==phaseID;
            survey=totalphase(index,3);
            if survey<0;
                SCS(-survey).remarks{totalphase(index,4)}=event.NewData;
            else
                OBS(survey).remarks{totalphase(index,4)}=event.NewData;
            end
        end
    end

    function name_callback(src,event)
        selection = questdlg('Please select a button OR CLICK TO CLOSE this window for CANCEL','','Rename current template','Create new empty template','Delete current template','Rename current template');
        phasegroupnumber=get(previewpop,'Value');
        need_update_templatenames=false;
        switch selection;
            case 'Rename current template'
                currentname=phasegroup(phasegroupnumber).name;
                prompt = {['Template #',num2str(phasegroupnumber),char(10),'Current name: ',currentname,char(10),'Input new name:']};
                dlg_title = 'Rename template';
                num_lines = 1;
                answer = inputdlg(prompt,dlg_title,num_lines);
                if ~isempty(answer);
                    phasegroup(phasegroupnumber).name=answer{1};
                    need_update_templatenames=true;
                end
            case 'Create new empty template'
                prompt = {'Input name of the new template:'};
                dlg_title = 'New template';
                num_lines = 1;
                answer = inputdlg(prompt,dlg_title,num_lines);
                if ~isempty(answer);
                    phasegroup(end+1).name=answer{1};
                    phasegroupnumber=length(phasegroup);
                    need_update_templatenames=true;
                end
            case 'Delete current template'
                makesure = questdlg('Are you sure to delete current template?','','Delete !','Cancel','Cancel');
                switch makesure;
                    case 'Delete !'
                        phasegroup(phasegroupnumber)=[];
                        need_update_templatenames=true;
                        phasegroupnumber=1;
                end
        end
        if need_update_templatenames;
            fun_update_templatenames(2);
            set(previewpop,'Value',phasegroupnumber);
            previewpop_callback(previewpop,event);
        end
    end

    function tempremove_callback(src,event)
        selection = questdlg('It will temporarily remove selected phases from top windows to bottom window.','','Yes','Cancel','Cancel');
        switch selection;
            case 'Yes'
                table1=get(previewtb1,'Data');
                table2=get(previewtb2,'Data');
                index=cell2mat(table1(:,end));
                table2=[table2; table1(index,:)];
                table1(index,:)=[];
                set(previewtb1,'Data',table1);
                set(previewtb2,'Data',table2);
        end
    end

    function restore_callback(src,event)
        selection = questdlg('It will restore temporarily removed phases to top preview windows.','','Only selected','Restore all','Cancel','Cancel');
        table2=get(previewtb2,'Data');
        if (~strcmp(selection,'Cancel'))&&(~isempty(table2));
            table1=get(previewtb1,'Data');
            if strcmp(selection,'Only selected');
                index=cell2mat(table2(:,end));
            else
                index=1:length(table2(:,1));
            end
            table1=[table1; table2(index,:)];
            table2(index,:)=[];
            set(previewtb1,'Data',table1);
            set(previewtb2,'Data',table2);
        end
    end

    function select_callback(src,event)
        if isempty(lockedtemplateID);
            lockedtemplateID=get(previewpop,'Value');
            set(previewpop,'Enable','inactive');
            set(selectbt,'String','Unlock Template','ForegroundColor','red');
            set(rbh2,'Enable','on');
            set(selectpop,'Value',get(previewpop,'Value'));
            selectpop_callback(selectpop,event);
            set(namebt,'Enable','off');
        else
            lockedtemplateID=[];
            set(previewpop,'Enable','on');
            set(selectbt,'String','Lock Template','ForegroundColor','blue');
            set(rbh2,'Enable','off');
            set(namebt,'Enable','on');
        end
    end

    function save_callback(src,event)
        % replace or save as template
        selection = questdlg('It will save all phases in top preview windows as phase group template.','','Replace current template','Save as a new template','Cancel','Cancel');
        phasegroupnumber=get(previewpop,'Value');
        need_update_templatenames=false;
        switch selection;
            case 'Replace current template'
                makesure = questdlg('Are you sure to replace/update current template?','','Yes !','Cancel','Cancel');
                switch makesure;
                    case 'Yes !'
                        need_update_templatenames=true;
                end
            case 'Save as a new template'
                prompt = {'Input name of the new template:'};
                dlg_title = 'New template';
                num_lines = 1;
                answer = inputdlg(prompt,dlg_title,num_lines);
                if ~isempty(answer);
                    phasegroup(end+1).name=answer{1};
                    phasegroupnumber=length(phasegroup);
                    need_update_templatenames=true;
                end
        end
        if need_update_templatenames;
            table1=get(previewtb1,'Data');
            % previewcolname={'Survey','Name','Phase','ID','Group','Layer','Ray','Wave','In preview','Remarks','Select'};
            % totalphase=NaN(1,6); % n-by-6 , columns are (1) phaseID; (2) time group; (3) survey; (4) phase; (5) ray; (6) wave
            % phasegroup=struct('name',{},'OBS',{},'SCS',{});
            % name: user defined name for each group
            % OBS: a 6-by-phase number matrix, the rows are (1) phase ID, (2) time group, (3) OBS#, (4) OBS#.moffset, (5) phase number in OBS#, (6) direction: left -1, right 1, both 2
            % SCS: a 5-by-phase number matrix, the rows are (1) phase ID, (2) time group, (3) SCS#, (4) shot_rec offset, (5) phase number in SCS#
            obspart=[];
            scspart=[];
            for i=1:length(table1(:,1));
                phaseID=table1{i,4};
                index=totalphase(:,1)==phaseID;
                surveynumber=totalphase(index,3);
                if surveynumber<0;
                    shot_rec=SCS(-surveynumber).shot_rec;
                    if isempty(shot_rec)
                        shot_rec=NaN;
                    end
                    scspart=[scspart; totalphase(index,1:2), -surveynumber, shot_rec, totalphase(index,4)];
                else
                    obspart=[obspart; totalphase(index,1:2), surveynumber, OBS(surveynumber).moffset, totalphase(index,4), 2];
                end
            end
            phasegroup(phasegroupnumber).OBS=obspart';
            phasegroup(phasegroupnumber).SCS=scspart';
            fun_update_templatenames(2);
            set(previewpop,'Value',phasegroupnumber);
            previewpop_callback(previewpop,event);
        end
    end

    function writetxin_callback(src,event)
        % output 2 ASCII files: tx_name.in & tx_name.txt for summary 
        tb=get(previewtb1,'Data');
        if ~isempty(tb);
            dowrite=true;
            selection = questdlg('It will write 2 ASCII files: tx_name.in & tx_name.txt, the latter containing the same contents as shown in preview window for tx.in summary purpose.','',...
                'Pick a folder to save the files','Cancel','Cancel');
            switch selection
                case 'Pick a folder to save the files'
                    txfilepath=uigetdir(txfilepath);
                    if txfilepath==0;
                        dowrite=false;
                        txfilepath=[];
                    end
                case 'Cancel'
                    dowrite=false;
            end
            if dowrite;
                systime=round(clock);
                systime=[num2str(systime(1)),sprintf('_%02d',systime(2:end))];
                txfilename=phasegroup(get(previewpop,'Value')).name;
                txfilename=['tx_',txfilename,'_',systime];
                txfull=fullfile(txfilepath,txfilename);
                [txindata,tglist,xshot_scs]=fun_form_txindata; % xshot_scs is used to output the xshot values for SCS shots in r.in
                for i=1:length(tglist);
                    txindata(txindata(:,end)==tglist(i),end)=itcol_ircol(i);
                end;
                fid=fopen([txfull,'.in'],'w'); % tx.in file
                for i=1:length(txindata(:,1));
                    fprintf(fid,'%10.3f%10.3f%10.3f%10i\n',txindata(i,:));
                end
                fclose(fid);
                fid=fopen([txfull,'.txt'],'w'); % summary txt file for tx.in
                fprintf(fid,'%-80s\n','Survey|     Name      |Phase| ID |Group|Layer|Ray|Wave|Template source|  Remarks');
                fprintf(fid,'%-90s\n','------------------------------------------------------------------------------------------');
                for i=1:length(tb(:,1));
                    fprintf(fid,'%-6s %-15s %-5i %-4i %-5i %-5i %-3i %-4i %-15s %-50s\n',tb{i,1:end-1});
                end
                fprintf(fid,'\n');
                fprintf(fid,'Colors for time groups:\n');
                fprintf(fid,'1(red), 2(green), 3(blue), 4(cyan/light blue), 5(magenta), 6(orange), 10(yellow)\n');
                fprintf(fid,'|Time group|  Color   |\n'); 
                for i=1:length(tglist);
                    fprintf(fid,'%8i    %6i\n',tglist(i),itcol_ircol(i));
                end;
                if ~isempty(xshot_scs)
                    fprintf(fid,'\n');
                    fprintf(fid,'SCS source position for r.in=\n');
                    fprintf(fid,'   xshot=\n');
                    allshots=length(xshot_scs);
                    outputcount=0;
                    for i=1:allshots;
                        outputcount=outputcount+1;
                        if outputcount==1;
                            fprintf(fid,'   ');
                        end
                        fprintf(fid,'%8.4f,',xshot_scs(i));
                        if outputcount==5;
                            fprintf(fid,'\n');
                            outputcount=0;
                        end
                        if i==allshots;
                            fprintf(fid,'\n');
                        end
                    end
                    fprintf(fid,'\n');
                    fprintf(fid,'   zshot=\n');
                    fprintf(fid,'   %5d*0,\n',allshots);
                end
                fclose(fid);
            end
        end
    end

%------ tool functions ------

    function previewtypelist=fun_sort_ray_and_wave(given)
        previewtypelist={[] [] []};
        data=[];
        if ~isempty(given.OBS);
            data=[data given.OBS(2,:)];
        end
        if ~isempty(given.SCS);
            data=[data given.SCS(2,:)];
        end
        while ~isempty(data)
            ID=data(1);
            type=timegrouptype(timegrouptype(:,1)==ID,2);
            previewtypelist{type}=[previewtypelist{type} ID];
            data(data==ID)=[];
        end
    end

    function selectliststring=fun_make_select_list(giventimegroup)
        selectliststring=[];
        while ~isempty(giventimegroup)
            ID=giventimegroup(1);
            selectliststring=[selectliststring ID];
            giventimegroup(giventimegroup==ID)=[];
        end
        selectliststring=num2cell(selectliststring);
    end

    function selectTable=fun_check_inpreview(selectTable)
        tb=[get(previewtb1,'Data'); get(previewtb2,'Data')];
        if ~isempty(tb);
            phaseIDinpreview=cell2mat(tb(:,4));
            for i=1:length(selectTable(:,1));
                if ~isempty(find(phaseIDinpreview==selectTable{i,4}));
                    selectTable(i,9)={true};
                end
            end
        end
    end

    function tabledata=fun_form_table_preview(given)
        count=0;
        tabledata={};
        if ~isempty(given.OBS); % previewcolname={'Survey','Name','Phase','ID','Group','Layer','Ray','Wave','Template source','Remarks','Select'};
            % OBS: a 6-by-phase number matrix, the rows are (1) phase ID, (2) time group, (3) OBS#, (4) OBS#.moffset, (5) phase number in OBS#, (6) direction: left -1, right 1, both 2
            data=given.OBS;
            for i=1:size(data,2)
                surveynumber=data(3,i);
                phasenumber=data(5,i);
                currentsurvey=OBS(surveynumber);
                count=count+1;
                tabledata(count,:)={['OBS#' num2str(surveynumber)], currentsurvey.name, phasenumber, data(1,i), data(2,i), currentsurvey.phase{phasenumber}(1,7),...
                    currentsurvey.phase{phasenumber}(1,8), currentsurvey.phase{phasenumber}(1,9), given.name, currentsurvey.remarks{phasenumber}, false};
            end            
        end
        if ~isempty(given.SCS);
            % SCS: a 5-by-phase number matrix, the rows are (1) phase ID, (2) time group, (3) SCS#, (4) shot_rec offset, (5) phase number in SCS#
            data=given.SCS;
            for i=1:size(data,2)
                surveynumber=data(3,i);
                phasenumber=data(5,i);
                currentsurvey=SCS(surveynumber);
                count=count+1;
                tabledata(count,:)={['SCS#' num2str(surveynumber)], currentsurvey.name, phasenumber, data(1,i), data(2,i), currentsurvey.phase{phasenumber}(1,7),...
                    currentsurvey.phase{phasenumber}(1,8), currentsurvey.phase{phasenumber}(1,9), given.name, currentsurvey.remarks{phasenumber}, false};
            end
        end
    end

    function tabledata=fun_form_table_selection(given)
        count=0;
        tabledata={};
        if ~isempty(given.OBS); % selectioncolname={'Survey','Name','Phase','ID','Group','Layer','Ray','Wave','In preview','Remarks','Select'};
            % OBS: a 6-by-phase number matrix, the rows are (1) phase ID, (2) time group, (3) OBS#, (4) OBS#.moffset, (5) phase number in OBS#, (6) direction: left -1, right 1, both 2
            data=given.OBS;
            for i=1:size(data,2)
                surveynumber=data(3,i);
                phasenumber=data(5,i);
                currentsurvey=OBS(surveynumber);
                count=count+1;
                tabledata(count,:)={['OBS#' num2str(surveynumber)], currentsurvey.name, phasenumber, data(1,i), data(2,i), currentsurvey.phase{phasenumber}(1,7),...
                    currentsurvey.phase{phasenumber}(1,8), currentsurvey.phase{phasenumber}(1,9), false, currentsurvey.remarks{phasenumber}, false};
            end            
        end
        if ~isempty(given.SCS);
            % SCS: a 5-by-phase number matrix, the rows are (1) phase ID, (2) time group, (3) SCS#, (4) shot_rec offset, (5) phase number in SCS#
            data=given.SCS;
            for i=1:size(data,2)
                surveynumber=data(3,i);
                phasenumber=data(5,i);
                currentsurvey=SCS(surveynumber);
                count=count+1;
                tabledata(count,:)={['SCS#' num2str(surveynumber)], currentsurvey.name, phasenumber, data(1,i), data(2,i), currentsurvey.phase{phasenumber}(1,7),...
                    currentsurvey.phase{phasenumber}(1,8), currentsurvey.phase{phasenumber}(1,9), false, currentsurvey.remarks{phasenumber}, false};
            end
        end
    end

    function st2=fun_form_table_unassigned
        % selectioncolname={'Survey','Name','Phase','ID','Group','Layer','Ray','Wave','In preview','Remarks','Select'};
        % totalphase=NaN(1,6); % n-by-6 , columns are (1) phaseID; (2) time group; (3) survey; (4) phase; (5) ray; (6) wave
        tb=get(selecttb1,'Data');
        if isempty(tb)
            used=0;
        else
            used=cell2mat(tb(:,4));
        end
        st2={};
        count=0;
        for i=1:length(totalphase(:,1));
            phaseID=totalphase(i,1);
            if isempty(find(used==phaseID))
                surveynumber=totalphase(i,3);
                phasenumber=totalphase(i,4);
                count=count+1;
                if surveynumber<0;
                    surveynumber=-surveynumber;
                    currentsurvey=SCS(surveynumber);
                    st2(count,:)={['SCS#' num2str(surveynumber)], currentsurvey.name, phasenumber, phaseID, totalphase(i,2), currentsurvey.phase{phasenumber}(1,7),...
                        currentsurvey.phase{phasenumber}(1,8), currentsurvey.phase{phasenumber}(1,9), false, currentsurvey.remarks{phasenumber}, false};
                else
                    currentsurvey=OBS(surveynumber);
                    st2(count,:)={['OBS#' num2str(surveynumber)], currentsurvey.name, phasenumber, phaseID, totalphase(i,2), currentsurvey.phase{phasenumber}(1,7),...
                        currentsurvey.phase{phasenumber}(1,8), currentsurvey.phase{phasenumber}(1,9), false, currentsurvey.remarks{phasenumber}, false};
                end
            end
        end
    end

    function st2=fun_form_table_addto(addto,fromstring) % addto: the valid phaseID array will be added to preview window
        % previewcolname={'Survey','Name','Phase','ID','Group','Layer','Ray','Wave','Template source','Remarks','Select'};
        % totalphase=NaN(1,6); % n-by-6 , columns are (1) phaseID; (2) time group; (3) survey; (4) phase; (5) ray; (6) wave
        st2={};
        for i=1:length(addto);
            phaseID=addto(i);
            index=totalphase(:,1)==phaseID;
            surveynumber=totalphase(index,3);
            phasenumber=totalphase(index,4);
            if surveynumber<0;
                surveynumber=-surveynumber;
                currentsurvey=SCS(surveynumber);
                st2(i,:)={['SCS#' num2str(surveynumber)], currentsurvey.name, phasenumber, phaseID, totalphase(index,2), currentsurvey.phase{phasenumber}(1,7),...
                    currentsurvey.phase{phasenumber}(1,8), currentsurvey.phase{phasenumber}(1,9), fromstring, currentsurvey.remarks{phasenumber}, false};
            else
                currentsurvey=OBS(surveynumber);
                st2(i,:)={['OBS#' num2str(surveynumber)], currentsurvey.name, phasenumber, phaseID, totalphase(index,2), currentsurvey.phase{phasenumber}(1,7),...
                    currentsurvey.phase{phasenumber}(1,8), currentsurvey.phase{phasenumber}(1,9), fromstring, currentsurvey.remarks{phasenumber}, false};
            end
        end
    end

    function templatenames=fun_update_templatenames(mode)
        templatenames={};
        for i=1:length(phasegroup)
            templatenames{i}=[num2str(i),' (',phasegroup(i).name,')'];
        end
        switch mode
            case 1; % only returen templatenames
            case 2; % also set templatenames to all popups
                set(comparepop1,'String',templatenames);
                set(comparepop2,'String',templatenames);
                set(selectpop,'String',templatenames);
                set(previewpop,'String',templatenames);
        end
    end

    function [txindata,tglist,xshot_scs]=fun_form_txindata
        tb=get(previewtb1,'Data');
        phaseIDtimegroup=cell2mat(tb(:,4:5));
        phaseIDtimegroup=sortrows(phaseIDtimegroup,[2 1]);
        tglist=unique(phaseIDtimegroup(:,2)); % time group list                
        obspart=[];
        scspart=[];
        xshot_scs=[];
        % totalphase=NaN(1,6); % n-by-6 , columns are (1) phaseID; (2) time group; (3) survey; (4) phase; (5) ray; (6) wave
        for i=1:length(phaseIDtimegroup(:,1));
            ID=phaseIDtimegroup(i,1); % phase ID
            TG=phaseIDtimegroup(i,2); % time group
            index=find(totalphase(:,1)==ID);
            SN=totalphase(index,3); % survey number
            PN=totalphase(index,4);  % phase number
            if SN<0; % SCS part: to ensure that all SCS reflections are searched in rayinvr, the output also need include both left and right directions
                CS=SCS(-SN); % current survey
                CP=CS.phase{PN}; % current phase
                for j=1:length(CP(:,1));
                    scspart=[scspart; CP(j,1) -1.0 0.0 0];
                    scspart=[scspart; CP(j,1:4)];
                    scspart=[scspart; CP(j,1) 1.0 0.0 0];
                    scspart=[scspart; CP(j,1:4)];
                    xshot_scs=[xshot_scs; CP(j,1)];
                end
            else  % OBS part
                CS=OBS(SN); % current survey
                CP=CS.phase{PN}; % current phase
                left=CP(:,6)==-1;
                right=CP(:,6)==1;
                if ~isempty(left);
                    obspart=[obspart; CS.moffset -1.0 0.0 0];
                    obspart=[obspart; CP(left,1:4)];
                end
                if ~isempty(right);
                    obspart=[obspart; CS.moffset 1.0 0.0 0];
                    obspart=[obspart; CP(right,1:4)];
                end
            end
        end
        txindata=[scspart; obspart; 0.000 0.000 0.000 -1];
        xshot_scs=unique(xshot_scs);
    end

end  % function