clc;
clear all;
close all;

folder='C:\Users\khoi\Google Drive\education-academics\CU Boulder\Research\NSF CPS Research\Experiments\EMCO C80 Characterization\PSU_Step';
dataLength=2000; % max # of data points possible. For us is 5000
noTests = 8; % number of tests

% initialize variables to store data for each test
% data = NaN(noTests,dataLength,3); % for saving trimmed and filtered input and output voltage and time
riseTime=zeros(2,7,7); 
settlingTime=zeros(2,7,7);
fallTime = zeros(2,7,7);
amplification = zeros(2,7,7);
ssError = zeros(2,7,7); % steady state error: output - input
ssErrorInput = zeros(2,7,7); % steady state error as a percentage of input (out-in)/in
ssErrorOutput = zeros(2,7,7); % steady state error as a percentage of output (out-in)/out
deadTime = zeros(2,7,7);% time for output to reach 10% of its steady state value

for i = 1:3
    for j = 1:7
        for k = 1:7
            
        % Import data from lvm files and store to raw_data
        if i == 1 || i == 2
            data = csvread(strcat('c80_',num2str(300*i-200),'mg_stp_',num2str(j*500),'_',num2str(k),'.csv'),2,0,[2 0 2001 2]);
        else
            data = csvread(strcat('c80_act1_stp_',num2str(j*500),'_',num2str(k+1),'.csv'),2,0,[2 0 2001 2]);
        end
        data(:,3) = data(:,3)*1900;

        % get input V, output V, and time from excel files
        time=data(:,1);
        Vin=data(:,2);
        Vout=data(:,3);

        % apply butterworth filter
        fc = 80; % corner frequency
        fs = 200; % sampling frequency
        [b,a] = butter(6,fc/(fs/2)); % set up butterworth filter
        Vin = filter(b,a,Vin); % filter input voltage
        Vout = filter(b,a,Vout); % filter output voltage
    
%     figure
%     yyaxis left
%     plot(data(:,1),data(:,2));
%     ylim([-0.2 4.5]); ylabel('Input Voltage (V)'); xlabel('Time (s)');
%     hold on
%     yyaxis right
%     plot(data(:,1),data(:,3));
%     ylim([-300 7000]); ylabel('Output Voltage (V)');
%     title (strcat('Step Response of EMCO101 Converter with ',num2str(300*i-200), ' MOhm Load'));
%     legend('Input Voltage (V)','Output Voltage (V)','location','northeast'); saveas(figure(1),'Step demo.jpg');
    
    
        % find indices for beginning and end of step function
        indices=[length(Vin) length(Vin)];% initialize as the last point for logic purposes
        for ii = 2:length(Vin)
            % the beginning of the step function will have:
            % 1) value greater than 0.1
            % 2) be the first time we find a greater value than 0.1
            % 3) the point before it will be smaller because we are looking for
            % a positive slope
            if Vin(ii)>0.1 && indices(1)==length(Vin) && Vin(ii-1)<0.1
                indices(1)=ii-1; % the index of the beginning of the step function
                % will be the current index-1
            end
            % the end of the step function will have:
            % 1) value less than 0.1
            % 2) be the first time we find a value less than 0.1
            % 3) the point before it will be larger because we are looking for
            % a negative slope
            if Vin(ii)<0.1 && indices(2)==length(Vin) && ii>indices(1) && Vin(ii-1)>0.1
                indices(2)=ii-50;% the index of the end of the step function
                % will be the current index-1
            end
        end

        mean(Vout((indices(2)-indices(1))/2+indices(1):indices(2)));
        % find indices at which the fall voltage reaches less than 90% of the
        % amplitude
        for ii = indices(2)+48:length(Vout)
            if Vout(ii) < 0.1*mean(Vout((indices(2)-indices(1))/2+indices(1):indices(2)))
                    fall_indx = ii-1;
                    break
            end
        end
        fallTime(i,j,k) = time(fall_indx)-time(indices(2));

        % trim input voltage, output voltage, and time to match the indices off the step function
        Vin=Vin(indices(1):indices(2));
        Vout=Vout(indices(1):indices(2));
        time=time(indices(1):indices(2))-time(indices(1));

    %     data(mm+1,1:length(Vin),:)=[Vin,Vout,time]; % save Vin, Vout, and time in data

        S = stepinfo(Vout,time); % built-in function characterizes much of the step response

        % calculate various characterization parameters
        settlingTime(i,j,k)=S.SettlingTime;
        riseTime(i,j,k)=S.RiseTime;
        amplification(i,j,k) = mean(Vout((length(Vout)/2):end)/mean(Vin((length(Vin)/2):end)));
        ssError(i,j,k) = mean(Vout((length(Vout)/2):end)-1600*mean(Vin((length(Vin)/2):end)));
        ssErrorInput(i,j,k) = ssError(i,j)/mean(Vin((length(Vin)/2):end)); 
        ssErrorOutput(i,j,k) = ssError(i,j)/mean(Vout((length(Vout)/2):end));
        for ii = 1:length(Vin)      % this loop is for calculating dead time  
            if Vout(ii)>0.1*mean(Vout((length(Vout)/2):end))	% time when output voltage reaches 10% of its steady state value
                deadTime(i,j,k) = time(ii);
                break
            end
        end
        end
    end
end

%% plot findings
close all

mean_Rise = mean(riseTime, 3);
mean_Fall = mean(fallTime, 3);
mean_ssError = mean(ssError, 3);
mean_amplification = mean(amplification, 3);
mean_dead = mean(deadTime, 3);

std_rise = std(riseTime,0,3);
std_Fall = std(fallTime,0,3);
std_ssError = std(ssError,0,3);
std_amplification = std(amplification,0,3);
std_dead = std(deadTime,0,3);


for jj = 1:3
    V = [0.6 1.2 1.8 2.4 3.0 3.6 4.2]; % voltages corresponding to each test
    Legend=cell(3,1);%  two positions 
    Legend{1}='100 Mega Ohm Load' ;
    Legend{2}='400 Mega Ohm Load';
    Legend{3}='BOPP Actuator with 100 Mega Ohm Load';
    
    
    figure(1); errorbar(V,mean_Rise(jj,:),std_rise(jj,:),'*'); grid on; xlabel('Step Input Voltage (V)'); ylabel('Rise Time (s)'); title('Rise Time'); legend(Legend); hold on;
    figure(2); errorbar(V,mean_Fall(jj,:),std_Fall(jj,:),'*'); grid on; xlabel('Step Input Voltage (V)'); ylabel('Fall Time (s)'); title('Fall Time'); legend(Legend); hold on;
    % Settling is not meaningful dueto ripples
%     figure(3); plot(V,settlingTime(jj,:),'*'); xlabel('Step Input Voltage (V)'); ylabel('Settling Time (s)'); title('Settling Time'); legend(Legend,'location','southwest'); hold on;
    figure(3); errorbar(V,mean_amplification(jj,:),std_amplification(jj,:),'*'); grid on; xlabel('Step Input Voltage (V)'); ylabel('Amplification Factor'); title('Amplification'); legend(Legend); hold on;
    figure(4); errorbar(V,mean_ssError(jj,:),std_ssError(jj,:),'*'); grid on; xlabel('Step Input Voltage (V)'); ylabel('Steady state Error (V)'); title('Steady State Error'); legend(Legend); hold on;
%     figure(6); plot(V,ssErrorInput(jj,:),'*'); xlabel('Step Input Voltage (V)'); ylabel('Proportional Steady State Error - Input'); title('Steady State Error, Proportional to Input'); legend(Legend); hold on;
%     figure(7); plot(V,ssErrorOutput(jj,:),'*'); xlabel('Step Input Voltage (V)'); ylabel('Proportional Steady State Error - Output'); title('Steady State Error, Proportional to Output'); legend(Legend); hold on;
    figure(5); errorbar(V,mean_dead(jj,:),std_dead(jj,:),'*'); grid on; xlabel('Step Input Voltage (V)'); ylabel('Dead Time (s)'); title('Dead Time');ylim([0.02 0.1]); legend(Legend); hold on;
    
    for i = 1:5
        figure(i)
        set( gca                       , ...
            'FontName'   , 'Helvetica' );
        set([hTitle, hXLabel, hYLabel, hText], ...
            'FontName'   , 'AvantGarde');
        set([hLegend, gca]             , ...
            'FontSize'   , 8           );
        set([hXLabel, hYLabel, hText]  , ...
            'FontSize'   , 10          );
        set( hTitle                    , ...
            'FontSize'   , 12          , ...
            'FontWeight' , 'bold'      );
    end
end

%% save images
h = get(0,'children');

for i=1:length(h)
    switch i
      case 5
          saveas(h(i), 'Rise Time.epsc');  
      case 4
          saveas(h(i), 'Fall Time.epsc');    
      case 3
          saveas(h(i), 'amplification.epsc');  
      case 2           
          saveas(h(i), 'ssError.epsc');  
      case 1           
          saveas(h(i), 'Dead time.epsc');  
    end
end