function fun_store_rayinvr_plot(hfig1, hfig2, working_dir)
% store plot data to a .mat file
% 提取射线图和走时图中的所有 plot，以数据的形式保存到 .mat 文件

    file = fullfile(working_dir, 'plotdata.rayinvr.mat');

    curves1 = get(findall(hfig1, 'type', 'axes'), 'Children');
    curves2 = get(findall(hfig2, 'type', 'axes'), 'Children');
    curves = [curves1; curves2];
    curves = curves(:);

    data = {};
    labels = {};
    for ii = 1:length(curves)
        curve = curves(ii);
        if isempty(curve.UserData), continue; end
        data{end+1} = [curve.XData; curve.YData];
        labels{end+1} = curve.UserData.tag;
    end
    data{end+1} = strjoin(labels, '|');
    data = data';
    save(file, 'data');
end
