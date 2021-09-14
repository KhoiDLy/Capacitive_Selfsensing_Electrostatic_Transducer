clc;
close all;
clear all;

DFT_137_20 = csvread('DFT_peanut_137add20g_4pt5V_0pt8V.csv');
Laser_137_20 = csvread('laser_peanut_137add20g_4pt5V_0pt8V.csv');
Laser_137_20(:,1) = (Laser_137_20(:,1))*2;

DFT_137_50 = csvread('DFT_peanut_137add50g_4pt5V_0pt8V.csv');
Laser_137_50 = csvread('laser_peanut_137add50g_4pt5V_0pt8V.csv');
Laser_137_50(:,1) = (Laser_137_50(:,1))*2;

DFT_137_100 = csvread('DFT_peanut_137add100g_4pt5V_0pt8V.csv');
Laser_137_100 = csvread('laser_peanut_137add100g_4pt5V_0pt8V.csv');
Laser_137_100(:,1) = (Laser_137_100(:,1))*2;

DFT_137_120 = csvread('DFT_peanut_137add120g_4pt5V_0pt8V.csv');
Laser_137_120 = csvread('laser_peanut_137add120g_4pt5V_0pt8V.csv');
Laser_137_120(:,1) = (Laser_137_120(:,1))*2;

DFT_137_150 = csvread('DFT_peanut_137add150g_4pt5V_0pt8V.csv');
Laser_137_150 = csvread('laser_peanut_137add150g_4pt5V_0pt8V.csv');
Laser_137_150(:,1) = (Laser_137_150(:,1))*2;

% Truncating the DFT_data to match the range of Laser_disp data
i = 1;
while DFT_137_20(i,2) <= Laser_137_20(end,2)
    i = i+1;
end
DFT_137_20 = DFT_137_20(1:end - (length(DFT_137_20)-i)-1,:);

i = 1;
while DFT_137_50(i,2) <= Laser_137_20(end,2)
    i = i+1;
end
DFT_137_50 = DFT_137_50(1:end - (length(DFT_137_50)-i)-1,:);

i = 1;
while DFT_137_100(i,2) <= Laser_137_100(end,2)
    i = i+1;
end
DFT_137_100 = DFT_137_100(1:end - (length(DFT_137_100)-i)-1,:);

i = 1;
while DFT_137_120(i,2) <= Laser_137_120(end,2)
    i = i+1;
end
DFT_137_120 = DFT_137_120(1:end - (length(DFT_137_120)-i)-1,:);

i = 1;
while DFT_137_150(i,2) <= Laser_137_150(end,2)
    i = i+1;
end
DFT_137_150 = DFT_137_150(1:end - (length(DFT_137_150)-i)-1,:);

% Interpolating data to obtain the laser displacement data corresponding to
% the time stamp of the DFT_data

% Curve fitting data between Laser displacement and DFT data
% Aligning the two data for curve fitting (removing phase lag)

Laser_interp_137_20 = interp1(Laser_137_20(:,2),Laser_137_20(:,1),DFT_137_20(:,2),'spline');
D = finddelay(DFT_137_20(:,1),Laser_interp_137_20)-311;

figure(1); hold on; title('Peanut HASEL with 137+20g load and 0.8V basedline');
yyaxis left; ylim([min(Laser_interp_137_20)-0.2, max(Laser_interp_137_20)+0.2 ]); ylabel('Displacement (mm)');
plot(DFT_137_20(abs(D):end-1,2),Laser_interp_137_20(1:end-abs(D)),':.');

yyaxis right; ylim([min(DFT_137_20(:,1))-5 max(DFT_137_20(:,1))+5]); ylabel('DFT output');
plot(DFT_137_20(abs(D):end-1,2),DFT_137_20(abs(D):end-1,1));
legend('Laser Displacement data',' Discrete Fourier Data');
xlabel('time (s)'); 

figure(2); hold on
plot(DFT_137_20(abs(D):end-1,1), Laser_interp_137_20(1:end-abs(D)));
xlim([100 220]);
xlabel('DFT value'); ylabel('Absolute Thickness (mm)');
title('DFT - Displacement Relationship');
legend('Peanut HASEL with 137+20g');

Laser_interp_137_50 = interp1(Laser_137_50(:,2),Laser_137_50(:,1),DFT_137_50(:,2),'spline');
D = finddelay(DFT_137_50(:,1),Laser_interp_137_50)-330;

figure(3); hold on; title('Peanut HASEL with 137+50g load and 0.8V basedline');
yyaxis left; ylim([min(Laser_interp_137_50)-0.2, max(Laser_interp_137_50)+0.2 ]); ylabel('Displacement (mm)');
plot(DFT_137_50(abs(D):end-1,2),Laser_interp_137_50(1:end-abs(D)),':.');

yyaxis right; ylim([min(DFT_137_50(:,1))-5 max(DFT_137_50(:,1))+5]); ylabel('DFT output');
plot(DFT_137_50(abs(D):end-1,2),DFT_137_50(abs(D):end-1,1));
legend('Laser Displacement data',' Discrete Fourier Data');
xlabel('time (s)'); 

figure(2); hold on;
plot(DFT_137_50(abs(D):end-1,1), Laser_interp_137_50(1:end-abs(D)));

Laser_interp_137_100 = interp1(Laser_137_100(:,2),Laser_137_100(:,1),DFT_137_100(:,2),'spline');
D = finddelay(DFT_137_100(:,1),Laser_interp_137_100)-300;

figure(5); hold on; title('Peanut HASEL with 137+100g load and 0.8V basedline');
yyaxis left; ylim([min(Laser_interp_137_100)-0.2, max(Laser_interp_137_100)+0.2 ]); ylabel('Displacement (mm)');
plot(DFT_137_100(abs(D):end-1,2),Laser_interp_137_100(1:end-abs(D)),':.');

yyaxis right; ylim([min(DFT_137_100(:,1))-5 max(DFT_137_100(:,1))+5]); ylabel('DFT output');
plot(DFT_137_100(abs(D):end-1,2),DFT_137_100(abs(D):end-1,1));
legend('Laser Displacement data',' Discrete Fourier Data');
xlabel('time (s)'); 

figure(2); hold on;
plot(DFT_137_100(abs(D):end-1,1), Laser_interp_137_100(1:end-abs(D)));

Laser_interp_137_120 = interp1(Laser_137_120(:,2),Laser_137_120(:,1),DFT_137_120(:,2),'spline');
D = finddelay(DFT_137_120(:,1),Laser_interp_137_120)-338;

figure(7); hold on; title('Peanut HASEL with 137+120g load and 0.8V basedline');
yyaxis left; ylim([min(Laser_interp_137_120)-0.2, max(Laser_interp_137_120)+0.2 ]); ylabel('Displacement (mm)');
plot(DFT_137_120(abs(D):end-1,2),Laser_interp_137_120(1:end-abs(D)),':.');

yyaxis right; ylim([min(DFT_137_120(:,1))-5 max(DFT_137_120(:,1))+5]); ylabel('DFT output');
plot(DFT_137_120(abs(D):end-1,2),DFT_137_120(abs(D):end-1,1));
legend('Laser Displacement data',' Discrete Fourier Data');
xlabel('time (s)'); 

figure(2); hold on;
plot(DFT_137_120(abs(D):end-1,1), Laser_interp_137_120(1:end-abs(D)));


Laser_interp_137_150 = interp1(Laser_137_150(:,2),Laser_137_150(:,1),DFT_137_150(:,2),'spline');
D = finddelay(DFT_137_150(:,1),Laser_interp_137_150)-244;

figure(9); hold on; title('Peanut HASEL with 137+150g load and 0.8V basedline');
yyaxis left; ylim([min(Laser_interp_137_150)-0.2, max(Laser_interp_137_150)+0.2 ]); ylabel('Displacement (mm)');
plot(DFT_137_150(abs(D):end-1,2),Laser_interp_137_150(1:end-abs(D)),':.');

yyaxis right; ylim([min(DFT_137_150(:,1))-5 max(DFT_137_150(:,1))+5]); ylabel('DFT output');
plot(DFT_137_150(abs(D):end-1,2),DFT_137_150(abs(D):end-1,1));
legend('Laser Displacement data',' Discrete Fourier Data');
xlabel('time (s)'); 

figure(2); hold on;
plot(DFT_137_150(abs(D):end-1,1), Laser_interp_137_150(1:end-abs(D)));
xlim([100 220]);
xlabel('DFT value'); ylabel('Absolute Thickness (mm)');
title('DFT - Displacement Relationship');
legend('Peanut HASEL with 137+20g','Peanut HASEL with 137+50g','Peanut HASEL with 137+100g','Peanut HASEL with 137+120g','Peanut HASEL with 137+150g','location','NorthWest');
