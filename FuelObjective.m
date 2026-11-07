function F = FuelObjective(d, track, car)
metrics = EvaluateLine(d, track, car);
F = metrics(2);
end