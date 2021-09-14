clc;
close all;
clear all;

DFT_33 = csvread('DFT data_peano_pelow_33g_0_6KV_V1code.csv');
raw_laser = csvread('Peano_Polyester_33g_6kv.csv');
Laser_33 = zeros(length(raw_laser)-6,2);
Laser_33(:,1) = raw_laser(5:end-2,2);
Laser_33(:,2) = raw_laser(5:end-2,1);

DFT_133 = csvread('DFT data_peano_pelow_133g_0_6KV_V1code.csv');
raw_laser = csvread('Peano_Polyester_133g_6kv.csv');
Laser_133 = zeros(length(raw_laser)-6,2);
Laser_133(:,1) = raw_laser(5:end-2,2);
Laser_133(:,2) = raw_laser(5:end-2,1);

DFT_233 = csvread('DFT data_peano_pelow_233g_0_6KV_V1code.csv');
raw_laser = csvread('Peano_Polyester_233g_6kv.csv');
Laser_233 = zeros(length(raw_laser)-6,2);
Laser_233(:,1) = raw_laser(5:end-2,2);
Laser_233(:,2) = raw_laser(5:end-2,1);

DFT_533 = csvread('DFT data_peano_pelow_533g_0_6KV_V1code.csv');
raw_laser = csvread('Peano_Polyester_533g_6kv.csv');
Laser_533 = zeros(length(raw_laser)-6,2);
Laser_533(:,1) = raw_laser(5:end-2,2);
Laser_533(:,2) = raw_laser(5:end-2,1);

DFT_1033 = csvread('DFT data_peano_pelow_1033g_0_6KV_V1code.csv');
raw_laser = csvread('Peano_Polyester_1033g_6kv.csv');
Laser_1033 = zeros(length(raw_laser)-6,2);
Laser_1033(:,1) = raw_laser(5:end-2,2);
Laser_1033(:,2) = raw_laser(5:end-2,1);

% Truncating the DFT_data to match the range of Laser_disp data
i = 1;
while DFT_33(i,2) <= Laser_33(end,2)
    i = i+1;
end
DFT_33 = DFT_33(1:end - (length(DFT_33)-i)-1,:);

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

i = 1;
while DFT_1033(i,2) <= Laser_1033(end,2)
    i = i+1;
end
DFT_1033 = DFT_1033(1:end - (length(DFT_1033)-i)-1,:);

% Interpolating data to obtain the laser displacement data corresponding to
% the time stamp of the DFT_data

% Curve fitting data between Laser displacement and DFT data
% Aligning the two data for curve fitting (removing phase lag)

fc = 25;
fs = 52;
[b,a] = butter(4, fc/(fs/2), 'low');

DFT_33(:,2) = filter(b, a, DFT_33(:,2));
Laser_interp_33 = interp1(Laser_33(:,2),Laser_33(:,1),DFT_33(:,2),'spline');
D = finddelay(DFT_33(:,1),Laser_interp_33);

figure(1); hold on; title('Peano HASEL with 33g load - Trek 5020');
yyaxis left; ylim([min(Laser_interp_33)-0.2, max(Laser_interp_33)+0.2 ]); ylabel('Absolute Displacement (mm)');
plot(DFT_33(abs(D):end-1,2),Laser_interp_33(1:end-abs(D)),':.');

yyaxis right; ylim([min(DFT_33(:,1))-5 max(DFT_33(:,1))+5]); ylabel('DFT output');
plot(DFT_33(abs(D):end-1,2),DFT_33(abs(D):end-1,1));
legend('Laser Displacement data',' Discrete Fourier Data');
xlabel('time (s)'); 

figure(2); hold on
plot(DFT_33(abs(D)+1600:end-1,1), Laser_interp_33(1+1600:end-abs(D)));
xlim([100 220]);
xlabel('DFT value'); ylabel('Absolute Thickness (mm)');
title('DFT - Displacement Relationship');
legend('Peano HASEL with 33g');

Laser_interp_133 = interp1(Laser_133(:,2),Laser_133(:,1),DFT_133(:,2),'spline');
D = finddelay(DFT_133(:,1),Laser_interp_133);

figure(3); hold on; title('Peano HASEL with 133g load - Trek 5020');
yyaxis left; ylim([min(Laser_interp_133)-0.2, max(Laser_interp_133)+0.2 ]); ylabel('Absolute Displacement (mm)');
plot(DFT_133(abs(D):end-1,2),Laser_interp_133(1:end-abs(D)),':.');

yyaxis right; ylim([min(DFT_133(:,1))-5 max(DFT_133(:,1))+5]); ylabel('DFT output');
plot(DFT_133(abs(D):end-1,2),DFT_133(abs(D):end-1,1));
legend('Laser Displacement data',' Discrete Fourier Data');
xlabel('time (s)'); 

figure(2); hold on;
plot(DFT_133(abs(D)+1600:end-1,1), Laser_interp_133(1+1600:end-abs(D)));

Laser_interp_233 = interp1(Laser_233(:,2),Laser_233(:,1),DFT_233(:,2),'spline');
D = finddelay(DFT_233(:,1),Laser_interp_233);

figure(5); hold on; title('Peano HASEL with 233g load - Trek 5020');
yyaxis left; ylim([min(Laser_interp_233)-0.2, max(Laser_interp_233)+0.2 ]); ylabel('Absolute Displacement (mm)');
plot(DFT_233(abs(D):end-1,2),Laser_interp_233(1:end-abs(D)),':.');

yyaxis right; ylim([min(DFT_233(:,1))-5 max(DFT_233(:,1))+5]); ylabel('DFT output');
plot(DFT_233(abs(D):end-1,2),DFT_233(abs(D):end-1,1));
legend('Laser Displacement data',' Discrete Fourier Data');
xlabel('time (s)'); 

figure(2); hold on;
plot(DFT_233(abs(D)+1600:end-1,1), Laser_interp_233(1+1600:end-abs(D)));

Laser_interp_533 = interp1(Laser_533(:,2),Laser_533(:,1),DFT_533(:,2),'spline');
D = finddelay(DFT_533(:,1),Laser_interp_533)+1;

figure(7); hold on; title('Peano HASEL with 533g load - Trek 5020');
yyaxis left; ylim([min(Laser_interp_533)-0.2, max(Laser_interp_533)+0.2 ]); ylabel('Absolute Displacement (mm)');
plot(DFT_533(abs(D):end-1,2),Laser_interp_533(1:end-abs(D)),':.');

yyaxis right; ylim([min(DFT_533(:,1))-5 max(DFT_533(:,1))+5]); ylabel('DFT output');
plot(DFT_533(abs(D):end-1,2),DFT_533(abs(D):end-1,1));
legend('Laser Displacement data',' Discrete Fourier Data');
xlabel('time (s)'); 

figure(2); hold on;
plot(DFT_533(abs(D)+1600:end-1,1), Laser_interp_533(1+1600:end-abs(D)));

Laser_interp_1033 = interp1(Laser_1033(:,2),Laser_1033(:,1),DFT_1033(:,2),'spline');
D = finddelay(DFT_1033(:,1),Laser_interp_1033)+1;

figure(9); hold on; title('Peano HASEL with 1033g load - Trek 5020');
yyaxis left; ylim([min(Laser_interp_1033)-0.2, max(Laser_interp_1033)+0.2 ]); ylabel('Absolute Displacement (mm)');
plot(DFT_1033(abs(D):end-1,2),Laser_interp_1033(1:end-abs(D)),':.');

yyaxis right; ylim([min(DFT_1033(:,1))-5 max(DFT_1033(:,1))+5]); ylabel('DFT output');
plot(DFT_1033(abs(D):end-1,2),DFT_1033(abs(D):end-1,1));
legend('Laser Displacement data',' Discrete Fourier Data');
xlabel('time (s)'); 

figure(2); hold on;
plot(DFT_1033(abs(D)+1600:end-1,1), Laser_interp_1033(1+1600:end-abs(D)));
xlim([40 200]);
xlabel('DFT value'); ylabel('Absolute Thickness (mm)');
title('DFT - Displacement Relationship using Trek 5020');
legend('Peano HASEL with 33g','Peano HASEL with 133g','Peano HASEL with 233g','Peano HASEL with 533g','Peano HASEL with 1033g','location','NorthWest');
