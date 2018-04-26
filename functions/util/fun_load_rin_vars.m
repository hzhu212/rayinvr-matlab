function [obj] = fun_load_rin_vars(file_rin_m, cell_vars)
%% fun_load_rin_vars: 载入 r_in.m 中的指定变量

    run(file_rin_m);
    for ii = 1:length(cell_vars)
        varname = cell_vars{ii};
        eval(sprintf('obj.%s=%s;', varname, varname));
    end
end
