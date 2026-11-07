function J = WeightedObjective(d,track,car,wT,wF,Tref,Fref)
metrics = EvaluateLine(d,track,car);
T = metrics(1);
F = metrics(2);
J = wT*(T/Tref) + wF*(F/Fref);
end