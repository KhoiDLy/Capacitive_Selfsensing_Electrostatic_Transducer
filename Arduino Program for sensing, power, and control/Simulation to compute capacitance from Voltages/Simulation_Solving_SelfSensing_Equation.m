clear all;
close all;
clc;

% Given Parameters:
V_Tot = 18; % Volt
V_Rm  = 835.04*10^-3; % Vollt
theta   = deg2rad(86.45); %Phase lead between V_Rm and V_tot

Rm = 20*10^3; % Ohm
Rs = 40*10^3; % Ohm
Cf = 220*10^-12; %Farah
Rp = 1.5*10^9; %Farah
F  = 1000; %Hz
% Solving for Zc
V_Junct = sqrt(V_Tot^2 + V_Rm^2 -2*V_Tot*V_Rm*cos(theta));
phi   = pi - asin(V_Tot / V_Junct * sin(theta) );
gamma = pi - phi;
z     = pi/2 - gamma;
I_Rm  = V_Rm / Rm;
I_f   = V_Junct * ( 2*pi*Cf*F);
I_a   = sqrt(I_Rm^2 + I_f^2 - 2*I_Rm*I_f*cos(z));
x     = asin(I_f / I_a * sin(z));
alpha = pi/2 - z - x;

p = [(V_Junct^2 / Rs^2), 0, -(V_Junct^2 / Rs^2), 0, (I_a^2*sin(alpha)^2)];
r = roots(p)

C =  1/(  tan(acos(r(4)))*40000*2*pi*1000);
