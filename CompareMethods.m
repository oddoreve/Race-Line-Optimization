function CompareMethods(Jbase, weights, weightedJ, JPareto, idxFast, idxFuel, idxBalanced, Jfuel, JminTime)
% Build result matrix
results = [
    weightedJ
    JPareto(idxFast,:)
    JPareto(idxFuel,:)
    JPareto(idxBalanced,:)
    Jfuel
    JminTime];
% Method labels
methodNames = [
    "Weighted Sum"
    "Weighted Sum"
    "Weighted Sum"
    "Weighted Sum" 
    "Weighted Sum" 
    "Pareto - Fastest" 
    "Pareto - Minimum Fuel" 
    "Pareto - Balanced" 
    "Minimum Fuel with Time Limit" 
    "Pure Minimum Lap Time"];
% Weight descriptions
weightLabels = strings(size(methodNames));
for k = 1:size(weights, 1)
    weightLabels(k) = sprintf('Time %.1f / Fuel %.1f', weights(k, 1), weights(k, 2));
end
weightLabels(6:10) = "-";
lapTime = results(:, 1);
fuel = results(:, 2);
% Percentage reduction relative to baseline
timeImprovement = (Jbase(1)-lapTime)/Jbase(1)*100;
fuelImprovement = (Jbase(2)-fuel)/Jbase(2)*100;
comparisonTable = table(methodNames, weightLabels, lapTime, fuel, timeImprovement,fuelImprovement, 'VariableNames', {'Method', 'Weights', 'LapTime_s', 'Fuel_kg', 'TimeReduction_pct', 'FuelReduction_pct'});
disp(comparisonTable);
% Save results
writetable(comparisonTable, 'methodComparison.csv');
fprintf('\nComparison table saved as methodComparison.csv\n');
end