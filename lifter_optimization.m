% lifter optimization



%% main parameters:
altitude  = 0 %[m] (above sea level)
air_temperature = 20 % [C*]
anode_wire_radius = 0.00005 % [m]   *TBOPT*
anode_wire_length = 0.05 % [m]   *TBOPT*
electrodes_gap = 0.05 % [m]   *TBOPT*
cathode_film_width = electrodes_gap % [m]   *TBOPT*
cathode_film_thickness = 0.0001 % [m]
voltage_ripple = 0.03 % [.%]
flight_duration = 60 % [sec]

% F = positive_corrona_lifter(altitude,anode_wire_radius,anode_wire_length,electrodes_gap,cathode_film_width,cathode_film_thickness,voltage_ripple,flight_duration)
F = @ (x) -positive_corrona_lifter(altitude,air_temperature,x(1),x(2),x(3),x(3),cathode_film_thickness,voltage_ripple,flight_duration);

x0 = [anode_wire_radius;anode_wire_length;electrodes_gap];%;cathode_film_width]

anode_wire_radius_min = 0.00005 % [m]   *TBOPT*
anode_wire_length_min = 0.001 % [m]   *TBOPT*
electrodes_gap_min = 0.001 % [m]   *TBOPT*
cathode_film_width_min = electrodes_gap % [m]   *TBOPT*

LB = [anode_wire_radius_min;anode_wire_length_min;electrodes_gap_min];%;cathode_film_width_min]

anode_wire_radius_max = 0.003 % [m]   *TBOPT*
anode_wire_length_max = 10 % [m]   *TBOPT*
electrodes_gap_max = 0.2 % [m]   *TBOPT*
cathode_film_width_max = electrodes_gap % [m]   *TBOPT*

UB = [anode_wire_radius_max;anode_wire_length_max;electrodes_gap_max];%;cathode_film_width_max]

options = psoptimset('UseParallel','always','MeshAccelerator','on','Display','iter','CompletePoll','on','UseParallel','always','ScaleMesh','on','PlotFcns',{@psplotfuncount,@psplotbestx,@psplotbestf,@psplotmeshsize});%
[x,fval,exitflag,output] = patternsearch(F,x0,[],[],[],[],LB,UB,[],options)

net_acceleration_g_fraction = positive_corrona_lifter(altitude,air_temperature,x(1),x(2),x(3),x(3),cathode_film_thickness,voltage_ripple,flight_duration)

