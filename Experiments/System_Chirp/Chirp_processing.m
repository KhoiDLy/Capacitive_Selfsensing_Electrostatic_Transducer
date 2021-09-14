clear all;
close all
clc;

for j = 1:2
    figure(j);
    mycolor = jet(4);
    for i = 1:4
        if i < 3 && j == 1
            m = readtable(['Chirp_3kVoff_3kVamp_0.0001_10Hz_peano_103g_v' num2str(i) '.txt']);
            A = table2array(m);
            yyaxis right
            plot(A(:,1),A(:,3), 'color',mycolor(i,:)); hold on
        elseif i >=3 && j == 1
            m = readtable(['Chirp_3.5kVoff_2.5kVamp_0.0001_10Hz_peano_103g_v' num2str(i-2) '.txt']);
            A = table2array(m);
            yyaxis right
            plot(A(:,1),A(:,3), 'color',mycolor(i,:));
            
        elseif i <3 && j == 2
            m = readtable(['Chirp_3kVoff_3kVamp_10_0.0001Hz_peano_103g_v' num2str(i) '.txt']);
            A = table2array(m);
            yyaxis right
            plot(A(:,1),A(:,3), 'color',mycolor(i,:)); hold on
            
        elseif i >= 3 && j == 2
            m = readtable(['Chirp_3.5kVoff_2.5kVamp_10_0.0001Hz_peano_103g_v' num2str(i-2) '.txt']);
            A = table2array(m);
            yyaxis right
            plot(A(:,1),A(:,3), 'color',mycolor(i,:)); hold on
            
        end
    end

    yyaxis left
    plot(A(:,1),A(:,2)); hold on

    legend('Input Voltage','3kVoff 3kVamp v1','3kVoff 3kVamp v2','3.5kVoff 2.5kVamp v1','3.5kVoff 2.5kVamp v2');
    title('Raw Chirp Data: Input voltage and Displacement of Peano Actuator');
    xlabel('Time (s)');
    ylabel('Voltage input to EMCO C80 (V)');

    yyaxis right
    ylabel('Displacement (mm)');
end

for i = 3:5
    figure(i);
    m = readtable(['Rand_3kVoff_3kVamp_peano_103g_v' num2str(i-2) '_stepsize_200.txt']);
    A = table2array(m);
    
    yyaxis left
    plot(A(:,1),A(:,2));    
    yyaxis right
    plot(A(:,1),A(:,3), 'r'); hold on


    legend('Input Voltage',['3kVoff 3kVamp v' num2str(i-2)]);
    title('Raw Random Data: Input voltage and Displacement of Peano Actuator');
    xlabel('Time (s)');
    ylabel('Voltage input to EMCO C80 (V)');

    yyaxis right
    ylabel('Displacement (mm)');
end

%% Obtaining the bode diagram from measured data:

m = readtable(['Chirp_3.5kVoff_2.5kVamp_0.0001_10Hz_peano_103g_v' num2str(1) '.txt']);
A = table2array(m);
            
L=length(A); %length of the signal
Fs=1000;%sampling frequency
N=2^nextpow2(L);%scale factor
t= A(:,1);%time domain array
f=linspace(0,Fs/2,length(t));%frequency domain array 
FFT=abs(fft(A(:,2),N)/L);                                   % Divide By ‘L’ To Scale For Signal Vector Length
figure(10)
plot(f(1:1000),FFT(1:1000)*2)         
