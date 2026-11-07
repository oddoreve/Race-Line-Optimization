function [v, ds, curvature] = SpeedProfile(path, track, car)
[ds, curvature] = PathMetrics(path);
N = length(ds);
% Cornering speed limit
lateralAcceleration = car.mu * car.g;
vCorner = sqrt(lateralAcceleration./max(abs(curvature), 1e-6));
% Apply maximum speed
vMax = min(vCorner, car.maxSpeed);
% Initial speed profile
v = vMax;
% Repeated forward and backward passes to enforce acceleration and braking limits
for iteration = 1:5
    % Forward acceleration pass
    for i = 1:N
        j = mod(i,N) + 1;
        currentSpeed = max(v(i),2);
        dragForce = 0.5*car.rho*car.Cd*car.A*currentSpeed^2;
        rollingForce = car.Crr*car.mass*car.g;
        availablePowerForce = car.maxPower/currentSpeed;
        powerAcceleration = (availablePowerForce-dragForce-rollingForce)/car.mass;
        availableAcceleration = min(car.maxDriveAccel, max(powerAcceleration,0));
        nextSpeed = sqrt(v(i)^2+2*availableAcceleration*ds(i));
        v(j) = min(v(j),nextSpeed);
    end
    % Backward braking pass
    for i = N:-1:1
        j = mod(i,N) + 1;
        previousSpeed = sqrt(v(j)^2 + 2*car.maxBrakeAccel*ds(i));
        v(i) = min(v(i),previousSpeed);
    end
end
v = max(v,0.5);
end