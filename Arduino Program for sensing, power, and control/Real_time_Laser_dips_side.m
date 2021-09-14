clear all;
close all;
clc;

s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev1', 'ai0', 'Voltage');

s.Rate = 100;

s.DurationInSeconds = 20;
addTriggerConnection(s,'external', 'Dev1/PFI1','StartTrigger');
s.ExternalTriggerTimeout = inf;
connection = s.Connection(1);
connection.TriggerCondition = 'FallingEdge'

[data,timeStamp,triggerTime] = s.startForeground;
plot(time,data);
xlabel('Time (secs)');
ylabel('Voltage');

Storage = zeros(length(data),2);
Storage(:,1) = data; Storage(:,2) = timeStamp;
csvwrite('Laser Displacement data.csv',Storage);


