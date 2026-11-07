function path = BuildPath(track, d)
N = track.N;
nCtrl = numel(d);
% Periodic interpolation of control-point offsets
controlPosition = linspace(1, N, nCtrl+1);
dExtended = [d(:); d(1)];
queryPosition = (1: N)';
lateralOffset = interp1(controlPosition, dExtended, queryPosition, 'pchip');
% Construct racing line
xPath = track.x + lateralOffset.*track.nx;
yPath = track.y + lateralOffset.*track.ny;
path = [xPath, yPath];
end