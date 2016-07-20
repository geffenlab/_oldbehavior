function [n,fs] = setupNI_analog(channel,fs)

devices = daq.getDevices;
n = daq.createSession('ni');
for i = 1:length(channel)
    addAnalogOutputChannel(n,'Dev1',channel(i),'Voltage');
end
n.Rate = fs;

end