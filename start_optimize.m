%% Run optimize when starting at no-GUI environment

function [final_x, final_val] = start_optimize(pathIn)

    addpath('./functions');
    addpath('./optimization');

    if nargin == 0
        pathIn = fullfile(pwd, 'data', 'subbarao_s');
    end
    mainOpts.pathIn = pathIn;
    % mainOpts.pathVin = fullfile(mainOpts.pathIn, 'v.in');
    % mainOpts.pathRin = fullfile(mainOpts.pathIn, 'r.in');

    [final_x, final_val] = fun_optimize(mainOpts);
end
