clc;
clear;
close all;
rng(1); % Reproducible random seed for the genetic algorithm
%% 1. Create track and vehicle
track = CreateTrack();
car = CreateCar();
nvars = 24; % Number of lateral-offset control points
% Lateral offset bounds
maxOffset = track.width/2 - track.margin;
lb = -maxOffset*ones(1, nvars);
ub = maxOffset*ones(1, nvars);
d0 = zeros(1, nvars);
nonlcon = @(d) LineConstraints(d, track);
%% 2. Evaluate baseline: geometric centerline
Jbase = EvaluateLine(d0, track, car);
fprintf('\n====================================\n');
fprintf('BASELINE: CENTERLINE\n');
fprintf('====================================\n');
fprintf('Lap time: %.3f s\n',Jbase(1));
fprintf('Fuel consumption: %.5f kg\n',Jbase(2));
%% 3. METHOD 1: WEIGHTED-SUM OPTIMIZATION
fprintf('\n====================================\n');
fprintf('METHOD 1: WEIGHTED-SUM OPTIMIZATION\n');
fprintf('====================================\n');
% Different priorities for lap time and fuel
weights = [
    0.9 0.1
    0.7 0.3
    0.5 0.5
    0.3 0.7
    0.1 0.9];
% Reference values for normalization
Tref = Jbase(1);
Fref = Jbase(2);
optsLocal = optimoptions('fmincon', 'Algorithm', 'sqp', 'Display', 'iter', 'MaxIterations', 500, 'MaxFunctionEvaluations', 30000, 'ConstraintTolerance', 1e-5, 'OptimalityTolerance', 1e-5);
weightedD = zeros(size(weights, 1), nvars);
weightedJ = zeros(size(weights, 1), 2);
for k = 1:size(weights, 1)
    wT = weights(k, 1);
    wF = weights(k, 2);
    fprintf('\nWeights: Time = %.1f, Fuel = %.1f\n',wT,wF);
    obj = @(d) WeightedObjective(d, track, car, wT, wF, Tref, Fref);
    [dOpt, ~, exitflag] = fmincon(obj, d0, [], [], [], [], lb, ub, nonlcon, optsLocal);
    weightedD(k, :) = dOpt;
    weightedJ(k, :) = EvaluateLine(dOpt, track, car);
    fprintf('Lap time: %.3f s\n', weightedJ(k, 1));
    fprintf('Fuel: %.5f kg\n', weightedJ(k, 2));
    fprintf('Exit flag: %d\n', exitflag);
end
%% 4. METHOD 2: PARETO-FRONT OPTIMIZATION
fprintf('\n====================================\n');
fprintf('METHOD 2: PARETO-FRONT OPTIMIZATION\n');
fprintf('====================================\n');
objPareto = @(d) EvaluateLine(d, track, car);
optsGA = optimoptions('gamultiobj', 'PopulationSize', 100, 'MaxGenerations', 150, 'MaxStallGenerations', 40, 'FunctionTolerance', 1e-4, 'Display', 'iter', 'PlotFcn', []);
[dPareto, JPareto, exitflagGA, outputGA] = gamultiobj(objPareto, nvars, [], [], [], [], lb, ub, nonlcon, optsGA);
fprintf('\nPareto optimization completed.\n');
fprintf('Number of Pareto solutions: %d\n', size(JPareto, 1));
fprintf('GA exit flag: %d\n', exitflagGA);
%% 5. Select representative Pareto solutions
% Fastest Pareto solution
[~, idxFast] = min(JPareto(:, 1));
dParetoFast = dPareto(idxFast, :);
JParetoFast = JPareto(idxFast, :);
% Minimum-fuel Pareto solution
[~, idxFuel] = min(JPareto(:, 2));
dParetoFuel = dPareto(idxFuel, :);
JParetoFuel = JPareto(idxFuel, :);
% Balanced Pareto solution
% Normalize objectives before calculating distance
Tnorm = (JPareto(:, 1)-min(JPareto(:, 1)))/max(max(JPareto(:, 1))-min(JPareto(:, 1)), eps);
Fnorm = (JPareto(:, 2)-min(JPareto(:, 2)))/max(max(JPareto(:, 2))-min(JPareto(:, 2)), eps);
distance = sqrt(Tnorm.^2+Fnorm.^2);
[~, idxBalanced] = min(distance);
dParetoBalanced = dPareto(idxBalanced, :);
JParetoBalanced = JPareto(idxBalanced, :);
%% 6. METHOD 3: MINIMUM FUEL WITH LAP-TIME LIMIT
fprintf('\n====================================\n');
fprintf('METHOD 3: MINIMUM FUEL WITH TIME LIMIT\n');
fprintf('====================================\n');
% Allow 5% more time than the fastest Pareto solution
TminApprox = JParetoFast(1);
timeMargin = 0.05;
Tlimit = (1+timeMargin)*TminApprox;
fprintf('Lap-time limit: %.3f s\n',Tlimit);
objFuel = @(d) FuelObjective(d,track,car);
fuelConstraint = @(d) FuelTimeConstraints(d, track, car, Tlimit);
% Start from the fastest Pareto solution
[dFuel, ~, exitflagFuel] = fmincon(objFuel, dParetoFast, [], [], [], [], lb, ub, fuelConstraint, optsLocal);
Jfuel = EvaluateLine(dFuel, track, car);
fprintf('Optimized lap time: %.3f s\n', Jfuel(1));
fprintf('Optimized fuel: %.5f kg\n', Jfuel(2));
fprintf('Time limit: %.3f s\n', Tlimit);
fprintf('Exit flag: %d\n', exitflagFuel);
%% 7. METHOD 4: PURE MINIMUM LAP TIME
fprintf('\n====================================\n');
fprintf('METHOD 4: PURE MINIMUM LAP TIME\n');
fprintf('====================================\n');
objTime = @(d) LapTimeObjective(d,track,car);
% Start from the fastest Pareto solution
[dMinTime, ~, exitflagTime] = fmincon(objTime, dParetoFast, [], [], [], [], lb, ub, nonlcon, optsLocal);
JminTime = EvaluateLine(dMinTime, track, car);
fprintf('Minimum lap time: %.3f s\n', JminTime(1));
fprintf('Fuel consumed: %.5f kg\n', JminTime(2));
fprintf('Exit flag: %d\n', exitflagTime);
%% 8. Compare all methods
fprintf('\n====================================\n');
fprintf('FINAL COMPARISON\n');
fprintf('====================================\n');
CompareMethods(Jbase, weights, weightedJ, JPareto,idxFast,idxFuel, idxBalanced, Jfuel,JminTime);
%% 9. Plot racing lines and optimization results
PlotResults(track, car, d0, weightedD, dParetoFast, dParetoFuel, dParetoBalanced, dFuel, dMinTime, JPareto, weightedJ);
%% 10. Save all optimization data
save('RaceLineOptimizationResults.mat', 'track', 'car', 'Jbase', 'weights', 'weightedD', 'weightedJ', 'dPareto', 'JPareto', 'dParetoFast', 'dParetoFuel', 'dParetoBalanced', 'dFuel', 'Jfuel', 'Tlimit', 'dMinTime', 'JminTime', 'exitflagGA', 'outputGA', 'exitflagFuel', 'exitflagTime');
fprintf('\nAll results saved successfully.\n');