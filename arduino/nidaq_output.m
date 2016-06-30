s = daq.createSession('ni');
addAnalogOutputChannel(s,'dev1','ao0','Voltage');
s.Rate = 400e3;
fs = s.Rate;

pad = fs * .1;
eventLength = .01 * fs;
stimDur = 1 * fs;
noise = rand(1,stimDur)/3;
noise = noise - mean(noise);
sound = [noise zeros(1,pad)];
event = [ones(1,eventLength) ...
         zeros(1,stimDur - eventLength) ...
         ones(1,eventLength) zeros(1,pad - eventLength)] * 3.3;
stim = [sound; event];
plot(stim');


queueOutputData(s,stim(2,:)');
startBackground(s);

