function fun_update_mat(mat_file, obj)
% update mat file with a struct.

	% ws = load(mat_file);
	% ws = fun_update_struct(ws, obj);
	% save(mat_file, '-struct', ws);
	save(mat_file, '-struct', 'obj', '-append');
end
