% 从 r.in 文件读入初始泊松比数组

function [ray, pois] = fun_load_from_rin(file_rin)
	% just a test for example 8
	% pois = [0.1,0.4,0.2500,0.2500,0.2500];
	file_rin_m = fun_trans_rin2m(file_rin);
	run(file_rin_m);
	clearvars('-except', 'ray', 'pois');
end

