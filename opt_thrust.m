function x = opt_thrust(weight,altitude,temperature)
%OPT_THRUST Summary of this function goes here
%   Detailed explanation goes here

% altitude - above sea level [m]
% temperature [C*]
% weight [Kg]
% r = 0.0005; % (anode radiuswire radius) [m]
% d = 0.03; % distance between electrodes (wires) [m]

% r = X(1);
% d = X(2);
F =@(X) opt(weight,X,altitude,temperature)

X0 = [0.0005,0.03];
lb = [8e-6,0.0005];
ub = [0.03,0.1];
% options = optimset('Display','iter','PlotFcns',@optimplotfval);
[x,fval,exitflag,output] = fmincon(F,X0,[],[],[],[],lb,ub,[]);%,options);

if x(1) < lb(1); x(1) = lb(1); end
if x(2) < lb(2); x(2) = lb(2); end

end

function target = opt(weight,X,altitude,temperature)
%OPT_THRUST Summary of this function goes here
%   Detailed explanation goes here

% altitude - above sea level [m]
% temperature [C*]
% weight [Kg]
% r = 0.0005; % (anode radiuswire radius) [m]
% d = 0.03; % distance between electrodes (wires) [m]

r = X(1);
d = X(2);
[V,i_needed,P_needed] = thrust(weight,r,d,altitude,temperature);

target = P_needed;

end

function [V,i_needed,P_needed] = thrust(weight,r,d,altitude,temperature)
%OPT_THRUST Summary of this function goes here
%   Detailed explanation goes here

% altitude - above sea level [m]
% temperature [C*]
% r = 0.0005; % (anode radiuswire radius) [m]
% d = 0.03; % distance between electrodes (wires) [m]


%% transformation:

p0 = 101325; % sea level standard atmospheric pressure [Pa]
L = 0.0065 ; % temperature lapse rate [K/m]
T0 = 288.15; % sea level standard temperature [K*]
g = 9.80665; % Earth-surface gravitational acceleration [m/sec2]
M = 0.0289644; % molar mass of dry air [Kg/mol]
R = 8.31447; % universal gas constant  [L/mol.K*]
T = temperature+273; % air temperature [K*]
p = p0.*((1-L.*altitude./T0).^(g.*M./(R.*L))); % air pressure [Pa]
rho_air = p./287.05./T; % air density (Kg/m3]


%% Peek's law:

mv = 0.98; %irregularity factor to account for the condition of the wires
rho_SATP = 1.22; % [Kg/m3]
g0 = 3200000; % disruptive electric field [V/m]
c = 0.0301; % empirical dimensional constant [sqrt(m)]
gamma = rho_air./rho_SATP;
gv = g0.*gamma.*(1+c./sqrt(gamma.*r)); % visual critical" electric field
ev = mv.*gv.*r.*log(d./r);
V = 1.1.*ceil(ev);

%% electrohydraulics:

k = 2.1e-4; % mobility coefficient of ion in air [m2/V.sec]
% Na = 6.0221367e23; % Na is Avogadro number [1/mole]
% e = 1.602176565e-19; % electron charge [C]
F_lift = weight.*9.81; %  (F = mass*g) [N]
i_needed = F_lift.*k./d; % [A]
P_needed = i_needed.*V; % [W]

end
