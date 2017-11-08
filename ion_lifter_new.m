clear all
clc


altitude = 0; % above sea level [m]
temperature = 20; % [C*]
weight = 1; % [Kg]
r = 1e-5; % (anode radiuswire radius) [m]
d = 0.5; % distance between electrodes (wires) [m]
flight_duration = 1800; % [sec]		
battery_specific_power = 500; % [W/Kg]		
battery_specific_energy = 350.*3600; % [J/Kg]

% for i = 1:100
%     rr(i) = 0.001./i;
%     r=rr(i)

%% constants:

K0 = sqrt(18.*pi); % mobility at 760 torr, 273 K
K = 1; % performace geometrical constant of anode-cathode performace
e0 = 8.854187817e-12; % vacuum permittivity, permittivity of free space or electric constant [F/m]
p0 = 101325; % sea level standard atmospheric pressure [Pa]
L = 0.0065 ; % temperature lapse rate [K/m]
T0 = 288.15; % sea level standard temperature [K*]
g = 9.80665; % Earth-surface gravitational acceleration [m/sec2]
M = 0.0289644; % molar mass of dry air [Kg/mol]
R = 8.31447; % universal gas constant  [L/mol.K*]
R_copper = 30; %16.78e-9 ; % [ohm/m]
h_air = 10; % [W/m2.K]
mv = 0.98; %irregularity factor to account for the condition of the wires
rho_SATP = 1.22; % [Kg/m3]
g0 = 3200000; % disruptive electric field [V/m]
c = 0.0301; % empirical dimensional constant [sqrt(m)]
k = 2e-4; % mobility coefficient of ion in air [m2/V.sec]
Na = 6.0221367e23; % Na is Avogadro number [1/mole]
e = 1.602176565e-19; % electron charge [C]


%% transformations:

T = temperature+273.2; % air temperature [K*]
p = p0.*((1-L.*altitude./T0).^(g.*M./(R.*L))); % air pressure [Pa]
rho_air = p./287.05./T; % air density (Kg/m3]


%% Peek's law:

gamma = rho_air./rho_SATP;
gv = g0.*gamma.*(1+c./sqrt(gamma.*r)); % visual critical" electric field [V/m]
ev = mv.*gv.*r.*log(d./r);
r0 = r.*gv./g0 % effective radius (corrona radius) [m]
Vd = gv.*r.*log(r0./r); % corona voltage drop - loss [V]
V = ceil(1.1.*ev); % effective voltage of corrona wire vs. collector [V]
CIV = V+Vd % actual needed voltage [V]
rc = V./(g0.*(1+c.*r.^(-0.5))) % minimal (wire case) collector radius of curvature [m]


%% Paschen's law:

N = 2.7e25; % air molecules in cubic meter [#/m3]
% lambda = 68e-9; % air mean free path [m]
% omega = 2.5e-8; %  the second Townsend coefficient (the mean number of generated secondary electrons per ion)
Ei = 1350; % 2.403285e-18; % ionization energy of air (Nitrojen=15.6 ev, oxygen = 13.6 ev) [J]
kb = 1.3806488e-23; % Boltzmann constant [J/K]
ri = 6e-11; % the radius of oxigen atom - for air molecule simplification [m]
L = kb.*T./(pi.*(ri.^2));
% lambda = kb.*T./(p.*pi.*(ri.^2)) % air mean free path [m]
VBD = L.*p.*d.*Ei./log(L.*p.*d); % breakdown (Townsend) voltage [V]


%% voltage for thruster will be CIV<V<VBD:

dV = VBD - CIV
% if dV>1000; dV = 1000; end
% V = ceil((CIV+dV)./1000).*1000
V = CIV

%% ionocraft basic geometry:

y = K.*d.*tand(65) % ion cloud half width at collector grid plane [m]
x = 1.35.*d % wires optimal spacing [m]


%% electrohydraulics:

F_lift = weight.*g; %  (F = mass*g) [N]
i_needed = F_lift.*k./d % [A]
P_needed = i_needed.*V


%% drift velocity:

E = V./d; % electric field force [V/m]
v_ion = k.*E % [m/sec]
j_max = 2.*k.*e0.*E.^2 % [A/m]
X = i_needed./j_max % total wire length [m]
A = 2.*y.*X % effective ion cloud cross sectional area at acollector plane [m2]
v_air = sqrt(i_needed.*d./(k.*rho_air.*A)) % air flow velocity [m/sec]
mdot = rho_air.*A.*v_air % [Kg/sec]
efficiency = F_lift.*v_air./(P_needed)
LPW_efficiency = F_lift./(P_needed)
force2power = F_lift./(g.*P_needed)  % [Kgf/W]


%% power payload:

E_needed = P_needed.*flight_duration; % [J]
battery_weight = max(E_needed./battery_specific_energy,P_needed./battery_specific_power)
anode_temperature = (R_copper.*i_needed.^2)./(h_air.*2.*pi.*r)+temperature % [C*]

% end
% 
% plot(rr,LPW_efficiency)