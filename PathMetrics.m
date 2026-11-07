function [ds, curvature] = PathMetrics(path)
x = path(:, 1);
y = path(:, 2);
% Segment lengths
dx = circshift(x, -1) - x;
dy = circshift(y, -1) - y;
ds = sqrt(dx.^2 + dy.^2);
% Central differences
dx1 = (circshift(x, -1) - circshift(x, 1))/2;
dy1 = (circshift(y, -1) - circshift(y, 1))/2;
dx2 = circshift(x, -1) - 2*x + circshift(x, 1);
dy2 = circshift(y, -1) - 2*y + circshift(y, 1);
denominator = (dx1.^2 + dy1.^2).^(3/2);
denominator = max(denominator, 1e-8);
% Signed curvature
curvature = (dx1.*dy2-dy1.*dx2)./denominator;
end