clear all;
close all;
clc;

cap_val = [96*10^-12, 192*10^-12, 250*10^-12, 363*10^-12, 460*10^-12, 778*10^-12, 970*10^-12, 1259*10^-12];
drift_val = [ 90.8,  90.9,  89.0,  87.1,  84.0,  83.1;
              113.8, 113.4, 110.2, 105.4, 100.5, 98.5;
              124.1, 124.2, 120.4, 114.1, 107.1, 103.8;
              130.6, 127.8, 120.7, 114.1, 106.9, 103.1;
              147.9, 143.0, 135.5, 126.1, 117.9, 113.9;
              199.9, 196.3, 187.5, 180.9, 170.0, 166.2;
              231.1, 226.3, 210.4, 192.3, 179.0, 173.5;
              255.0, 246.1, 226.5, 207.8, 191.0, 183.9];
voltage = [0 1 2 3 4 4.5];

% Capacitance relationship with baseline drift
P = polyfit(drift_val(:,5),cap_val(:),1);
yfit = P(1)*drift_val(:,5)+P(2);
    
figure(1);
plot(drift_val(:,5), cap_val(:), '*', 'LineWidth',2); hold on;
plot(drift_val(:,5), yfit, 'LineWidth',2);
legend('Baseline DFT and Capacitance values');
xlabel('DFT Baseline Values');
ylabel('Capacitance Values');
title('Capacitance value and DFT Baseline Relationship');

% DFT Drift and EMCO C80 Input Voltage
figure(2);
plot(voltage, drift_val(1,:), 'LineWidth',2); hold on;
plot(voltage, drift_val(2,:), 'LineWidth',2);
plot(voltage, drift_val(3,:), 'LineWidth',2);
plot(voltage, drift_val(4,:), 'LineWidth',2);
plot(voltage, drift_val(5,:), 'LineWidth',2);
plot(voltage, drift_val(6,:), 'LineWidth',2);
plot(voltage, drift_val(7,:), 'LineWidth',2);
plot(voltage, drift_val(8,:), 'LineWidth',2);
legend('96pF Cap','192pF Cap','250pF Cap','363pF Cap','460pF Cap','778pF Cap', '970pF Cap','1259pF Cap');
xlabel('Input Voltage to EMCO C80 (V)');
ylabel('DFT values');
title('HV-dependent DFT values');

% Normalizing data and replot DFT vs EMCO input voltage

drift_norm = zeros(6,6);
for i = 1:1:8
    for j = 1:1:6
        drift_norm(i,j) = ( drift_val(i,j)- min(drift_val(i,:)) ) / ( max(drift_val(i,:)) - min(drift_val(i,:)) );       
    end
end
figure(3);
plot(voltage, drift_norm(1,:), 'LineWidth',2); hold on;
plot(voltage, drift_norm(2,:), 'LineWidth',2);
plot(voltage, drift_norm(3,:), 'LineWidth',2);
plot(voltage, drift_norm(4,:), 'LineWidth',2);
plot(voltage, drift_norm(5,:), 'LineWidth',2);
plot(voltage, drift_norm(6,:), 'LineWidth',2);
plot(voltage, drift_norm(7,:), 'LineWidth',2);
plot(voltage, drift_norm(8,:), 'LineWidth',2);
legend('96pF Cap','192pF Cap','250pF Cap','363pF Cap','460pF Cap','778pF Cap', '970pF Cap','1259pF Cap');
xlabel('Input Voltage to EMCO C80 (V)');
ylabel('DFT values Normalized');
title('HV-dependent DFT Normalized');

P = polyfit(voltage(:)',drift_val(4,:),1);