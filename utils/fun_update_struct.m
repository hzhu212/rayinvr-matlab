function st = fun_update_struct(st, new_st)
% update a struct with another struct.

    f = fieldnames(new_st);
    for ii = 1:length(f)
       st.(f{ii}) = new_st.(f{ii});
    end
end
