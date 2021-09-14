clc; clear all; close all;
% Plotting High Voltage versus displacement of HASEL actuators

var1 = xlsread('Test1.xlsx');
var3 = xlsread('Test3.xlsx'); var3(:,2) = var3(:,2)* 2; 
var4 = xlsread('Test4.xlsx'); var4(:,2) = var4(:,2)* 2;

t = 0:1:29999;
t = t/1000;

figure
yyaxis left
plot(t,var1(1:30000,1),'--');
ylabel('Voltage (V)');
xlabel('Second (s)')
yyaxis right
plot(t,var1(1:30000,2),'--');
ylabel('Displacement (mm)');
title('Quad Donut HASEL Actuators (BOPP) 560pF');

figure
yyaxis left
plot(t,var3(1:30000,1),'--');
ylabel('Voltage (V)');
xlabel('Second (s)')
yyaxis right
plot(t,var3(1:30000,2),'--');
ylabel('Displacement (mm)');
title('8 folded HASEL without wrap (BOPP) 320pF');

figure
yyaxis left
plot(t,var4(1:30000,1),'--');
ylabel('Voltage (V)');
xlabel('Second (s)')
yyaxis right
plot(t,var4(1:30000,2),'--');
ylabel('Displacement (mm)');
title('8 folded HASEL with wrap (BOPP) 320pF');

figure
plot(var1(1:30000,2),var1(1:30000,1),'--');
title('Quad Donut HASEL Actuators (BOPP) 560pF');
xlabel('Displacement (mm)'); ylabel('Voltage (V)');

figure
plot(var3(1:30000,2),var3(1:30000,1),'--');
title('8 folded HASEL without wrap (BOPP) 320pF');
xlabel('Displacement (mm)'); ylabel('Voltage (V)');

figure
plot(var4(1:30000,2),var4(1:30000,1),'--');
title('8 folded HASEL with wrap (BOPP) 320pF');
xlabel('Displacement (mm)'); ylabel('Voltage (V)');