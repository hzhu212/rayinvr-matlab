%% 优化算法参数配置

% 待优化的泊松比在 pois 数组中的 index
indexs = 2:10;

% 基因算法代数
nGeneration = 10;

% 每代的个体数
nPopulation = 70;

% 待优化的自变量的下限和上限（此处指泊松比）
lowerLimit = 0.43;
upperLimit = 0.499;
