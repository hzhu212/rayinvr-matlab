function fun_batch_ui_switch(uilist,property,willbe)
% uilist: a cell of ui component handles
% property: a string of switch type property name of ui component want to change
% willbe: 'on' or 'off'; if this argin exist, the ui component will be set as "willbe", no matter the current status

if ~iscell(uilist);  % if the input uilist is not cell type
    uilist=num2cell(uilist);
end

for i=1:length(uilist);
    if nargin==2;
        current=get(uilist{i},property);
        switch current
            case 'off'
                willbe='on';
            case 'on'
                willbe='off';
        end
    end
    set(uilist{i},property,willbe);
end