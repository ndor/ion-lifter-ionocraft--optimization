clear all
clc


altitude = 0; % above sea level [m]
temperature = 20; % [C*]
weight = 1; % [Kg]
% r = 0.0005; % (anode radiuswire radius) [m]
% d = 0.03; % distance between electrodes (wires) [m]
thruster_area = 0.2.^2; % [m2]
flight_duration = 1800; % [sec]		
battery_specific_power = 500; % [W/Kg]		
battery_specific_energy = 350.*3600; % [J/Kg]

X = opt_thrust(weight,altitude,temperature);
r = X(1)
d = X(2)

%% transformation:

K = 1; % performace geometrical constant of anode-cathode performace
e0 = 8.854187817e-12; % vacuum permittivity, permittivity of free space or electric constant [F/m]
p0 = 101325; % sea level standard atmospheric pressure [Pa]
L = 0.0065 ; % temperature lapse rate [K/m]
T0 = 288.15; % sea level standard temperature [K*]
g = 9.80665; % Earth-surface gravitational acceleration [m/sec2]
M = 0.0289644; % molar mass of dry air [Kg/mol]
R = 8.31447; % universal gas constant  [L/mol.K*]
T = temperature+273; % air temperature [K*]
p = p0.*((1-L.*altitude./T0).^(g.*M./(R.*L))); % air pressure [Pa]
rho_air = p./287.05./T % air density (Kg/m3]
R_copper = 30; %16.78e-9 ; % [ohm/m]
h_air = 10; % [W/m2.K]

%% Peek's law:

mv = 0.98; %irregularity factor to account for the condition of the wires
rho_SATP = 1.22; % [Kg/m3]
g0 = 3200000; % disruptive electric field [V/m]
c = 0.0301; % empirical dimensional constant [sqrt(m)]
gamma = rho_air./rho_SATP;
gv = g0.*gamma.*(1+c./sqrt(gamma.*r)); % visual critical" electric field
ev = mv.*gv.*r.*log(d./r);

V = ceil(1.1.*ev)


%% Paschen's law:

% N = 2.7e25; % air molecules in cubic meter [#/m3]
% lambda = 68e-9; % air mean free path [m]
% omega = 2.5e-8; %  the second Townsend coefficient (the mean number of generated secondary electrons per ion)
% Ei = 1350; % 2.403285e-18; % ionization energy of air (Nitrojen=15.6 ev, oxygen = 13.6 ev) [J]
% kb = 1.3806488e-23; % Boltzmann constant [J/K]
% ri = 6e-11; % the radius of oxigen atom - for air molecule simplification [m]
% L = kb.*T./(pi.*(ri.^2));
% % lambda = kb.*T./(p.*pi.*(ri.^2))
% 
% VBD = L.*p.*d.*Ei./log(L.*p.*d) % breakdown (Townsend) voltage [V]


%% voltage for thruster will be CIV<V<VBD:
% 
% dV = VBD - CIV;
% V = ceil(CIV./1000).*1000


%% electrohydraulics:

k = 2.1e-4; % mobility coefficient of ion in air [m2/V.sec]
Na = 6.0221367e23; % Na is Avogadro number [1/mole]
e = 1.602176565e-19; % electron charge [C]
F_lift = weight.*9.81; %  (F = mass*g) [N]
i_needed = F_lift.*k./d % [A]
P_needed = i_needed.*V
i_max = 100.*sqrt(thruster_area).*2.*K.*k.*e0.*(V./d).^2 % [A]

%% kinetics:

% m = 28.*1.67262158e-27 % air molecule mass [Kg]
% n = i_needed./e % charged particles per second 
% mdot = n.*m % [Kg/sec]
% v_air = P_needed./mdot % [m/sec]
% v_air = sqrt(2.*V.*e./m) % [m/sec]
% v_air = mdot./(rho_air.*thruster_area) % [m/sec]
v_air = sqrt(i_needed.*d./(rho_air.*k.*thruster_area)) % [m/sec]
mdot = F_lift./v_air % [Kg/sec]
E_needed = P_needed.*flight_duration; % [J]
battery_weight = max(E_needed./battery_specific_energy,P_needed./battery_specific_power)
anode_temperature = (R_copper.*i_needed.^2)./(h_air.*2.*pi.*r)+temperature % [C*]



