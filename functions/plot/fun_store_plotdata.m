function fun_store_plotdata(hfig1, hfig2, working_dir)
% store plot data to a .mat file

    file = fullfile(working_dir, 'plotdata.rayinvr.mat');

    curves1 = get(get(hfig1, 'Children'), 'Children');
    curves2 = get(get(hfig2, 'Children'), 'Children');
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
