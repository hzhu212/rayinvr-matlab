% 通过优化算法寻找使得 CHI 最小的 pois 数组

function [x,fval] = fun_optimize(mainOptions)
	file_rin = fullfile(mainOptions.pathIn, 'r.in');
	pois = fun_init_pois(file_rin);
	% 只对前若干层应用基因算法，提高计算效率
	nvarsMax = length(pois);
	nvar = min(nvarsMax, 2);

	mainOptions.isPlot = false;
	target_fun = fun_partialMain(mainOptions);
	% [x, fval] = fminunc(target_fun, pois);

	% default options:
	% Generations: 100 * nvar
	% PopulationSize: {50} when numberOfVariables <= 5, {200} otherwise | {min(max(10*nvar,40),100)} for mixed-integer problems
	% options = gaoptimset('Generations', 10, 'PopulationSize', 20);
	gaoutfun = @gaoutfun_bar3;
	options = optimoptions('ga', 'OutputFcn', gaoutfun, 'Generations', 3, 'PopulationSize', 2);
	[x, fval] = ga(target_fun, nvar, [],[],[],[],zeros(nvar,1),ones(nvar,1)*0.5,[],options);
end

function func = fun_partialMain(mainOptions)
	function y = wrapper(pois)
		mainOptions.pois = pois;
		[RMS, CHI] = main(mainOptions);
		y = CHI;
	end

	func = @wrapper;
end

%% output function for ga

function [state,options,optchanged] = gaoutfun_stem3(options,state,flag)
	persistent hf history h z;
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
	        h = stem3(ax, x, y, z, 'Marker','s','MarkerEdgeColor','m','MarkerFaceColor','g');
	        h.ZDataSource = 'z';
	        ax.XTick = 0:nGen;
	        ax.YTick = 1:nPop;
	        xlabel(ax, 'X - Generation');
	        ylabel(ax, 'Y - Population');
	        zlabel(ax, 'Z - Score');
	        pause(0.1);
	        history(:,:,1) = state.Population;
	        assignin('base','gapopulationhistory',history);
	    case 'iter'
	        % Update the history every 10 generations.
            ss = size(history,3);
            history(:,:,ss+1) = state.Population;
            assignin('base','gapopulationhistory',history);
	        % Update the plot.
	        z(nPop*curGen+1:nPop*(curGen+1)) = state.Score';
	        refreshdata(h, 'caller');
	        figure(hf);
	        pause(0.1);
	    case 'done'
	        % Include the final population in the history.
	    end
end

function [state,options,optchanged] = gaoutfun_surf(options,state,flag)
	persistent hf history h z;
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
	        history(:,:,1) = state.Population;
	        assignin('base','gapopulationhistory',history);
	    case 'iter'
	        % Update the history every 10 generations.
            ss = size(history,3);
            history(:,:,ss+1) = state.Population;
            assignin('base','gapopulationhistory',history);
	        % Update the plot.
	        z(:,curGen) = state.Score;
	        refreshdata(h, 'caller');
	        figure(hf);
	        pause(0.1);
	    case 'done'
	        % Include the final population in the history.
	    end
end

function [state,options,optchanged] = gaoutfun_mesh(options,state,flag)
	persistent hf history h z;
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
	        history(:,:,1) = state.Population;
	        assignin('base','gapopulationhistory',history);
	    case 'iter'
	        % Update the history every 10 generations.
            ss = size(history,3);
            history(:,:,ss+1) = state.Population;
            assignin('base','gapopulationhistory',history);
	        % Update the plot.
	        z(:,curGen) = state.Score;
	        refreshdata(h, 'caller');
	        figure(hf);
	        pause(0.1);
	    case 'done'
	        % Include the final population in the history.
	    end
end

function [state,options,optchanged] = gaoutfun_bar3(options,state,flag)
	persistent hf ax history h x y z;
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
	        ax.XLim = [0 nGen];
	        ax.YLim = [0 nPop];
	        xlabel(ax, 'X - Generation');
	        ylabel(ax, 'Y - Population');
	        zlabel(ax, 'Z - Score');
	        pause(0.1);
	        history(:,:,1) = state.Population;
	        assignin('base','gapopulationhistory',history);
	    case 'iter'
	        % Update the history every 10 generations.
            ss = size(history,3);
            history(:,:,ss+1) = state.Population;
            assignin('base','gapopulationhistory',history);
	        y(:,curGen) = state.Score;
	        h = bar3(ax, y);
	        figure(hf);
	        pause(0.1);
	    case 'done'
	        % Include the final population in the history.
	        xlabel(ax, 'X - Generation');
	        ylabel(ax, 'Y - Population');
	        zlabel(ax, 'Z - Score');
	    end
end
