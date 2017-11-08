clear all
clc


%% input parameters:
desiered_W = 120; %[Kg]
flight_duration = 1800; % [sec]	
No_rotors = 2; %
R_rotor = 0.5; % [m]	
battery_specific_power = 600; % [KW/Kg]		
battery_specific_energy = 0.6.*3600; % [KJ/Kg]
rotor_efficiency = 0.8	; % 	
temperature = 20; % air temperature [K*]
altitude = 2000; %[m] ASL


%% transformations:
p0 = 101325; % sea level standard atmospheric pressure [Pa]
L = 0.0065 ; % temperature lapse rate [K/m]
T0 = 288.15; % sea level standard temperature [K*]
g = 9.80665; % Earth-surface gravitational acceleration [m/sec2]
M = 0.0289644; % molar mass of dry air [Kg/mol]
R = 8.31447; % universal gas constant  [L/mol.K*]
rho_SATP = 1.22; % [Kg/m3]
T = temperature+273.2; % air temperature [K*]
p = p0.*((1-L.*altitude./T0).^(g.*M./(R.*L))); % air pressure [Pa]
rho = p./287.05./T; % air density (Kg/m3]

%% battery weight - plain
	
A = No_rotors.*pi.*R_rotor.^2
W_batt = battery_weight(rho,rotor_efficiency,No_rotors,R_rotor,flight_duration,battery_specific_power,battery_specific_energy,desiered_W)


% %% battery weight - optimization
% No_rotors = [2;2;2]; % [lb;x0;ub]
% R_rotor = [0.05;0.15;0.3]; % [lb;x0;ub] [m]		
% 
% x = lift_plat_opt(rho,rotor_efficiency,No_rotors,R_rotor,flight_duration,battery_specific_power,battery_specific_energy,desiered_W)


%% vattery weight included in power calculation
% flight_duration = [0:1:180.*2].*5;
% 
% for i = 1:10
%     
%     battery_s_energy(i) = (battery_specific_energy./10).*i;
%     
%     for j = 1:length(flight_duration)
%         
%         W = desiered_W;
%         dW = 1;
%         
%         while dW>0.0001
%             W1 = W;
%             W = desiered_W+battery_weight(rho,rotor_efficiency,No_rotors,R_rotor,flight_duration(j),battery_specific_power,battery_s_energy(i),W);
%             dW = abs(W1-W);
%         end
%         
%     tot_W(j,i) = W;
%         
%     end
% 
%     plot(flight_duration,tot_W(:,i),'Color',i.*[1 0 1]./10,'LineWidth',3)
%     hold on
%     
% end
% 
% plot(flight_duration,desiered_W.*ones(length(flight_duration),1),'--r','LineWidth',3)
% hold on
% grid on
% xlabel('flight duration [sec]','FontSize',14,'FontWeight','bold')
% ylabel('total weight [Kg]','FontSize',14,'FontWeight','bold')
% title('')

