function [stim, t] = makeStim(fs,f,sd,nd,srms,nrms,ramp)

% Make ramp
r = genRamp(fs,ramp);

% Make noise
nr = [r ones(1,nd*fs) fliplr(r)];
noise = rand(1,(nd + (2*ramp))*fs);
noise = noise - mean(noise);
noise = noise * (nrms/rms(noise));
noiseOnly = noise .* nr;

% Make signal
sr = [r ones(1,sd*fs) fliplr(r)];
signal = genTone(fs,f,sd + 2*ramp,1);
signal = signal * (srms/rms(signal));
signal = signal .* sr;

% Combine them (assuming signal goes on at the end end)
signalOnly = [zeros(1,length(noiseOnly)-length(signal)) signal];
stim = signalOnly + noiseOnly;

% Add event pulses
pulseWidth = .01;
pulseMagnitude = 5;
pad = .01;
events = zeros(1,length(stim) + (pad + pulseWidth)*fs);
events(1:pulseWidth * fs) = 1;
events(end-(pad+pulseWidth)*fs+1:end-pad*fs) = 1;

stim = [stim zeros(1,(pad+pulseWidth)*fs); events * pulseMagnitude];
t = (1:length(stim)) / fs;

%  hold on
%  plot(t,stim);
%  plot([ramp ramp], ylim,'k');
%  plot([nd/2 + ramp nd/2 + ramp], ylim,'k');
%  plot([nd + ramp nd + ramp],ylim,'k');