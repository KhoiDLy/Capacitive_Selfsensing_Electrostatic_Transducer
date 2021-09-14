clc; clear all; close all;
% Plotting High Voltage versus displacement of HASEL actuators

var1 = xlsread('TPU_0g_1W_1.xlsx');
var2 = xlsread('TPU_0g_TREK_Ramp.xlsx'); 
var3 = xlsread('TPU_0g_TREK_Step.xlsx'); 
var4 = xlsread('TPU_136g_1W_2.xlsx');
var5 = xlsread('TPU_136g_TREK_3.xlsx');  
var6 = xlsread('TPU_136g_TREK_Ramp_1.xlsx');
var7 = xlsread('TPU_136g_TREK_Ramp_2.xlsx');


t1 = 0:1:29999;
t1 = t1/1000;
t2 = 0:1:299999;
t2 = t2/10000;

figure(1)
yyaxis left
plot(t1,var1(1:30000,2)*1165,'--');
ylabel('Voltage (V)');
xlabel('Second (s)')
yyaxis right
plot(t1,var1(1:30000,1),'--');
ylabel('Displacement (mm)');
title('Stack of 3 TPU Donuts 0g load 1W Converter');

figure(2)
plot(var1(1:30000,1),var1(1:30000,2)*1165,'--');
title('Stack of 3 TPU Donuts 0g load 1W Converter');
xlabel('Displacement (mm)'); ylabel('Voltage (V)');

figure(3)
yyaxis left
plot(t2,var3(1:300000,2)*1165,'--');
ylabel('Voltage (V)');
xlabel('Second (s)')
yyaxis right
plot(t2,var3(1:300000,1),'--');
ylabel('Displacement (mm)');
title('Stack of 3 TPU Donuts 0g load TREK');

figure(4)
plot(var3(1:300000,1),var3(1:300000,2)*1165,'--');
title('Stack of 3 TPU Donuts 0g load TREK');
xlabel('Displacement (mm)'); ylabel('Voltage (V)');

figure(5)
yyaxis left
plot(t1,var4(1:30000,2)*1165,'--');
ylabel('Voltage (V)');
xlabel('Second (s)')
yyaxis right
plot(t1,var4(1:30000,1),'--');
ylabel('Displacement (mm)');
title('Stack of 3 TPU Donuts 136g load 1W Converter');

figure(6)
plot(var4(1:30000,1),var4(1:30000,2)*1165,'--');
title('Stack of 3 TPU Donuts 136g load 1W Converter');
xlabel('Displacement (mm)'); ylabel('Voltage (V)');

figure(7)
yyaxis left
plot(t2,var5(1:300000,2)*1165,'--');
ylabel('Voltage (V)');
xlabel('Second (s)')
yyaxis right
plot(t2,var5(1:300000,1),'--');
ylabel('Displacement (mm)');
title('Stack of 3 TPU Donuts 136g load TREK');

figure(8)
plot(var5(1:300000,1),var5(1:300000,2)*1165,'--');
title('Stack of 3 TPU Donuts 136g load TREK');
xlabel('Displacement (mm)'); ylabel('Voltage (V)');

figure(9)
yyaxis left
plot(t1,var2(1:30000,2)*1165,'--');
ylabel('Voltage (V)');
xlabel('Second (s)')
yyaxis right
plot(t1,var2(1:30000,1),'--');
ylabel('Displacement (mm)');
title('Stack of 3 TPU Donuts 0g load Trek Ramp');

figure(10)
plot(var2(1:30000,1),var2(1:30000,2)*1165,'--');
title('Stack of 3 TPU Donuts 0g load Trek Ramp');
xlabel('Displacement (mm)'); ylabel('Voltage (V)');

figure(11)
yyaxis left
plot(t1,var6(1:30000,2)*1165,'--');
ylabel('Voltage (V)');
xlabel('Second (s)')
yyaxis right
plot(t1,var6(1:30000,1),'--');
ylabel('Displacement (mm)');
title('Stack of 3 TPU Donuts 136g load Trek Ramp');

figure(12)
plot(var6(1:30000,1),var6(1:30000,2)*1165,'--');
title('Stack of 3 TPU Donuts 136g load Trek Ramp');
xlabel('Displacement (mm)'); ylabel('Voltage (V)');

figure(13)
yyaxis left
plot(t1,var7(1:30000,2)*1165,'--');
ylabel('Voltage (V)');
xlabel('Second (s)')
yyaxis right
plot(t1,var7(1:30000,1),'--');
ylabel('Displacement (mm)');
title('Stack of 3 TPU Donuts 136g load Trek Ramp 2');

figure(14)
plot(var7(1:30000,1),var7(1:30000,2)*1165,'--');
title('Stack of 3 TPU Donuts 136g load Trek Ramp 2');
xlabel('Displacement (mm)'); ylabel('Voltage (V)');