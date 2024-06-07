D_initial = 500;
W = 10;
threshold = D_initial * 0.01;
maxWashes = 10000;
remainingDirt = D_initial;
washCount = 0;
current_a = 0.8;
while remainingDirt > threshold && washCount < maxWashes
    washCount = washCount + 1;
    remainingDirt = remainingDirt - W * current_a;
    current_a = 0.5 * current_a;
    if current_a < 0.01
        current_a = 0.01;
    end
end
if washCount == maxWashes
    fprintf('Reached maximum wash count without meeting dirt removal criteria.\n');
else
    fprintf('Optimal number of washes: %d\n', washCount);
    fprintf('Water used per wash: %d liters\n', W);
    fprintf('Remaining dirt: %.2f grams\n', remainingDirt);
end

D_initial = 500; 
W = 10; 
threshold = D_initial * 0.001;
maxWashes = 10000; 
remainingDirt = D_initial;
washCount = 0;
current_a = 0.8;
while remainingDirt > threshold && washCount < maxWashes
    washCount = washCount + 1;
    remainingDirt = remainingDirt - W * current_a;
    current_a = 0.5 * current_a;
    if current_a < 0.01
        current_a = 0.01;
    end
end
if washCount == maxWashes
    fprintf('Reached maximum wash count without meeting dirt removal criteria.\n');
else
    fprintf('Optimal number of washes: %d\n', washCount);
    fprintf('Water used per wash: %d liters\n', W);
    fprintf('Remaining dirt: %.2f grams\n', remainingDirt);
end

opts = detectImportOptions('C:\Users\l\Desktop\A题附件\附件1 每件衣服的污染物数量表.xlsx');
opts.VariableNamingRule = 'preserve';
dirt = readtable('C:\Users\l\Desktop\A题附件\附件1 每件衣服的污染物数量表.xlsx', opts);
opts = detectImportOptions('C:\Users\l\Desktop\A题附件\附件2 洗涤效果及单价表.xlsx');
opts.VariableNamingRule = 'preserve';
detergents = readtable('C:\Users\l\Desktop\A题附件\附件2 洗涤效果及单价表.xlsx', opts);
 
cost = detergents{:, end};
detergentEfficacy = detergents{:, 2:end-1};
numClothes = size(dirt, 1); 
numDetergents = size(detergents, 1);
efficacyThreshold = 0.05;
x = optimvar('x', numClothes, numDetergents, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);
costMatrix = repmat(cost', numClothes, 1);
totalCost = sum(sum(x .* costMatrix));
prob = optimproblem('Objective', totalCost);
for i = 1:numClothes
    prob.Constraints.(['consCloth' num2str(i)]) = sum(x(i, :)) == 1;
end
for i = 1:numClothes
    for j = 1:size(dirt, 2) - 1
        prob.Constraints.(['consDirt' num2str(i) '_' num2str(j)]) = sum(x(i, :) .* detergentEfficacy(:, j)') >= efficacyThreshold * dirt{i, j+1};
    end
end
[sol, fval, exitflag, output] = solve(prob);
fprintf('Total cost: %f\n', fval);
W = 0.05;
totalWaterCost = W * 3.8 * numClothes;
totalCost = fval + totalWaterCost;
fprintf('Total cost including water: %f\n', totalCost);

opts = detectImportOptions('C:\Users\l\Desktop\A题附件\附件3 服装材料及污染物数量表.xlsx');
opts.VariableNamingRule = 'preserve';
clothesData = readtable('C:\Users\l\Desktop\A题附件\附件3 服装材料及污染物数量表.xlsx', opts);
opts = detectImportOptions('C:\Users\l\Desktop\A题附件\附件4 混合使用不同材料洗涤衣物的限制.xlsx', 'ReadRowNames', true);
opts.VariableNamingRule = 'preserve';
mixingLimits = readtable('C:\Users\l\Desktop\A题附件\附件4 混合使用不同材料洗涤衣物的限制.xlsx', opts);
numClothes = size(clothesData, 1);
washGroups = optimvar('washGroups', numClothes, numClothes, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);
totalWashes = sum(sum(washGroups));
prob = optimproblem('Objective', totalWashes);
for i = 1:numClothes
    prob.Constraints.(['consCloth' num2str(i)]) = sum(washGroups(i, :)) >= 1;
end
for i = 1:numClothes
    for j = 1:numClothes
        if i ~= j
            material_i = clothesData{i, '材料'};
            material_j = clothesData{j, '材料'};
            if mixingLimits{material_i, material_j + 1} == '×'
                prob.Constraints.(['consMix' num2str(i) '_' num2str(j)]) = washGroups(i, j) == 0;
            end
        end
    end
end
[sol, fval, exitflag, output] = solve(prob);
fprintf('Total number of washes: %f\n', fval);