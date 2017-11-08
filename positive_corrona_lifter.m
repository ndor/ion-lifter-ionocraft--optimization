function net_acceleration_g_fraction = positive_corrona_lifter(altitude,air_temperature,anode_wire_radius,anode_wire_length,electrodes_gap,cathode_film_width,cathode_film_thickness,voltage_ripple,flight_duration)
% lifter : positive corona wire - advanced model [SI]

%% main parameters:
% altitude  = 0 %[m]
% anode_wire_radius = 0.00005 % [m]   *TBOPT*
% anode_wire_length = 0.05 % [m]   *TBOPT*
% electrodes_gap = 0.05 % [m]   *TBOPT*
% cathode_film_width = electrodes_gap % [m]   *TBOPT*
% cathode_film_thickness = 0.0001 % [m]
% voltage_ripple = 0.03 % [.%]
% flight_duration = 60 % [sec])

% material parameters:
m0 = 0.98 % The wire roughness factor 
battery_specific_power = 300 % [W/Kg]
battery_specific_energy = 250.*3600 % [J/Kg]
anode_wire_density = 8960 % [Kg/m3] (copper)
anode_free_e_density = 8.5e28 % [#/m3]
cathode_density = 2700 % [Kg/m3]
transformer_specific_power = 5000 % [W/Kg]
empty_body_weight_scalar = 5; % times the metals to estimate whole chassis

%% atmosphere
one_electron = abs(-1.6e-19) % [C]
ion_mobility = 2e-4; % for negative corrona: 2.7e-4 % [m2/V]
K_geometric_factor = 0.5;
kb = 1.3806488e-23; % Boltzmann constant [J/K]
R_earth = 6371.009e+3 % [m]
g0 = 9.80665 % [m/sec2]
g = 9.80665.*(R_earth./(R_earth+altitude)).^2 % [m/sec2]
gas_constant  = 8.3145 % [J/K*mol]
avogadro = 6.02e+23 % [1/mol]
dT = 273.15 % [K*]	
colissionless_cross_section = 3.57e-10 % [m]	
atm = 101325 % [Pa] (altitudeat sea level)	
elementary_charge = 1.60217656535e-19% [coulomb]
E0 = 3e6 % Air breakdown field gradient at STP [V/m]
epsilon0 = 8.8542e-12 % []F/m]

% N2:
N2_portion_in_atmosphere = 0.78084 % [.%]
N2_single_atom_mass = 2.33e-26 % [Kg]
N2_single_molecule_mass = 2.*N2_single_atom_mass % [Kg]
N2_single_molecule_diameter = mean([3.16,3.14,4],2).*10^-10 % [m]
N2_single_atom_1st_order_ionization = 2.32846e-18 % [J]
N2_single_molecule_1st_order_ionization = 2.*N2_single_atom_1st_order_ionization % [J]

% O2:
O2_portion_in_atmosphere = 0.20946 % [.%]
O2_single_atom_mass = 2.66e-26 % [Kg]
O2_single_molecule_mass = 2.*O2_single_atom_mass % [Kg]
O2_single_molecule_diameter = mean([2.96,2.9,4,3.75]).*10^-10 % [m]
O2_single_atom_1st_order_ionization = 2.18168e-18 % [J]
O2_single_molecule_1st_order_ionization = 2.*O2_single_atom_1st_order_ionization % [J]

% N2 & O2:
N2nO2_portion_in_atmosphere = 0.9903 % [.%]
average_single_atom_mass = (N2_single_atom_mass.*N2_portion_in_atmosphere + O2_single_atom_mass.*O2_portion_in_atmosphere)./N2nO2_portion_in_atmosphere % [Kg]
average_single_molecule_mass = 2.*average_single_atom_mass % [Kg]
average_single_molecule_diameter = (N2_single_molecule_diameter.*N2_portion_in_atmosphere + O2_single_molecule_diameter.*O2_portion_in_atmosphere)./N2nO2_portion_in_atmosphere % [Kg]
average_single_atom_1st_order_ionization = (N2_single_atom_1st_order_ionization.*N2_portion_in_atmosphere + O2_single_atom_1st_order_ionization.*O2_portion_in_atmosphere)./N2nO2_portion_in_atmosphere % [J]
average_single_molecule_1st_order_ionization = 2.*average_single_atom_1st_order_ionization % [J]

atmospheric_average_molecular_mass = avogadro.*average_single_molecule_mass % [Kg/mol]	
pressure = atm.*((1-0.0065.*altitude./288.15).^(g.*atmospheric_average_molecular_mass./(gas_constant.*0.0065))) % air pressure [Pa]
% pressure = atm.*exp(-atmospheric_average_molecular_mass.*g.*altitude./(gas_constant.*(dT+air_temperature))) % [Pa]
mean_free_path_of_air = gas_constant.*(dT+air_temperature)./(sqrt(2).*pi.*avogadro.*pressure.*colissionless_cross_section.^2) % [m]
rho_air_at_STP = atm./287.05./(dT+air_temperature) % air density (Kg/m3]
rho_air = pressure./287.05./(dT+air_temperature) % air density (Kg/m3]
speed_of_sound = sqrt(1.4.*pressure./rho_air) % [m/sec] - speed of molecules colission in air
vrms_of_air_molecule = sqrt(3.*kb.*(dT+air_temperature)./average_single_molecule_mass) % [m/sec]

%% ionization

anode_wire_circumference = 2.*pi.*anode_wire_radius % [m]
anode_wire_cut_area = pi.*anode_wire_radius.^2 % [m]
% R_min_equivalent =  % [Ohm]
anode_wire_surface_area = anode_wire_length.*anode_wire_circumference % [m]
anode_wire_circular_occupation = anode_wire_circumference./mean_free_path_of_air % [#]
anode_wire_length_occupation = anode_wire_length./mean_free_path_of_air % [#]
anode_wire_occupation = anode_wire_circular_occupation.*anode_wire_length_occupation % [#]
% theoretical_ionization_instantanius_power = average_single_molecule_1st_order_ionization.*anode_wire_occupation % [m] !!!!!!!!!!!!!!!

% Corona inception voltage (CIV):
d_air = rho_air./rho_air_at_STP;
Ei = E0.*d_air.*(1+0.0301./sqrt(d_air.*anode_wire_radius)) % Corona Inception Voltage Gradient [V/m]
CIV = (1+voltage_ripple).*m0.*Ei.*anode_wire_radius.*log(electrodes_gap./anode_wire_radius)   % [V]
effective_corrona_radius = (Ei./E0).*anode_wire_radius % [m]
corona_voltage_drop = Ei.*anode_wire_radius.*log(effective_corrona_radius./anode_wire_radius) % [V]
ionization_volume = anode_wire_length.*pi.*(effective_corrona_radius.^2 - anode_wire_radius.^2)./log(CIV./corona_voltage_drop) % [m3]
% ionization_volume = anode_wire_length.*pi.*((anode_wire_radius+ average_single_molecule_diameter).^2 - anode_wire_radius.^2)./log(CIV./corona_voltage_drop) % [m3]
number_of_ionized_molecules = ionization_volume.*rho_air./average_single_molecule_mass % [#]
ionized_air_mass = ionization_volume.*rho_air % [Kg]
% CIV_force_on_air_molecule  = elementary_charge.*CIV./electrodes_gap % [N]
% air_molecule_acceleration  = (CIV_force_on_air_molecule./average_single_molecule_mass) % [m/sec2]
% ionization_time_of_air  = 1./sqrt(air_molecule_acceleration./(effective_corrona_radius - anode_wire_radius)) % [sec]
% max_current = number_of_ionized_molecules.*elementary_charge./ionization_time_of_air % [A]
% max_current = 100.*50E-6 % [A/m]
% theoretical_ionization_instantanius_power = number_of_ionized_molecules.*average_single_molecule_1st_order_ionization./ionization_time_of_air % [#/m3] number of molecules @ m3

% % ion mobility: drift_time pending
% Ptorr = pressure.*133.322 % [Torr]
% drift_time = electrodes_gap./speed_of_sound % [sec]
% % Ko = (electrodes_gap.^2./(voltage.*drift_time)).*(273.15./(dT+air_temperature)).*(Ptorr./760) % mobility constant
% No = rho_air./average_single_molecule_mass
% myu = average_single_molecule_mass.*average_single_molecule_mass./(2.*average_single_molecule_mass)% mM/(m+M)
% omega = (3./16).*(2.*elementary_charge./No).*sqrt(2.*pi./(myu.*kb.*(dT+air_temperature)))./Ko

% air_collision_cross_section do it now!

% air_ion_mobility = (3./16).*(2.*elementary_charge./(No.*air_collision_cross_section)).*sqrt(2.*pi./(myu.*kb.*(dT+air_temperature)))
% 
% 
% 
% % Peek's law: 
% % Peek's law defines the electric potential gap necessary for triggering a corona discharge between two wires
% mv = 0.98; %is an irregularity factor to account for the condition of the wires. 
% % For smooth, polished wires, mv = 1. For roughened, dirty or weathered wires, 0.98 to 0.93, and for cables, 0.87 to 0.83, 
% % namely the surface irregularities result in diminishing the corona threshold voltage.
% rho_SATP = 1.22; % [Kg/m3]
% go = 320000; % disruptive electric field [V/m]
% c = 0.0301; % empirical dimensional constant [sqrt(m)]
% gamma = rho_air./rho_SATP;
% gv = go.*gamma.*(1+c./sqrt(gamma.*anode_wire_radius)); % visual critical" electric field
% ev = mv.*gv.*anode_wire_radius.*log(electrodes_gap./anode_wire_radius) % [V]
% V = floor(ev) % [V]



%% Paschen's law:
% 
% N = 2.7e25; % air molecules in cubic meter [#/m3]
% % lambda = 68e-9; % air mean free path [m]
% % omega = 2.5e-8; %  the second Townsend coefficient (the mean number of generated secondary electrons per ion)
% ei = 1350; % 2.403285e-18; % ionization energy of air (Nitrojen=15.6 ev, oxygen = 13.6 ev) [J]
% kb = 1.3806488e-23; % Boltzmann constant [J/K]
% ri = 6e-11; % the radius of oxigen atom - for air molecule simplification [m]
% L = kb.*T./(pi.*(ri.^2));
% % lambda = kb.*T./(p.*pi.*(ri.^2)) % air mean free path [m]
% VBD = L.*p.*d.*ei./log(L.*p.*d); % breakdown (Townsend) voltage [V]


%% thrust:
myu = average_single_molecule_mass.*average_single_molecule_mass./(2.*average_single_molecule_mass)% mM/(m+M)
ion_drift_time = (pressure.*dT.*electrodes_gap.^2)./(ion_mobility.*atm.*(air_temperature+dT).*CIV) % [sec]
pulsed_frequency = 1./ion_drift_time % [Hz] (if desired)
ion_cloud_cross_sectional_area = (sqrt(18.*pi)./16).*(elementary_charge./sqrt(kb.*(air_temperature+dT))).*(ion_drift_time.*CIV./((electrodes_gap).^2)).*(atm./pressure).*((air_temperature+dT)./dT).*myu % [m2]
ion_drift_velocity = electrodes_gap./ion_drift_time % [m/sec]
thrust_by_momentum = ion_drift_velocity.*ionized_air_mass./ion_drift_time % [N]
% ion_current = anode_wire_occupation.*one_electron.*ion_drift_velocity./(electrodes_gap+cathode_film_width./2) % [A]
ion_current = ()2.*ion_mobility.*K_geometric_factor.*epsilon0.*(CIV./electrodes_gap).^2).*anode_wire_length % [A]
thrust_by_ion_mobility = ion_current.*electrodes_gap./ion_mobility % [N]
thrust_by_kilograms = thrust_by_ion_mobility./g % [g]
theoretical_ionization_power = CIV.*ion_current % [W]
theoretical_ionization_power_loss = corona_voltage_drop.*ion_current % [W]
theoretical_needed_power = theoretical_ionization_power_loss + theoretical_ionization_power % [W]
thrust_to_power_ratio = thrust_by_kilograms./theoretical_needed_power % [Kg/W]
minimal_cathode_radius_of_curvature = ((CIV./1000)./(3.*(1 + 0.03.*(1000.*anode_wire_radius).^(-0.5))))./1000 % [m]

%% body weight:
anode_wire_volume = anode_wire_length.*pi.*anode_wire_radius.^2 % [m3]
cathode_volume = anode_wire_length.*cathode_film_thickness.*cathode_film_width % [m3]
anode_weight = anode_wire_volume.*anode_wire_density % [Kg]
cathode_weight = cathode_volume.*cathode_density % [Kg]
empty_body_weight = empty_body_weight_scalar.*(cathode_weight + anode_weight) % [Kg]
transformer_weight = theoretical_needed_power./transformer_specific_power % [Kg]
battary_weight_by_power = theoretical_needed_power./battery_specific_power % [Kg]
battary_weight_by_energy = flight_duration.*theoretical_needed_power./battery_specific_energy % [Kg]
battary_weight = max([battary_weight_by_power,battary_weight_by_energy]) % [Kg]
overall_lifter_weight = empty_body_weight + transformer_weight + battary_weight % [Kg]

net_thrust = thrust_by_ion_mobility - overall_lifter_weight .*g % [N]
net_thrust_by_kilograms = net_thrust./g % [Kg]
net_thrust_to_power_ratio = net_thrust_by_kilograms./theoretical_needed_power % [Kg/W]
net_acceleration = net_thrust./overall_lifter_weight  % [m/sec2]
net_acceleration_g_fraction = net_acceleration./g

% to be continued..




















