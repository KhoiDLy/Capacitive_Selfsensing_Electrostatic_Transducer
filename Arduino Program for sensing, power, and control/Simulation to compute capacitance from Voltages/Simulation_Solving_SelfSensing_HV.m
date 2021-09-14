clear all;
close all;
clc;

%% read in sensor data
m = readtable(['raw_data.txt']);
A = table2array(m);
theta = A(10,1)*ones(length(A),1);
% theta = A(:,1);
V_Rm  = A(:,2);
V_Tot = A(:,3);
% Ca_meas = A(:,4);

%% plot data
figure(1)
plot(V_Tot); hold on; plot(V_Rm); plot(theta); legend('Total Voltage','Measured Voltage', 'theta'); 

% figure(2)
% plot(Ca_meas); title('Measured Capacitnace (pF)');

%%
% Given Parameters:

Rm = 31100; % Ohm
Rs = 1; % Ohm // decrease Rs will fix the problem
Ct = 220*10^-12; %Farah
Rvs = 70.742; % Ohm // Increasing C must decreases Rvs
C   = 3000*10^-12; % Farah // THis seems to be the issue
Rvp = 6435000000; %Ohm
F  = 1000; %Hz

% Solving for Zc
V_Junct = sqrt(V_Tot.^2 + V_Rm.^2 -2*V_Tot.*V_Rm.*cos(theta));
phi   = pi - asin(V_Tot./ V_Junct.* sin(theta) );
gamma = pi - phi;
z     = pi/2 - gamma;
I_Rm  = V_Rm./ Rm;
I_t   = V_Junct.* ( 2*pi*Ct*F);
I_a   = sqrt(I_Rm.^2 + I_t.^2 - 2.*I_Rm.*I_t.*cos(z));
x     = asin(I_t./I_a.* sin(z));
alpha = pi/2 - z - x;

% Solving for the V_o and I_o
Zc = 1/(2*pi*C*F);
V_o = I_a.* sqrt(Rvs.^2 + Zc.^2).* Rvp./ (Rvp+ sqrt(Rvs.^2 + Zc.^2)); % the calculation says that V_o > V_Tot!!!
y = atan(Rvs./ Zc);
w = pi/2 - y;
I_vp = V_o./ Rvp;
k = asin(I_vp./ I_a.* sin(pi - w));
m = pi - ( pi - w) - k;
n = m - alpha;
% n  = ones(676,1) *0.1105;
V_a = sqrt( V_Junct.^2 + V_o.^2 - 2.*V_Junct.*V_o.*cos(n));
p = asin( V_o./ V_a.*sin(n));
beta = alpha - p;

B       =  V_a.* sin(beta)./ I_a;
Zca     =  ( B.* (1./ tan(beta)./ tan(beta) + 1) + sqrt(B.* B.* (1./ tan(beta)./ tan(beta) + 1).* (1./ tan(beta)./ tan(beta) + 1) - 4.* Rs.* Rs) ) / 2;
Ca      =  1./ (2* pi.* Zca* F)*(10^12);

figure(3)
plot(Ca); hold on;
