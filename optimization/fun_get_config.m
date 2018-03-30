%% 优化算法参数配置

function options = fun_get_config()

	% 优化过程中是否绘图，如是，则每个个体均绘图
	options.isPlot = false;
	% 优化所有层与优化一层内的所有块分开讨论
	options.type = 2;

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
		% 层号，从 1 开始，第 1 层为海水

		% poisl 和 poisb 分别指定要优化的泊松比所在的层编号和块编号。
		% 二者所包含的元素个数必须相等，即两者 flatten 之后必须等长。
		% poisb 采用了 cell 存储，而非数组，这是为了支持在内部分组，位于同一个内部数组
		% 的块共享同一个泊松比，这样可以尽可能减少遗传算法的参数，加快速度（由于深度节点
		% 与速度节点设置的问题，很多块变得非常狭窄，没必要独占一个优化参数）。
		options.poisl = [2,2,2,2,2,2,2];
		options.poisb = {[12,13],[14,15],[16,17],18};

		% poisbl 的基准值。与 poisb 形状相同，即为每个分组分配一个泊松比，如果为标量，则为所有组赋同一个值
		options.poisbl = 0.4852;
		% poisbl 的偏差范围，优化变量的上下限将被限制在 poisbl +/- offset 范围内。与 poisbl 形状相同，或者是一个标量
		options.offset = 0.015;

		% 基因算法参数
		options.nGeneration = 2;
		options.nPopulation = 2;

	else
		error('config error!');
	end

end
