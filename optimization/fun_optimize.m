% 通过优化算法寻找使得 CHI 最小的 pois 数组

function [x,fval] = fun_optimize(mainOptions)
	% load indexs, nGeneration, nPopulation, lowerLimit, upperLimit
	run('config.m');
	if isempty(nGeneration) || ~nGeneration, nGeneration = 10; end
	if isempty(nPopulation) || ~nPopulation, nPopulation = 20; end

	nvar = length(indexs);
	file_rin = fullfile(mainOptions.pathIn, 'r.in');
	POIS = fun_init_pois(file_rin);
	INDEXS = int32(indexs);

	mainOptions.isPlot = false;
	target_fun = fun_partialMain(mainOptions,POIS,INDEXS);

	% default options:
	% Generations: 100 * nvar
	% PopulationSize: {50} when numberOfVariables <= 5, {200} otherwise | {min(max(10*nvar,40),100)} for mixed-integer problems
	% options = gaoptimset('Generations', 10, 'PopulationSize', 20);
	gaoutfun = @gaoutfun_stem3;
	options = optimoptions('ga','OutputFcn',gaoutfun,'Generations',nGeneration,'PopulationSize',nPopulation);
	[x, fval] = ga(target_fun, nvar, [],[],[],[],...
		lowerLimit*ones(nvar,1),upperLimit*ones(nvar,1),[],options);
end

function func = fun_partialMain(mainOptions,POIS,INDEXS)
	function y = wrapper(iterPois)
		disp('Optimizing pois: ');
		fprintf('%10.0f', INDEXS); fprintf('\n');
		fprintf('%10.4f', iterPois); fprintf('\n');
		curPois = POIS;
		curPois(INDEXS) = iterPois;
		mainOptions.pois = curPois;
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
	        save('history_optimize.mat', 'populations', 'scores');
	    end
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
