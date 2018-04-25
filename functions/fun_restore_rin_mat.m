function file_rin_mat = fun_restore_rin_mat(file_rin_m)
    % restore r_in.mat from r_in.m
    file_rin_mat = 'r_in.mat';
    run(file_rin_m);
    % save(file_rin_mat);
    save(file_rin_mat,'-regexp','^(?!(file_rin_*)$).');
end
