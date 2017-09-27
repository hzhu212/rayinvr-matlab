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
	options = optimoptions('ga', 'OutputFcn', @gaoutfun, 'Generations', 10, 'PopulationSize', 20);
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

% output function for ga
function [state,options,optchanged] = gaoutfun(options,state,flag)
	persistent hf ax history h x y z;
	nGen = options.Generations;
	nPop = options.PopulationSize;
	curGen = state.Generation + 1;
	optchanged = false;
	switch flag
	    case 'init'
	        hf = figure;
	        ax = gca;
	        ax.XLim = [0 nGen];
	        ax.YLim = [0 nPop];
	        xlabel('X - Generation');
	        ylabel('Y - Population');
	        zlabel('Z - Score');
	        % x = curGen*ones(1,nPop);
	        % y = 1:nPop;
	        % z = state.Score';
	        % h = scatter3(ax, x, y, z);
	        y = zeros(nPop, nGen);
	        y(:,curGen) = state.Score;
	        h = bar3(ax, y);
	        pause(0.1);
	        history(:,:,1) = state.Population;
	        assignin('base','gapopulationhistory',history);
	    case 'iter'
	        % Update the history every 10 generations.
	        if rem(state.Generation,10) == 0
	            ss = size(history,3);
	            history(:,:,ss+1) = state.Population;
	            assignin('base','gapopulationhistory',history);
	        end
	        % % Find the best objective function, and stop if it is low.
	        % ibest = state.Best(end);
	        % ibest = find(state.Score == ibest,1,'last');
	        % bestx = state.Population(ibest,:);
	        % bestf = gaintobj(bestx);
	        % if bestf <= 0.1
	        %     state.StopFlag = 'y';
	        %     disp('Got below 0.1')
	        % end
	        % Update the plot.
	        % [x, y] = meshgrid(1:curGen, 1:nPop);
	        % z = [h.ZData', state.Score];
	        % h = scatter3(ax, x, y, z);
	        % y = [y, state.Score];
	        % h = bar3(ax, y);
	        y(:,curGen) = state.Score;
	        % refreshdata(h, 'caller');
	        h = bar3(ax, y);
	        figure(hf);
	        pause(0.1);
	        % Update the fraction of mutation and crossover after 25 generations.
	        % if state.Generation == 25
	        %     options.CrossoverFraction = 0.8;
	        %     optchanged = true;
	        % end
	    case 'done'
	        % Include the final population in the history.
	        ss = size(history,3);
	        history(:,:,ss+1) = state.Population;
	        assignin('base','gapopulationhistory',history);
	        xlabel('X - Generation');
	        ylabel('Y - Population');
	        zlabel('Z - Score');
	    end
end
