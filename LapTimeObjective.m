function T = LapTimeObjective(d, track, car)
metrics = EvaluateLine(d, track, car);
T = metrics(1);
end