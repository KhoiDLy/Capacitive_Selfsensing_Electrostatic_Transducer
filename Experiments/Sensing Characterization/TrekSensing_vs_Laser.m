%% Preliminary Sensor Characterization
clc; clear all; close all;

filename1 = 'test_1_full_stroke_trek.xlsx';
sheet = 1;
xlRange = 'B2:B2155';
test1_trek = xlsread(filename1,sheet,xlRange);

filename2 = 'test_1_full_stroke.csv';
sheet = 1;
xlRange = 'C1:C3500';
test1_laser = xlsread(filename2,sheet,xlRange);

filename3 = 'test_2_high_load_trek.xlsx';
sheet = 1;
xlRange = 'B2:B1773';
test2_trek = xlsread(filename3,sheet,xlRange);

filename4 = 'test_2_high_load.csv';
sheet = 1;
xlRange = 'C1:C2635';
test2_laser = xlsread(filename4,sheet,xlRange);

filename5 = 'test_3_varying_signal_200g_trek.xlsx';
sheet = 1;
xlRange = 'B2:B4355';
test3_trek = xlsread(filename5,sheet,xlRange);

filename6 = 'test_3_varying_signal_200g.csv';
sheet = 1;
xlRange = 'C1:C6770';
test3_laser = xlsread(filename6,sheet,xlRange);

filename7 = 'test_4_varying_signal_25g_trek.xlsx';
sheet = 1;
xlRange = 'B2:B7455';
test4_trek = xlsread(filename7,sheet,xlRange);

filename8 = 'test_4_varying_signal_25g.csv';
sheet = 1;
xlRange = 'C1:C10000';
test4_laser = xlsread(filename8,sheet,xlRange);

%%
f1 = figure(1)
yyaxis left; plot(test1_laser(500:3000));
xlabel('Time step (no unit)'); ylabel('Laser Displacement (mm)'); hold on; 
yyaxis right; plot(test1_trek(50:2000)); ylabel('Relative Capacitance');
title('Donut Actuation Under no Load- HV 0 to 9kV');
saveas(f1,'figure 1.jpeg');
f2 = figure(2)
yyaxis left; plot(test2_laser(50:2000));
xlabel('Time step (no unit)'); ylabel('Laser Displacement (mm)'); hold on; 
yyaxis right; plot(test2_trek(50:1700)); ylabel('Relative Capacitance');
title('Donut Actuation Very High Load - HV 0 to 9kV');
saveas(f2,'figure 2.jpeg');

f3 = figure(3)
yyaxis left; plot(test3_laser(200:6500));
xlabel('Time step (no unit)'); ylabel('Laser Displacement (mm)'); hold on; 
yyaxis right; plot(test3_trek(200:4300)); ylabel('Relative Capacitance');
title('Donut Actuation varying kV, 200g Load');
saveas(f3,'figure 3.jpeg');

f4 = figure(4)
yyaxis left; plot(test4_laser(200:8000));
xlabel('Time step (no unit)'); ylabel('Laser Displacement (mm)'); hold on; 
yyaxis right; plot(test4_trek(200:5500)); ylabel('Relative Capacitance');
title('Donut Actuation varying kV, 25g Load');
saveas(f4,'figure 4.jpeg');
