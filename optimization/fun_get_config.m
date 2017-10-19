%% 优化算法参数配置

function options = fun_get_config()

	% 优化过程中是否绘图，如是，则每个个体均绘图
	options.isPlot = false;
	% 优化所有层与优化一层内的所有块分开讨论
	options.type = 1;

	%% by layer
	if options.type == 1
		% 待优化的泊松比在 pois 数组中的 index
		options.layerIndexs = [4];
		% 基因算法代数
		options.nGeneration = 1;
		% 每代的个体数
		options.nPopulation = 10;
		% 待优化的自变量的下限和上限（此处指泊松比）
		% options.lowerLimit = 0.43;
		% options.upperLimit = 0.499;
		options.lowerLimit = 0.43;
		options.upperLimit = 0.499;

	%% by block
	elseif options.type == 2
		% 层号
		options.layer = 3;
		% 该层的 block 数
		options.nBlock = 21;
		% 待优化的块的 index
		options.blockIndexs = 11:14;
		% 基因算法参数
		options.nGeneration = 3;
		options.nPopulation = 3;
		% 基准值
		options.refval = 0.494;
		% 偏差度
		options.offset = 0.03;

		% default values
		% ----------------------------------------
		if strcmp(options.blockIndexs, 'all') || strcmp(options.blockIndexs, 'default')
			options.blockIndexs = 1:options.nBlock;
		end

	else
		error('config error!');
	end

end
