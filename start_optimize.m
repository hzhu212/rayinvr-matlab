function [final_x, final_val] = start_optimize(pathIn, pathRin, pathVin, isUseOde)
% [final_x, final_val] = start_optimize(pathIn, pathRin, pathVin, isUseOde)
% Rayinvr inversed calculating without GUI.
% Will find the best parameters automaticly with genetic algorithm.

    if nargin < 1
        pathIn = fullfile(pwd, 'data', 'subbarao_s');
    end
    if nargin < 2
        pathRin = fullfile(pathIn, 'r.in');
    end
    if nargin < 3
        pathVin = fullfile(pathIn, 'v.in');
    end
    if nargin < 4
        isUseOde = false;
    end

    % Add functions to path.
    % `genpath` will add all the children path
    addpath(genpath('./functions'));
    addpath('./optimization');
    rmpath('./overwrite/fprintf');

    obj.pathIn = pathIn;
    obj.pathRinm = fun_trans_rin2m(pathRin);
    % Clear cached r_in.m, or the modification for r.in won't work
    clear(obj.pathRinm);
    obj.pathVin = pathVin;
    obj.isUseOde = isUseOde;

    obj.inOptimize = true;

    % Enable parallel computing
    try
        parpool;
    catch e
        ;
    end

    % There is no need to write output file when optimizing.
    addpath('./overwrite/fprintf');
    try
        tic;
        [final_x, final_val] = fun_optimize(obj);
        toc;
    catch e
        rmpath('./overwrite/fprintf');
        rethrow(e);
    end
    rmpath('./overwrite/fprintf');
end
