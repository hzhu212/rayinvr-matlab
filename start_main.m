%% Run main when starting at no-GUI environment

function [final_x, final_val] = start_main(pathIn)

    addpath('./functions');

    if nargin == 0
        pathIn = fullfile(pwd, 'data', 'examples', 'e1');
    end
    mainOpts.pathIn = pathIn;
    % mainOpts.pathVin = fullfile(mainOpts.pathIn, 'v.in');
    % mainOpts.pathRin = fullfile(mainOpts.pathIn, 'r.in');
    file_rin = fullfile(mainOpts.pathIn, 'r.in');
    file_rin_m = fun_trans_rin2m(file_rin);

    [RMS, CHI] = main(mainOpts);
end
