
warning off

% Open audio player
a = audiodevinfo;
%sc = 'HD USB Audio (Core Audio)';
sc = 'Speakers (High Definition Audio Device) (Windows DirectSound)';
device = a.output(find(strcmp({a.output.Name},sc)==1)).ID;
fs = 192000;
bitrate = 24;

% Make sounds
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

% Load audio into buffer and play
b = audioplayer(stim,fs,bitrate,device);
play(b);
