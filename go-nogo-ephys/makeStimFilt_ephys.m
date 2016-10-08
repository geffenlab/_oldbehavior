function [stim, events, t] = makeStimFilt_ephys(fs,f,sd,nd,samp,namp,ramp,Filt)
% Make ramp
r = make_ramp(ramp*fs);

% Make noise
nr = [r ones(1,round((nd - (2*ramp))*fs)) fliplr(r)];
noise = randn(1,length(nr))./ sqrt(2) ./ 10;
noiseOnly = noise .* nr * namp;
noiseF = conv(noiseOnly,Filt,'same');

% Make signal
sr = [r ones(1,round((sd - (2*ramp))*fs)) fliplr(r)];
signal = genTone(fs,f,sd,1);
signal = signal .* sr * samp;

% Combine them (assuming signal goes on at the end of preceding noise
% and that there is at least 1s of noise at the end)
signal = [zeros(1,round((nd-1)*fs)) signal];
signalOnly = [signal zeros(1,length(noiseOnly)-length(signal))];
signalF = conv(signalOnly,Filt,'same');
stim = signalF + noiseF;

% clf
% hold on
% plot(noiseF)
% plot(signalF)
% hold off

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