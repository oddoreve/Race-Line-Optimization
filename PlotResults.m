function PlotResults(track, car, d0, dWeighted, dParetoFast, dParetoFuel, dParetoBalanced, dFuel, dMinTime, JPareto, weightedJ)
% Define 9 distinct colors
colors = [
    0.00 0.45 0.74;  % Blue
    0.85 0.33 0.10;  % Orange
    0.93 0.69 0.13;  % Yellow
    0.49 0.18 0.56;  % Purple
    0.47 0.67 0.19;  % Green
    0.30 0.75 0.93;  % Cyan
    0.64 0.08 0.18;  % Dark red
    0.25 0.25 0.25;  % Dark gray
    0.90 0.40 0.70   % Pink
    ];
%% Figure 1: Race line comparison
figure('Name', 'Race Line Comparison');
hold on;
axis equal;
grid on;
% Close the track centerline
trackX = [track.x(:); track.x(1)];
trackY = [track.y(:); track.y(1)];
plot(trackX, trackY, 'w--', 'linew', 1.5);
% Track boundaries
leftX = track.x + track.nx*track.width/2;
leftY = track.y + track.ny*track.width/2;
rightX = track.x - track.nx*track.width/2;
rightY = track.y - track.ny*track.width/2;
[leftX, leftY] = CloseCurve(leftX, leftY);
[rightX, rightY] = CloseCurve(rightX, rightY);
plot(leftX, leftY, 'w:', 'linew', 1.2);
plot(rightX, rightY, 'w:', 'linew', 1.2);
% Centerline
plot(trackX, trackY, 'Color', [0.4 0.4 0.4], 'linew', 1.5);
% Generate optimized racing lines
dWeightedBalanced = dWeighted(3, :);
pWeighted = BuildPath(track, dWeightedBalanced);
pFast = BuildPath(track, dParetoFast);
pFuel = BuildPath(track, dParetoFuel);
pBalanced = BuildPath(track, dParetoBalanced);
pConstrained = BuildPath(track, dFuel);
pMinTime = BuildPath(track, dMinTime);
% Close all racing lines before plotting
[pWeightedX, pWeightedY] = CloseCurve(pWeighted(:,1), pWeighted(:,2));
[pFastX, pFastY] = CloseCurve(pFast(:,1), pFast(:,2));
[pFuelX, pFuelY] = CloseCurve(pFuel(:,1), pFuel(:,2));
[pBalancedX, pBalancedY] = CloseCurve(pBalanced(:,1), pBalanced(:,2));
[pConstrainedX, pConstrainedY] = CloseCurve(pConstrained(:,1), pConstrained(:,2));
[pMinTimeX, pMinTimeY] = CloseCurve(pMinTime(:,1), pMinTime(:,2));
plot(pWeightedX, pWeightedY, 'b', 'linew', 1.5);
plot(pFastX, pFastY, 'r', 'linew', 1.5);
plot(pFuelX, pFuelY, 'g', 'linew', 1.5);
plot(pBalancedX, pBalancedY, 'm', 'linew', 1.5);
plot(pConstrainedX, pConstrainedY, 'c', 'linew', 1.5);
plot(pMinTimeX, pMinTimeY, 'Color', [0.9 0.5 0], 'linew', 1.8);
xlabel('X position (m)');
ylabel('Y position (m)');
title('Comparison of Optimized Racing Lines');
legend('Centreline reference', 'Left track boundary', 'Right track boundary', 'Centreline', 'Weighted Sum (0.5/0.5)', 'Pareto Fastest', 'Pareto Minimum Fuel', 'Pareto Balanced', 'Minimum Fuel with Time Limit', 'Pure Minimum Lap Time', 'Location', 'bestoutside');
%% Figure 2: Trade-off
figure('Name', 'Lap time and fuel trade-off');
scatter(JPareto(:,1), JPareto(:,2), 35, 'filled');
hold on;
grid on;
scatter(weightedJ(:,1), weightedJ(:,2), 60, 'filled');
Jfast = EvaluateLine(dParetoFast, track, car);
Jfuel = EvaluateLine(dParetoFuel, track, car);
Jbalanced = EvaluateLine(dParetoBalanced, track, car);
Jconstrained = EvaluateLine(dFuel, track, car);
Jtime = EvaluateLine(dMinTime, track, car);
scatter(Jfast(1), Jfast(2), 100, 'r', 'filled');
scatter(Jfuel(1), Jfuel(2), 100, 'g', 'filled');
scatter(Jbalanced(1), Jbalanced(2), 100, 'm', 'filled');
scatter(Jconstrained(1), Jconstrained(2), 100, 'c', 'filled');
scatter(Jtime(1), Jtime(2), 120, 'w', 'filled');
xlabel('Lap time (s)');
ylabel('Fuel consumption (kg)');
title('Multi-objective Optimization and Comparison');
legend('Pareto Front', 'Weighted Sum Solutions', 'Pareto Fastest', 'Pareto Minimum Fuel', 'Pareto Balanced', 'Minimum Fuel with Time Limit', 'Pure Minimum Lap Time', 'Location', 'best');
%% Figure 3: Speed profile comparison
figure('Name', 'Speed Profile Comparison');
hold on;
grid on;
box on;
% Plot all five weighted-sum solutions
weightPairs = [
    0.9 0.1
    0.7 0.3
    0.5 0.5
    0.3 0.7
    0.1 0.9
    ];
for k = 1:size(dWeighted, 1)
    d = dWeighted(k, :);
    % Generate racing path
    path = BuildPath(track, d);
    % Calculate vehicle speed profile
    [v, ds, ~] = SpeedProfile(path, track, car);
    % Calculate distance along racing line
    distance = [0; cumsum(ds(1:end-1))];
    % Plot weighted-sum speed profile
    label = sprintf('Weighted Sum (%.1f/%.1f)', weightPairs(k,1), weightPairs(k,2));
    plot(distance, v, 'Color', colors(k,:), 'linew', 1.8, 'DisplayName', label);
end
% Other optimization methods
methods = {
    dParetoFast, 'Pareto Fastest'
    dParetoFuel, 'Pareto Minimum Fuel'
    dFuel, 'Minimum Fuel with Time Limit'
    dMinTime, 'Pure Minimum Lap Time'
    };
for k = 1:size(methods, 1)
    d = methods{k, 1};
    label = methods{k, 2};
    % Generate racing path
    path = BuildPath(track, d);
    % Calculate vehicle speed profile
    [v, ds, ~] = SpeedProfile(path, track, car);
    % Calculate distance along racing line
    distance = [0; cumsum(ds(1:end-1))];
    % Plot speed profile
    colorIndex = size(dWeighted, 1) + k;
    plot(distance, v, 'Color', colors(colorIndex,:), 'linew', 1.8, 'DisplayName', label);
end
% Graph formatting
xlabel('Distance along racing line (m)');
ylabel('Vehicle speed (m/s)');
title('Vehicle Speed Profiles - All Optimization Methods');
legend('show', 'Location', 'eastoutside');
end
%% Helper function: Close a plotted curve
function [xClosed, yClosed] = CloseCurve(x, y)
x = x(:);
y = y(:);
xClosed = [x; x(1)];
yClosed = [y; y(1)];
end