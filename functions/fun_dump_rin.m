function file_rin_mat = fun_dump_rin(file_rin_m)
	% dump varables from r_in.m to r_in.mat
	file_rin_mat = 'r_in.mat';
	save('temp.mat');
	clear;
	run(file_rin_m);
	save(file_rin_mat);
	clear;
	load('temp.mat');
end
