function signalF = makeTone(fs,f,sd,samp,nd,offset,ramp,Filt)

% function signalF = makeTone(fs,f,sd,samp,nd,offset,ramp,Filt)
% This function makes filtered sine tones of particular duration, amplitude.
% The goal is to embed this tone within a noise burst, so it also takes the
% duration of the noise as a parameters.
%
% fs        = samplerate
% f         = tone frequency
% sd        = tone duration (including ramps)
% nd        = noise duration to embed in
% offset    = relative to the start of the noise, where does the tone start
% ramp      = ramp duration
% Filt      = filter to control dB level

% Make ramp
r = make_ramp(ramp*fs);

% Make tone
sr = [r ones(1,round((sd - (2*ramp))*fs)) fliplr(r)];
signal = genTone(fs,f,sd,1);
signal = signal .* sr * samp;
signal = [zeros(1,round((offset)*fs)) signal];
signalOnly = [signal zeros(1,(fs*nd)-length(signal))];
signalF = conv(signalOnly,Filt,'same');