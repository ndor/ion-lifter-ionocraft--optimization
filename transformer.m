




DC_feed_to_switcher = 11.1 % [V]
switcher_duty_cycle = 0.4 % [.%]
power_demand = switcher_duty_cycle.*30./0.8 % [W] transformer power duty
f = 1e6 % [Hz] 
Bmax = 125e-4 % [T]

% Topology constant 
Kt = 0.0014 
% Forward converter = 0.0005 
% Push-Pull = 0.001
% Half-bridge = 0.0014 
% Full-bridge = 0.0014
% Flyback = 0.00033 (single winding) 
% Flyback = 0.00025 (multiple winding)


primary_current_rms = power_demand./(DC_feed_to_switcher.*sqrt(switcher_duty_cycle)) % [A]

primary_wire_cross_sectional_area = 0.0001.*0.01 % [m]

Dcma = primary_wire_cross_sectional_area./primary_current_rms % [m2/A] current density

WaAc = power_demand.*Dcma./(Kt.*Bmax.*f)

























