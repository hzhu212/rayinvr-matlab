% 通过优化算法寻找使得 CHI 最小的 pois 数组

function [x,fval] = fun_optimize(mainOpts)
	mainOpts.inOptimize = true;
	file_rin = fullfile(mainOpts.pathIn, 'r.in');
	file_rin_m = fun_trans_rin2m(file_rin);
	file_rin_mat = fun_restore_rin_mat(file_rin_m);
	rin = load(file_rin_mat);
	cfg = fun_get_config();

	% default ga options:
	% Generations: 100 * nvar
	% PopulationSize: {50} when numberOfVariables <= 5, {200} otherwise | {min(max(10*nvar,40),100)} for mixed-integer problems
	% options = gaoptimset('Generations', 10, 'PopulationSize', 20);

	optimizeOpts.type = cfg.type;
	optimizeOpts.isPlot = cfg.isPlot;
	optimizeOpts.rin_mat = 'r_in_optimize.mat';
	if exist(optimizeOpts.rin_mat, 'file'), delete(optimizeOpts.rin_mat); end

	% ga by layer
	if cfg.type == 1
		% config includes layerIndexs, nGeneration, nPopulation, lowerLimit, upperLimit
		nvar = length(cfg.layerIndexs);
		layerIndexs = int32(cfg.layerIndexs);
		upperLimit = cfg.upperLimit .* ones(nvar,1);
		lowerLimit = cfg.lowerLimit .* ones(nvar,1);

		[obj.ray,obj.ncbnd,obj.cbnd,obj.ivray] = fun_select_rays(layerIndexs,rin.ray,rin.ncbnd,rin.cbnd,rin.ivray);
		save(optimizeOpts.rin_mat, '-struct', 'obj');

		target_fun = fun_partialMain1(mainOpts, optimizeOpts, rin.pois, layerIndexs);
		gaoutfun = @gaoutfun_stem3;
		options = optimoptions('ga','OutputFcn',gaoutfun,'Generations',cfg.nGeneration,'PopulationSize',cfg.nPopulation);
		[x, fval] = ga(target_fun, nvar, [],[],[],[], lowerLimit, upperLimit, [], options);

	% ga by block
	elseif cfg.type == 2
		% config includes poisl, poisb, nGeneration, nPopulation, poisbl, offset
		optimizeOpts.poisl = cfg.poisl;
		optimizeOpts.poisbCell = cfg.poisb;
		% 将分组存放在 cell 中的 poisb 串接成一个向量
		optimizeOpts.poisb = cat(2, cfg.poisb{:});

		% 优化算法要追踪的参数个数
		nvar = length(cfg.poisb);

		% 如果 poisbl 为单个值，则扩展为向量
		poisbl = cfg.poisbl;
		if length(poisbl) == 1
		    poisbl = poisbl * ones(1, nvar);
		end
		% 将 poisbl 的上下限限制在 0.250 到 0.499 之间
		upperLimit = poisbl + cfg.offset;
		lowerLimit = poisbl - cfg.offset;
		upperLimit(upperLimit > 0.499) = 0.499;
		lowerLimit(lowerLimit < 0.250) = 0.250;

		% % 当优化某一层的所有块时，只追踪该层的事件，其他层的事件对优化结果影响不大，去掉以节省时间
		% [obj.ray,obj.ncbnd,obj.cbnd,obj.ivray] = fun_select_rays(cfg.poisl,rin.ray,rin.ncbnd,rin.cbnd,rin.ivray);
		% save(optimizeOpts.rin_mat, '-struct', 'obj');

		target_fun = fun_partialMain2(mainOpts,optimizeOpts);
		gaoutfun = @gaoutfun_stem3;
		options = optimoptions('ga','OutputFcn',gaoutfun,'Generations',cfg.nGeneration,'PopulationSize',cfg.nPopulation);
		[x, fval] = ga(target_fun, nvar, [],[],[],[], lowerLimit, upperLimit, [], options);
	end
end

% 依据层编号 poisl，取出在该层内发生的事件对应的 ray
% 同时，挑选出相应的 ncbnd, cbnd, ivray
function [ray, ncbnd, cbnd, ivray] = fun_select_rays(poisl, ray, ncbnd, cbnd, ivray)
	trace_layers = min(poisl):max(poisl);
	if trace_layers(1)-1 > 1
	    trace_layers = [trace_layers(1)-1, trace_layers];
	end
	grouped_cbnd = fun_group_cbnd(ncbnd, cbnd);

	ray_layers = fix(ray);
	indexs = [];
	for ii = 1:length(ray_layers)
	    ly = ray_layers(ii);
	    if ismember(ly, trace_layers)
	        indexs = [indexs, ii];
	    end
	end

	ray = ray(indexs);
	ncbnd = ncbnd(indexs);
	grouped_cbnd = grouped_cbnd(indexs);
	cbnd = fun_ungroup_cbnd(grouped_cbnd);
	ivray = ivray(indexs);

	% 将平坦数组 cbnd 转为按照 ncbnd 分组的 cell
	function grouped_cbnd = fun_group_cbnd(ncbnd, cbnd)
		total = 1;
		grouped_cbnd = {};
		for ii = 1:length(ncbnd)
		    n = ncbnd(ii);
		    grouped_cbnd{ii} = cbnd(total:(total+n-1));
		    total = total + n;
		end
	end

	% 将分组后的 cbnd 转为平坦数组
	function cbnd = fun_ungroup_cbnd(grouped_cbnd)
		cbnd = [];
		for ii = 1:length(grouped_cbnd)
		    cbnd = [cbnd, grouped_cbnd{ii}];
		end
	end
end

% ga by layer
function func = fun_partialMain1(mainOpts, optimizeOpts, initPois, layerIndexs)
    save('history_optimize.mat', 'layerIndexs');
	function y = wrapper(iterPois)
		disp('Optimizing pois by layer: ');
		fprintf('%10.0f', layerIndexs); fprintf('\n');
		fprintf('%10.4f', iterPois); fprintf('\n');
		optimizeOpts.pois = initPois;
		optimizeOpts.pois(layerIndexs) = iterPois;
		mainOpts.optimizeOpts = optimizeOpts;
		[RMS, CHI] = main(mainOpts);
		y = CHI;
		if isempty(y), y = inf; end
		% 如果优化过程中仍需要绘图，则暂停一下等待绘图
		if optimizeOpts.isPlot
		    pause(0.1);
		end
	end
	func = @wrapper;
end

% ga by block
function func = fun_partialMain2(mainOpts,optimizeOpts)
	poisl = optimizeOpts.poisl; poisb = optimizeOpts.poisb; poisbCell = optimizeOpts.poisbCell;
    save('history_optimize.mat', 'poisl', 'poisb', 'poisbCell');
	function y = wrapper(iterPois)
		% 将分组存放的 poisbl 展开成与 poisl 相同的长度
		poisbl = [];
		for ii = 1:length(iterPois)
			groupSize = length(optimizeOpts.poisbCell{ii});
		    poisbl = [poisbl, iterPois(ii).*ones(1, groupSize)];
		end
		optimizeOpts.poisbl = poisbl;
		disp('Optimizing pois by block: ');
		fprintf('poisl: '); fprintf('%6.0f,', optimizeOpts.poisl); fprintf('\n');
		fprintf('poisb: '); fprintf('%6.0f,', optimizeOpts.poisb); fprintf('\n');
		fprintf('poisbl:'); fprintf('%6.3f,', optimizeOpts.poisbl); fprintf('\n');
		mainOpts.optimizeOpts = optimizeOpts;
		[RMS, CHI] = main(mainOpts);
		y = CHI;
		if isempty(y), y = inf; end
		% 如果优化过程中仍需要绘图，则暂停一下等待绘图
		if optimizeOpts.isPlot
		    pause(0.1);
		end
	end
	func = @wrapper;
end

%% output function for ga

function [state,options,optchanged] = gaoutfun_stem3(options,state,flag)
	persistent hf populations scores h z;
	nGen = options.Generations;
	nPop = options.PopulationSize;
	% Generation 索引默认从 0 开始，加 1 方便索引
	curGen = state.Generation + 1;
	optchanged = false;
	switch flag
	    case 'init'
	        hf = figure;
	        ax = gca;
	        [x, y] = meshgrid(0:nGen, 1:nPop);
	        z = zeros(nPop, nGen+1);
	        x = x(:)'; y = y(:)'; z = z(:)';
	        z((nPop*(curGen-1)+1):nPop*curGen) = state.Score';
	        h = stem3(ax, x, y, z, 'Marker','s','MarkerEdgeColor','r','MarkerFaceColor','g');
	        h.ZDataSource = 'z';
	        ax.XTick = 0:nGen;
	        ax.YTick = 1:nPop;
	        xlabel(ax, 'X - Generation');
	        ylabel(ax, 'Y - Population');
	        zlabel(ax, 'Z - Score');
	        pause(0.1);
	        populations(:,:,1) = state.Population;
	        scores(:,1) = state.Score;
	    case 'iter'
	        % Update the history
            populations(:,:,curGen) = state.Population;
            scores(:,curGen) = state.Score;
	        % Update the plot.
	        z(nPop*(curGen-1)+1:nPop*curGen) = state.Score';
	        refreshdata(h, 'caller');
	        figure(hf);
	        pause(0.1);
	    case 'done'
	        % save('history_optimize.mat', 'populations', 'scores');
	    end
    save('history_optimize.mat', '-append', 'populations', 'scores');
end

function [state,options,optchanged] = gaoutfun_surf(options,state,flag)
	persistent hf populations scores h z;
	nGen = options.Generations;
	nPop = options.PopulationSize;
	curGen = state.Generation + 1;
	optchanged = false;
	switch flag
	    case 'init'
	        hf = figure;
	        ax = gca;
	        [x, y] = meshgrid(0:nGen, 1:nPop);
	        z = zeros(nPop, nGen+1);
	        z(:,curGen) = state.Score;
	        h = surf(ax, x, y, z);
	        h.ZDataSource = 'z';
	        ax.XTick = 0:nGen;
	        ax.YTick = 1:nPop;
	        xlabel(ax, 'X - Generation');
	        ylabel(ax, 'Y - Population');
	        zlabel(ax, 'Z - Score');
	        pause(0.1);
	        populations(:,:,1) = state.Population;
	        scores(:,1) = state.Score;
	    case 'iter'
	        % Update the history.
            populations(:,:,curGen) = state.Population;
	        scores(:,curGen) = state.Score;
	        % Update the plot.
	        z(:,curGen) = state.Score;
	        refreshdata(h, 'caller');
	        figure(hf);
	        pause(0.1);
	    case 'done'
	        save('history_optimize.mat', '-append', 'populations', 'scores');
	    end
end

function [state,options,optchanged] = gaoutfun_mesh(options,state,flag)
	persistent hf populations scores h z;
	nGen = options.Generations;
	nPop = options.PopulationSize;
	curGen = state.Generation + 1;
	optchanged = false;
	switch flag
	    case 'init'
	        hf = figure;
	        ax = gca;
	        [x, y] = meshgrid(0:nGen, 1:nPop);
	        z = zeros(nPop, nGen+1);
	        z(:,curGen) = state.Score;
	        h = mesh(ax, x, y, z);
	        h.ZDataSource = 'z';
	        ax.XTick = 0:nGen;
	        ax.YTick = 1:nPop;
	        xlabel(ax, 'X - Generation');
	        ylabel(ax, 'Y - Population');
	        zlabel(ax, 'Z - Score');
	        pause(0.1);
	        populations(:,:,1) = state.Population;
	        scores(:,1) = state.Score;
	    case 'iter'
	        % Update the history.
            populations(:,:,curGen) = state.Population;
	        scores(:,curGen) = state.Score;
	        % Update the plot.
	        z(:,curGen) = state.Score;
	        refreshdata(h, 'caller');
	        figure(hf);
	        pause(0.1);
	    case 'done'
	        save('history_optimize.mat', '-append', 'populations', 'scores');
	    end
end

function [state,options,optchanged] = gaoutfun_bar3(options,state,flag)
	persistent hf ax populations scores h y;
	nGen = options.Generations;
	nPop = options.PopulationSize;
	curGen = state.Generation + 1;
	optchanged = false;
	switch flag
	    case 'init'
	        hf = figure;
	        ax = gca;
	        y = zeros(nPop, nGen+1);
	        y(:,curGen) = state.Score;
	        h = bar3(ax, y);
	        pause(0.1);
	        populations(:,:,1) = state.Population;
	        scores(:,1) = state.Score;
	    case 'iter'
	        % Update the history
            populations(:,:,curGen) = state.Population;
	        scores(:,curGen) = state.Score;
	        y(:,curGen) = state.Score;
	        h = bar3(ax, y);
	        figure(hf);
	        pause(0.1);
	    case 'done'
	        xlabel(ax, 'X - Generation');
	        ylabel(ax, 'Y - Population');
	        zlabel(ax, 'Z - Score');
	        save('history_optimize.mat', '-append', 'populations', 'scores');
	    end
end
