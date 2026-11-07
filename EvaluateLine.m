function J = EvaluateLine(d, track, car)
path = BuildPath(track, d);
[v, ds, ~] = SpeedProfile(path, track, car);
N = length(v);
totalTime = 0;
totalFuel = 0;
for i = 1:N
    j = mod(i, N) + 1;
    vAverage = max((v(i)+v(j))/2, 0.5);
    % Time for the segment
    dt = ds(i)/vAverage;
    totalTime = totalTime + dt;
    % Longitudinal acceleration
    acceleration = (v(j)^2-v(i)^2)/(2*max(ds(i), 1e-8));
    % Resistive forces
    dragForce = 0.5*car.rho*car.Cd*car.A*vAverage^2;
    rollingForce = car.Crr*car.mass*car.g;
    % Required traction force
    tractiveForce = car.mass*acceleration + dragForce + rollingForce;
    % Engine power is only required for positive traction force
    wheelPower = max(tractiveForce,0)*vAverage;
    enginePower = wheelPower/car.drivetrainEfficiency;
    % Fuel mass flow rate
    fuelFlow = enginePower/(car.engineEfficiency*car.fuelLHV);
    % Idle fuel rate
    fuelFlow = fuelFlow + car.idleFuelRate;
    totalFuel = totalFuel + fuelFlow*dt;
end
J = [totalTime, totalFuel];
end