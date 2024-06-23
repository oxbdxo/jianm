% 初始化参数
D_initial = 500; % 初始污垢量, 例如 500 克
W = 10; % 每次洗涤使用的水量, 例如 10 升
threshold = D_initial * 0.01; % 污垢残留阈值
maxWashes = 10000; % 设置一个最大洗涤次数以避免无限循环
% 洗涤过程
remainingDirt = D_initial; % 剩余污垢量
washCount = 0; % 洗涤次数
current_a = 0.8; % 初始溶解度
while remainingDirt > threshold && washCount < maxWashes
    washCount = washCount + 1;
    remainingDirt = remainingDirt - W * current_a;
    current_a = 0.5 * current_a; % 更新溶解度
    if current_a < 0.01
        current_a = 0.01; % 防止溶解度过低
    end
end
% 输出结果
if washCount == maxWashes
    fprintf('Reached maximum wash count without meeting dirt removal criteria.\n');
else
    fprintf('Optimal number of washes: %d\n', washCount);
    fprintf('Water used per wash: %d liters\n', W);
    fprintf('Remaining dirt: %.2f grams\n', remainingDirt);
end

% 初始化参数
D_initial = 500; % 初始污垢量, 例如 500 克
W = 10; % 每次洗涤使用的水量, 例如 10 升
threshold = D_initial * 0.001; % 污垢残留阈值为初始污垢量的千分之一
maxWashes = 10000; % 设置一个最大洗涤次数以避免无限循环
% 洗涤过程
remainingDirt = D_initial; % 剩余污垢量
washCount = 0; % 洗涤次数
current_a = 0.8; % 初始溶解度
while remainingDirt > threshold && washCount < maxWashes
    washCount = washCount + 1;
    remainingDirt = remainingDirt - W * current_a;
    current_a = 0.5 * current_a; % 更新溶解度
    if current_a < 0.01
        current_a = 0.01; % 防止溶解度过低
    end
end
% 输出结果
if washCount == maxWashes
    fprintf('Reached maximum wash count without meeting dirt removal criteria.\n');
else
    fprintf('Optimal number of washes: %d\n', washCount);
    fprintf('Water used per wash: %d liters\n', W);
    fprintf('Remaining dirt: %.2f grams\n', remainingDirt);
end

% 读取数据
opts = detectImportOptions('C:\Users\l\Desktop\A题附件\附件1 每件衣服的污染物数量表.xlsx');
opts.VariableNamingRule = 'preserve';
dirt = readtable('C:\Users\l\Desktop\A题附件\附件1 每件衣服的污染物数量表.xlsx', opts);
opts = detectImportOptions('C:\Users\l\Desktop\A题附件\附件2 洗涤效果及单价表.xlsx');
opts.VariableNamingRule = 'preserve';
detergents = readtable('C:\Users\l\Desktop\A题附件\附件2 洗涤效果及单价表.xlsx', opts);
 
% 获取洗涤剂价格
cost = detergents{:, end};
% 获取洗涤剂的污渍溶解度
detergentEfficacy = detergents{:, 2:end-1};
% 衣服的数量和洗涤剂的数量
numClothes = size(dirt, 1); 
numDetergents = size(detergents, 1);
% 溶解度阈值
efficacyThreshold = 0.05; % 可以根据需要调整
% 定义决策变量
x = optimvar('x', numClothes, numDetergents, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);
% 目标函数：最小化总成本
costMatrix = repmat(cost', numClothes, 1);
totalCost = sum(sum(x .* costMatrix));
% 创建优化问题
prob = optimproblem('Objective', totalCost);
% 约束：每件衣服只能使用一种洗涤剂
for i = 1:numClothes
    prob.Constraints.(['consCloth' num2str(i)]) = sum(x(i, :)) == 1;
end
% 约束：每种污渍的溶解度总和超过阈值
for i = 1:numClothes
    for j = 1:size(dirt, 2) - 1 % 排除第一列（衣服编号）
        prob.Constraints.(['consDirt' num2str(i) '_' num2str(j)]) = sum(x(i, :) .* detergentEfficacy(:, j)') >= efficacyThreshold * dirt{i, j+1};
    end
end
% 求解优化问题
[sol, fval, exitflag, output] = solve(prob);
% 输出解决方案
fprintf('Total cost: %f\n', fval);
% 假设每次洗涤的水量
W = 0.05; % 例如，每次洗涤使用0.05吨水
% 计算总水费
totalWaterCost = W * 3.8 * numClothes; % 每件衣服洗涤一次
% 计算总成本（洗涤剂成本 + 水费）
totalCost = fval + totalWaterCost;
% 输出总成本
fprintf('Total cost including water: %f\n', totalCost);

% 读取衣服材料和污染物数据
opts = detectImportOptions('C:\Users\l\Desktop\A题附件\附件3 服装材料及污染物数量表.xlsx');
opts.VariableNamingRule = 'preserve';
clothesData = readtable('C:\Users\l\Desktop\A题附件\附件3 服装材料及污染物数量表.xlsx', opts);
% 读取混洗限制数据
opts = detectImportOptions('C:\Users\l\Desktop\A题附件\附件4 混合使用不同材料洗涤衣物的限制.xlsx', 'ReadRowNames', true);
opts.VariableNamingRule = 'preserve';
mixingLimits = readtable('C:\Users\l\Desktop\A题附件\附件4 混合使用不同材料洗涤衣物的限制.xlsx', opts);
% 初始化决策变量：每个洗涤组合的衣服
numClothes = size(clothesData, 1);
washGroups = optimvar('washGroups', numClothes, numClothes, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);
% 目标函数：最小化洗涤组合的数量（简化模型）
totalWashes = sum(sum(washGroups));
% 创建优化问题
prob = optimproblem('Objective', totalWashes);
% 添加约束
% 每件衣服至少在一个洗涤组合中
for i = 1:numClothes
    prob.Constraints.(['consCloth' num2str(i)]) = sum(washGroups(i, :)) >= 1;
end
% 混洗限制
for i = 1:numClothes
    for j = 1:numClothes
        if i ~= j
            material_i = clothesData{i, '材料'};
            material_j = clothesData{j, '材料'};
            % 检查混洗限制
            if mixingLimits{material_i, material_j + 1} == '×' % 确保索引在表的维度内
                prob.Constraints.(['consMix' num2str(i) '_' num2str(j)]) = washGroups(i, j) == 0;
            end
        end
    end
end
% 求解优化问题
[sol, fval, exitflag, output] = solve(prob);
% 输出解决方案
fprintf('Total number of washes: %f\n', fval);
