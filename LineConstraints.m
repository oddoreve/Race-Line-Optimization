function [c, ceq] = LineConstraints(d, track)
maxStep = 1.5; % Maximum offset change between controls (m)
dNext = circshift(d(:), -1);
c = abs(dNext-d(:)) - maxStep;
ceq = [];
end