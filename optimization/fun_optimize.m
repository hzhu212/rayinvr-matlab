% 通过优化算法寻找使得 CHI 最小的 pois 数组

function [x,fval] = fun_optimize(mainOptions)
	file_rin = fullfile(mainOptions.pathIn, 'r.in');
	[initRay, initPois] = fun_load_from_rin(file_rin);

	cfg = fun_get_config();

	% default ga options:
	% Generations: 100 * nvar
	% PopulationSize: {50} when numberOfVariables <= 5, {200} otherwise | {min(max(10*nvar,40),100)} for mixed-integer problems
	% options = gaoptimset('Generations', 10, 'PopulationSize', 20);

	% ga by layer
	if cfg.type == 1
		% config includeing layerIndexs, nGeneration, nPopulation, lowerLimit, upperLimit
		nvar = length(cfg.layerIndexs);
		layerIndexs = int32(cfg.layerIndexs);

		mainOptions.isPlot = false;
		target_fun = fun_partialMain1(mainOptions,initPois,layerIndexs);
		gaoutfun = @gaoutfun_stem3;
		options = optimoptions('ga','OutputFcn',gaoutfun,'Generations',cfg.nGeneration,'PopulationSize',cfg.nPopulation);
		[x, fval] = ga(target_fun, nvar, [],[],[],[],...
			lowerLimit*ones(nvar,1),upperLimit*ones(nvar,1),[],options);

	% ga by block
	elseif cfg.type == 2
		% config includeing layer, nBlock, blockIndexs, nGeneration, nPopulation, refval, offset
		% 当优化某一层的所有块时，只追踪该层的事件，其他层的事件对优化结果影响不大，去掉以节省时间
		ray = initRay(fix(initRay) == cfg.layer);
		nvar = cfg.nBlock;
		initPoisl = cfg.layer .* ones(nvar,1);
		initPoisb = 1:nvar;
		initPoisbl = cfg.refval * ones(nvar,1);
		upperLimit = min((1+cfg.offset)*cfg.refval, 0.499) * ones(nvar,1);
		lowerLimit = max((1-cfg.offset)*cfg.refval, 0.42) * ones(nvar,1);

		mainOptions.isPlot = false;
		target_fun = fun_partialMain2(mainOptions,initPoisl,initPoisb,initPoisbl,cfg.blockIndexs);
		gaoutfun = @gaoutfun_stem3;
		options = optimoptions('ga','OutputFcn',gaoutfun,'Generations',cfg.nGeneration,'PopulationSize',cfg.nPopulation);
		[x, fval] = ga(target_fun, nvar, [],[],[],[], lowerLimit, upperLimit, [], options);
	end

	% 依据层编号 layer，取出在该层内发生的事件对应的 ray
	% 同时，求出相应的 ncbnd, cbnd, ivray
	function [ray, ncbnd, cbnd, ivray] = fun_get_related_rays(layer, ray, ncbnd, cbnd, ivray)
		grouped_cbnd = fun_group_cbnd(ncbnd, cbnd);

		indexs = find(fix(ray) == layer);
		ray = ray(indexs);
		ncbnd = ncbnd(indexs);
		grouped_cbnd = grouped_cbnd(indexs);
		cbnd = fun_ungroup_cbnd(grouped_cbnd);
		ivray = ivray(indexs);

		% 将平坦数组 cbnd 转为按照 ncbnd 分组的 cell
		function grouped_cbnd = fun_group_cbnd(ncbnd, cbnd)
			total = 1
			grouped_cbnd = {};
			for ii = 1:length(ncbnd)
			    n = ncbnd(ii);
			    grouped_cbnd{ii} = cbnd(total:(total+n));
			    total = total + n + 1;
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
end

% ga by layer
function func = fun_partialMain1(mainOptions,initPois,layerIndexs)
	function y = wrapper(iterPois)
		disp('Optimizing pois by layer: ');
		fprintf('%10.0f', layerIndexs); fprintf('\n');
		fprintf('%10.4f', iterPois); fprintf('\n');
		curPois = POIS;
		curPois(layerIndexs) = iterPois;
		mainOptions.pois = curPois;
		[RMS, CHI] = main(mainOptions);
		y = CHI;
	end
	func = @wrapper;
end

% ga by block
function func = fun_partialMain2(mainOptions,initPoisl,initPoisb,initPoisbl,blockIndexs)
	function y = wrapper(iterPois)
		disp('Optimizing pois by block: ');
		fprintf('layer #: %.0f\n', initPoisl(1));
		fprintf('%10.0f', blockIndexs); fprintf('\n');
		fprintf('%10.4f', iterPois); fprintf('\n');
		curPoisbl = initPoisbl;
		curPoisbl(blockIndexs) = iterPois;
		mainOptions.poisl = initPoisl;
		mainOptions.poisb = initPoisb;
		mainOptions.poisbl = curPoisbl;
		[RMS, CHI] = main(mainOptions);
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
	        z(nPop*curGen+1:nPop*(curGen+1)) = state.Score';
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
    save('history_optimize.mat', 'populations', 'scores');
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
	        save('history_optimize.mat', 'populations', 'scores');
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
	        save('history_optimize.mat', 'populations', 'scores');
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
	        save('history_optimize.mat', 'populations', 'scores');
	    end
end
