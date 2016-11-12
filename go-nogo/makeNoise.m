function [noiseF, events] = makeNoise(fs,nd,namp,ramp,Filt)

% function [noiseF, events] = makeNoise(fs,nd,namp,ramp,Filt)
% This function makes a random, filtered noise burst of a particular
% duration and amplitude. It also creates an event vector showing when this
% noise burst starts and ends.
%
% fs = samplerate
% nd = noise duration
% namp = noise amplitude
% ramp = ramp duration
% Filt = filter to control dB level

% Make ramp
r = make_ramp(ramp*fs);

% Make noise
nr = [r ones(1,round((nd - (2*ramp))*fs)) fliplr(r)];
noise = randn(1,length(nr))./ sqrt(2) ./ 10;
noiseOnly = noise .* nr * namp;
noiseF = conv(noiseOnly,Filt,'same');

% clf
% hold on
% plot(noiseF)
% hold off

% Add event pulses
pulseWidth = .01;
pulseMagnitude = 5;
pad = .01;
events = zeros(1,length(noiseF) + (pad + pulseWidth)*fs);
events(1:pulseWidth * fs) = 1;
events(end-(pad+pulseWidth)*fs+1:end-pad*fs) = 1;
events = events * pulseMagnitude;

% Pad noise to make the same length as events vector
noiseF = [noiseF zeros(1,length(events)-length(noiseF))];

%  hold on
%  plot(t,stim);
%  plot([ramp ramp], ylim,'k');
%  plot([nd/2 + ramp nd/2 + ramp], ylim,'k');
%  plot([nd + ramp nd + ramp],ylim,'k');