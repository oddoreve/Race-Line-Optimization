function [c, ceq] = FuelTimeConstraints(d, track, car, Tlimit)
[cPath, ceq] = LineConstraints(d, track);
metrics = EvaluateLine(d, track, car);
T = metrics(1);
% Lap-time constraint
cTime = T-Tlimit;
c = [cPath(:); cTime];
end