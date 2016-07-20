function [s,fs] = setupNidaq(ch,fs)

if nargin < 2
    fs = 192e3;
    if nargin < 1
        ch = 0;
    end
end

s = daq.createSession('ni');
addAnalogOutputChannel(s,'dev1',ch,'Voltage');
s.Rate = fs;
fs = s.Rate;