function fun_store_plotdata(hfig1, hfig2)
% store plot data to a .mat file

    lines1 = get(get(hfig1, 'Children'), 'Children');
    lines2 = get(get(hfig2, 'Children'), 'Children');
    lines = [lines1; lines2];

    data = {};
    label = [];
    for ii = 1:length(lines)
        line_ = lines(ii);
        if isempty(line_.UserData), continue; end
        data{end+1} = [line_.XData; line_.YData];
        label = [label, '|', line_.UserData.tag];
    end
    label = label(2:end);
    data{end+1} = label;
    data = data';
    save('plotdata.mat', 'data');


    % h5file = 'plotdata.h5';
    % if exist(h5file, 'file'), delete(h5file); end

    % lines1 = get(get(hfig1, 'Children'), 'Children');
    % lines2 = get(get(hfig2, 'Children'), 'Children');

    % lines = [lines1; lines2];
    % data = []; label = string;
    % max_len = 500;
    % for ii = 1:length(lines)
    %     line_ = lines(ii);
    %     if isempty(line_.UserData), continue; end

    %     this_data = nan(2, max_len);
    %     len = min(max_len, length(line_.XData));
    %     this_data(:,1:len) = [line_.XData(1:len); line_.YData(1:len)];
    %     data(:,:,ii) = this_data;
    %     label(ii) = line_.UserData.tag;
    % end
    % label = strjoin(label, '|');
    % h5create(h5file, '/data', size(data));
    % h5write(h5file, '/data', data);
    % % h5writeatt(h5file, '/data', 'label', label);
    % save('plotdata.mat', 'data', 'label');

    % for ii = 1:length(lines1)
    %     line_ = lines1(ii);
    %     if isempty(line_.UserData), continue; end

    %     group_name = ['/fig1/', num2str(ii)];
    %     h5create(h5file, [group_name, '/x'], size(line_.XData));
    %     h5create(h5file, [group_name, '/y'], size(line_.YData));
    %     h5write(h5file, [group_name, '/x'], line_.XData);
    %     h5write(h5file, [group_name, '/y'], line_.YData);
    %     if ~isempty(line_.ZData)
    %         h5create(h5file, [group_name, '/z'], size(line_.ZData));
    %         h5write(h5file, [group_name, '/z'], line_.ZData);
    %     end
    %     h5writeatt(h5file, group_name, 'tag', line_.UserData.tag);
    % end

    % for ii = 1:length(lines2)
    %     line_ = lines2(ii);
    %     if isempty(line_.UserData), continue; end

    %     group_name = ['/fig2/', num2str(ii)];
    %     h5create(h5file, [group_name, '/x'], size(line_.XData));
    %     h5create(h5file, [group_name, '/y'], size(line_.YData));
    %     h5write(h5file, [group_name, '/x'], line_.XData);
    %     h5write(h5file, [group_name, '/y'], line_.YData);
    %     if ~isempty(line_.ZData)
    %         h5create(h5file, [group_name, '/z'], size(line_.ZData));
    %         h5write(h5file, [group_name, '/z'], line_.ZData);
    %     end
    %     h5writeatt(h5file, group_name, 'tag', line_.UserData.tag);
    % end


    % lines = [lines1; lines2];
    % lines_c1 = {};
    % for ii = 1:length(lines1)
    %     line_ = lines1(ii);
    %     if isempty(line_.UserData)
    %         continue;
    %     end
    %     obj = [];
    %     obj.xdata = line_.XData;
    %     obj.ydata = line_.YData;
    %     obj.zdata = line_.ZData;
    %     obj.tag = line_.UserData.tag;
    %     lines_c1{end+1} = obj;
    % end
    % lines_c2 = {};
    % for ii = 1:length(lines2)
    %     line_ = lines2(ii);
    %     if isempty(line_.UserData)
    %         continue;
    %     end
    %     obj = [];
    %     obj.xdata = line_.XData;
    %     obj.ydata = line_.YData;
    %     obj.zdata = line_.ZData;
    %     obj.tag = line_.UserData.tag;
    %     lines_c2{end+1} = obj;
    % end
    % save('plotdata.mat', 'lines_c1', 'lines_c2');
end
