% This script compare the ripples magnitude and frequency using FFT for three different types of 
% Power supply: EMCO Q101, EMCO C80, and PICO 5VV10
clc;
clear all;
close all;
folder='E:\Google Drive\education-academics\CU Boulder\Research\NSF CPS Research\Capacitance Sensing and Control of HASEL\Experiments\PSU ripples\';
mag_array = zeros(3,4);
freq_array  = zeros(3,4);

Fs = 400000;  % Sampling rate
T = 1/Fs;     % Sampling period 
%%
for i = 1:3
    for j = 1:4
        switch i
            case 1
                volt_data = lvm_import(strcat(folder,'Q101_Ripple_',num2str(j*2),'kV.lvm'));               
            case 2
                volt_data = lvm_import(strcat(folder,'C80_Ripple_',num2str(j*2),'kV.lvm'));
            case 3
                volt_data = lvm_import(strcat(folder,'5VV10_Ripple_',num2str(j*2),'kV.lvm'));
        end
        
        % The resistive divider ratio is 1704.767 (R1 = 199MEG, R2 = 116.8k)
        volt_data.Segment1.data(:,2) = 1704.767*volt_data.Segment1.data(:,2);
        
        %Remove DC offset
        volt_data.Segment1.data(:,2) = detrend(volt_data.Segment1.data(:,2),0);
             
        L = length(volt_data.Segment1.data);             % Length of signal
        t = (0:L-1)*T;

        Y1 = fft(volt_data.Segment1.data(:,2));
        P2_1 = abs(Y1)/L; % Normalization to make the amplitude of the FFT matches with the sine wave amplitude
        P1_1 = P2_1(1:L/2+1);
        P1_1(2:end-1) = 2*P1_1(2:end-1);

        f = Fs*(0:(L/2))/L;
        
        figure(j)
        hold on;
        plot(P1_1, 'LineWidth',2);
        xlim([0 2*10^4]);
        
        c={' '};
        hTitle = title(strcat('High Voltage Ripple Amplitude Spectrum at',c,num2str(j*2),' kV'));
        hXLabel = xlabel('Ripple Frequency (Hz) '                        );
        hYLabel = ylabel('Ripple Amplitude (V)'                   ); 
                
        hLegend = legend( ...
        'EMCO Q101'                      , ...
        'EMCO C80'                       , ...
        'PICO 5VV10'                     , ...
        'location', 'NorthEast' );

        set( gca                       , ...
            'FontName'   , 'Helvetica' );
        set([hTitle, hXLabel, hYLabel ], ...
            'FontName'   , 'AvantGarde');
        set([hLegend, gca]             , ...
            'FontSize'   , 8           );
        set([hXLabel, hYLabel]  , ...
            'FontSize'   , 10          );
        set( hTitle                    , ...
            'FontSize'   , 12          , ...
            'FontWeight' , 'bold'      );

        set(gca, ...
          'Box'         , 'off'     , ...
          'TickDir'     , 'out'     , ...
          'TickLength'  , [.02 .02] , ...
          'XMinorTick'  , 'on'      , ...
          'YMinorTick'  , 'on'      , ...
          'YGrid'       , 'on'      , ...
          'GridLineStyle', '--'     , ...
          'GridAlpha'   , 0.2       , ...
          'XColor'      , [.3 .3 .3], ...
          'YColor'      , [.3 .3 .3], ...
          'LineWidth'   , 1         );
    end
end

figure(1);
set(gcf, 'PaperPositionMode', 'auto'); 
print -opengl -dsvg 2kVspectrum.svg 

figure(2);
set(gcf, 'PaperPositionMode', 'auto'); 
print -opengl -dsvg 4kVspectrum.svg 

figure(3);
set(gcf, 'PaperPositionMode', 'auto'); 
print -opengl -dsvg 6kVspectrum.svg 

figure(4);
set(gcf, 'PaperPositionMode', 'auto'); 
print -opengl -dsvg 8kVspectrum.svg 
