function car = CreateCar()
% Basic vehicle parameters
car.mass = 800; % kg
car.g = 9.81; % m/s^2
car.mu = 1.4; % Tyre-road friction coefficient
% Engine and drivetrain
car.maxPower = 250000; % W (250 kW)
car.maxSpeed = 80; % m/s
car.drivetrainEfficiency = 0.90;
% Aerodynamic parameters
car.rho = 1.225; % Air density (kg/m^3)
car.Cd = 0.9; % Drag coefficient
car.A = 1.5; % Frontal area (m^2)
car.Crr = 0.015; % Rolling resistance
% Combustion engine parameters
car.engineEfficiency = 0.30;
car.fuelLHV = 43e6; % J/kg
car.idleFuelRate = 0.0003; % kg/s (illustrative)
% Braking limit
car.maxBrakeAccel = 0.90*car.mu*car.g;
% Longitudinal traction limit
car.maxDriveAccel = 0.90*car.mu*car.g;
end