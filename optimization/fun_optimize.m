% 通过优化算法寻找使得 CHI 最小的 pois 数组

function [x,fval] = fun_optimize(mainOptions)
	file_rin = fullfile(mainOptions.pathIn, 'r.in');
	pois = fun_init_pois(file_rin);
	nvars = length(pois);

	mainOptions.isPlot = false;
	target_fun = fun_partialMain(mainOptions);
	% [x, fval] = fminunc(target_fun, pois);

	% default options:
	% Generations: 100 * nvars
	% PopulationSize: {50} when numberOfVariables <= 5, {200} otherwise | {min(max(10*nvars,40),100)} for mixed-integer problems
	options = gaoptimset('Generations', 10, 'PopulationSize', 50);
	[x, fval] = ga(target_fun, nvars, [],[],[],[],zeros(nvars,1),ones(nvars,1)*0.5,[],options);
end

function func = fun_partialMain(mainOptions)
	function y = wrapper(pois)
		mainOptions.pois = pois;
		[RMS, CHI] = main(mainOptions);
		y = CHI;
	end

	func = @wrapper;
end
