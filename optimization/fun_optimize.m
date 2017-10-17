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

	optimizeOpts.rin_mat = 'r_in_optimize.mat';
	optimizeOpts.type = cfg.type;
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
		% config includes layer, nBlock, blockIndexs, nGeneration, nPopulation, refval, offset
		% 当优化某一层的所有块时，只追踪该层的事件，其他层的事件对优化结果影响不大，去掉以节省时间
		nvar = length(cfg.blockIndexs);
		initPoisl = cfg.layer .* ones(cfg.nBlock,1);
		initPoisb = 1:cfg.nBlock;
		initPoisbl = cfg.refval .* ones(cfg.nBlock,1);
		upperLimit = min((1+cfg.offset)*cfg.refval, 0.499) .* ones(nvar,1);
		lowerLimit = max((1-cfg.offset)*cfg.refval, 0.42) .* ones(nvar,1);

		[obj.ray,obj.ncbnd,obj.cbnd,obj.ivray] = fun_select_rays(cfg.layer,rin.ray,rin.ncbnd,rin.cbnd,rin.ivray);
		save(optimizeOpts.rin_mat, '-struct', 'obj');

		target_fun = fun_partialMain2(mainOpts,optimizeOpts,initPoisl,initPoisb,initPoisbl,cfg.layer,cfg.blockIndexs);
		gaoutfun = @gaoutfun_stem3;
		options = optimoptions('ga','OutputFcn',gaoutfun,'Generations',cfg.nGeneration,'PopulationSize',cfg.nPopulation);
		[x, fval] = ga(target_fun, nvar, [],[],[],[], lowerLimit, upperLimit, [], options);
	end
end

% 依据层编号 layer，取出在该层内发生的事件对应的 ray
% 同时，挑选出相应的 ncbnd, cbnd, ivray
function [ray, ncbnd, cbnd, ivray] = fun_select_rays(layers, ray, ncbnd, cbnd, ivray)
	layers = min(layers):max(layers);
	grouped_cbnd = fun_group_cbnd(ncbnd, cbnd);

	ray_layers = fix(ray);
	indexs = [];
	for ii = 1:length(ray_layers)
	    ly = ray_layers(ii);
	    if ismember(ly, layers)
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
	end
	func = @wrapper;
end

% ga by block
function func = fun_partialMain2(mainOpts,optimizeOpts,initPoisl,initPoisb,initPoisbl,layer,blockIndexs)
	optimizeOpts.poisl = initPoisl;
	optimizeOpts.poisb = initPoisb;
    save('history_optimize.mat', 'layer', 'blockIndexs');
	function y = wrapper(iterPois)
		disp('Optimizing pois by block: ');
		fprintf('layer: %.0f\n', layer);
		disp('block pois: ');
		fprintf('%10.0f', blockIndexs); fprintf('\n');
		fprintf('%10.4f', iterPois); fprintf('\n');
		optimizeOpts.poisbl = initPoisbl;
		optimizeOpts.poisbl(blockIndexs) = iterPois;
		mainOpts.optimizeOpts = optimizeOpts;
		[RMS, CHI] = main(mainOpts);
		y = CHI;
	end
	func = @wrapper;
end

%% output function for ga

function [state,options,optchanged] = gaoutfun_stem3(options,state,flag)
	persistent hf populations scores h z;
	nGen = options.Generations;
	nPop = options.PopulationSize;
	curGen = state.Generation;
	optchanged = false;
	switch flag
	    case 'init'
	        hf = figure;
	        ax = gca;
	        [x, y] = meshgrid(0:nGen, 1:nPop);
	        z = zeros(nPop, nGen+1);
	        x = x(:)'; y = y(:)'; z = z(:)';
	        z((nPop*curGen+1):nPop*(curGen+1)) = state.Score';
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
            ss = size(populations,3);
            populations(:,:,curGen) = state.Population;
            scores(:,curGen) = state.Score;
	        % Update the plot.
	        z(nPop*curGen+1:nPop*(curGen+1)) = state.Score';
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
