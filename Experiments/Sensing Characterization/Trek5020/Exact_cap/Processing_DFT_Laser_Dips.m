clc;
close all;
clear all;

DFT_133 = csvread('Peano_Pelow_Trek_Cap_0_6KV_133g.csv');
raw_laser = csvread('Peano_Polyester_133g_6kv_laser.csv');
Laser_133 = zeros(length(raw_laser)-6,2);
Laser_133(:,1) = raw_laser(5:end-2,2);
Laser_133(:,2) = raw_laser(5:end-2,1);
Laser_133 = Laser_133(1000:9500,:);
Laser_133(:,2) = Laser_133(:,2) - 10;

DFT_233 = csvread('Peano_Pelow_Trek_Cap_0_6KV_233g.csv');
raw_laser = csvread('Peano_Polyester_233g_6kv_laser.csv');
Laser_233 = zeros(length(raw_laser)-6,2);
Laser_233(:,1) = raw_laser(5:end-2,2);
Laser_233(:,2) = raw_laser(5:end-2,1);
Laser_233 = Laser_233(1000:9500,:);
Laser_233(:,2) = Laser_233(:,2) - 11;

DFT_533 = csvread('Peano_Pelow_Trek_Cap_0_6KV_533g.csv');
raw_laser = csvread('Peano_Polyester_533g_6kv_laser.csv');
Laser_533 = zeros(length(raw_laser)-6,2);
Laser_533(:,1) = raw_laser(5:end-2,2);
Laser_533(:,2) = raw_laser(5:end-2,1);
Laser_533 = Laser_533(1000:9500,:);
Laser_533(:,2) = Laser_533(:,2) - 10.5;

% Truncating the DFT_data to match the range of Laser_disp data
i = 1;
while DFT_133(i,2) <= Laser_133(end,2)
    i = i+1;
end
DFT_133 = DFT_133(1:end - (length(DFT_133)-i)-1,:);

i = 1;
while DFT_233(i,2) <= Laser_233(end,2)
    i = i+1;
end
DFT_233 = DFT_233(1:end - (length(DFT_233)-i)-1,:);

i = 1;
while DFT_533(i,2) <= Laser_533(end,2)
    i = i+1;
end
DFT_533 = DFT_533(1:end - (length(DFT_533)-i)-1,:);

% Interpolating data to obtain the laser displacement data corresponding to
% the time stamp of the DFT_data

% Curve fitting data between Laser displacement and DFT data
% Aligning the two data for curve fitting (removing phase lag)


Laser_interp_133 = interp1(Laser_133(:,2),Laser_133(:,1),DFT_133(:,2),'spline');
D = finddelay(DFT_133(:,1),Laser_interp_133)+10;

figure(3); hold on; title('Peano HASEL with 133g load - Trek 5012');
yyaxis left; ylim([min(Laser_interp_133)-0.05, max(Laser_interp_133)+0.05 ]); ylabel('Absolute Displacement (mm)');
plot(DFT_133(abs(D):end-1,2),Laser_interp_133(1:end-abs(D)),':.');

yyaxis right; ylim([min(DFT_133(:,1))-5 max(DFT_133(:,1))+5]); ylabel('DFT output');
plot(DFT_133(abs(D):end-1,2),DFT_133(abs(D):end-1,1));
legend('Laser Displacement data',' Capacitance (pF)');
xlabel('time (s)'); 

figure(2); hold on;
plot(DFT_133(abs(D)+1600:end-1,1), Laser_interp_133(1+1600:end-abs(D)));

Laser_interp_233 = interp1(Laser_233(:,2),Laser_233(:,1),DFT_233(:,2),'spline');
D = finddelay(DFT_233(:,1),Laser_interp_233)+3;

figure(5); hold on; title('Peano HASEL with 233g load - Trek 5012');
yyaxis left; ylim([min(Laser_interp_233)-0.05, max(Laser_interp_233)+0.05 ]); ylabel('Absolute Displacement (mm)');
plot(DFT_233(abs(D):end-1,2),Laser_interp_233(1:end-abs(D)),':.');

yyaxis right; ylim([min(DFT_233(:,1))-5 max(DFT_233(:,1))+5]); ylabel('Capacitance (pF)');
plot(DFT_233(abs(D):end-1,2),DFT_233(abs(D):end-1,1));
legend('Laser Displacement data',' Capacitance (pF)');
xlabel('time (s)'); 

figure(2); hold on;
plot(DFT_233(abs(D)+1600:end-1,1), Laser_interp_233(1+1600:end-abs(D)));

Laser_interp_533 = interp1(Laser_533(:,2),Laser_533(:,1),DFT_533(:,2),'spline');
D = finddelay(DFT_533(:,1),Laser_interp_533)+5;

figure(7); hold on; title('Peano HASEL with 533g load - Trek 5012');
yyaxis left; ylim([min(Laser_interp_533)-0.02, max(Laser_interp_533)+0.02 ]); ylabel('Absolute Displacement (mm)');
plot(DFT_533(abs(D):end-1,2),Laser_interp_533(1:end-abs(D)),':.');

yyaxis right; ylim([min(DFT_533(:,1))-5 max(DFT_533(:,1))+5]); ylabel('Capacitance (pF)');
plot(DFT_533(abs(D):end-1,2),DFT_533(abs(D):end-1,1));
legend('Laser Displacement data',' Capacitance (pF)');
xlabel('time (s)'); 

figure(2); hold on;
plot(DFT_533(abs(D):end-1,1), Laser_interp_533(1:end-abs(D)));

xlim([40 1200]);
xlabel('Capacitance (pF)'); ylabel('Absolute Displacement (mm)');
title('Cap - Displacement Relationship using Trek 5012');
legend('Peano HASEL with 133g','Peano HASEL with 233g','Peano HASEL with 533g','location','NorthWest');

Laser_data = [0.746, 0.700, 0.673, 0.601, 0.435, 0.118];
Cp_data = [77.1, 75.32, 73.74, 71.42, 67.34, 65.30];
figure(2); hold on;
plot(Cp_data, Laser_data, '*');
