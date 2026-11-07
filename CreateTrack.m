function track = CreateTrack()
N = 300;
theta = linspace(0, 2*pi, N+1)';
theta(end) = [];
% Synthetic irregular closed track
radiusX = 60 + 7*sin(3*theta) + 3*cos(5*theta);
radiusY = 40 + 5*cos(2*theta) + 2*sin(4*theta);
x = radiusX.*cos(theta);
y = radiusY.*sin(theta);
track.x = x;
track.y = y;
track.N = N;
track.width = 10; % Total track width (m)
track.margin = 1.5; % Vehicle/safety margin (m)
% Approximate track normals
dx = circshift(x, -1) - circshift(x, 1);
dy = circshift(y, -1) - circshift(y, 1);
tangentLength = sqrt(dx.^2+dy.^2);
track.nx = -dy./tangentLength;
track.ny = dx./tangentLength;
end