clc;
clear all;
close all;

data1 = csvread('20mHz_amp_1V_off_2V_smhole_1.csv');
data1(:,2) = data1(:,2) - data1(1,2);
data1(:,1) = detrend(data1(:,1));
data2 = lvm_import('20mHz_amp_1V_off_2V_smallhole_1.lvm');

figure(1)
subplot(2,1,1)
plot(data1(:,2),data1(:,1));
subplot(2,1,2)
plot(data2.Segment1.data(:,1), data2.Segment1.data(:,2));

data1 = csvread('50mHz_amp_1V_off_2V_smhole_1.csv');
data1(:,2) = data1(:,2) - data1(1,2);
data1(:,1) = detrend(data1(:,1));
data2 = lvm_import('50mHz_amp_1V_off_2V_smallhole_1.lvm');

figure(2)
subplot(2,1,1)
plot(data1(:,2),data1(:,1));
subplot(2,1,2)
plot(data2.Segment1.data(:,1), data2.Segment1.data(:,2));