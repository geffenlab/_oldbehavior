function [stim, events, t] = makeStimFilt_ephys(fs,f,sd,nd,samp,namp,ramp,Filt)

% Make ramp
r = make_ramp(ramp*fs);

% Make noise
nr = [r ones(1,round(nd*fs)) fliplr(r)];
noise = randn(1,round((nd + (2*ramp))*fs))./ sqrt(2) ./ 10;
noiseOnly = noise .* nr * namp;
noiseF = filter(Filt,1,noiseOnly);

% Make signal
sr = [r ones(1,sd*fs) fliplr(r)];
signal = genTone(fs,f,sd + 2*ramp,1);
signal = signal .* sr * samp;

% Combine them (assuming signal goes on at the end of preceding noise
% and that there is at least 1s of noise at the end)
signal = [zeros(1,round((nd-1)*fs)) signal];
signalOnly = [signal zeros(1,length(noiseOnly)-length(signal))];
signalF = filter(Filt,1,signalOnly);
stim = signalF + noiseF;

clf
hold on
plot(noiseOnly)
plot(signalOnly)
hold off
keyboard

% Add event pulses
pulseWidth = .01;
pulseMagnitude = 5;
pad = .01;
events = zeros(1,length(stim) + (pad + pulseWidth)*fs);
events(1:pulseWidth * fs) = 1;
events(end-(pad+pulseWidth)*fs+1:end-pad*fs) = 1;

stim = [stim zeros(1,(pad+pulseWidth)*fs)];
events = events * pulseMagnitude;
t = (1:length(stim)) / fs;

%  hold on
%  plot(t,stim);
%  plot([ramp ramp], ylim,'k');
%  plot([nd/2 + ramp nd/2 + ramp], ylim,'k');
%  plot([nd + ramp nd + ramp],ylim,'k');