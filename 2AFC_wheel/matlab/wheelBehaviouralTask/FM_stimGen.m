% Generate a frequency modulated tone of average freq (carrierFreq, Hz), with modulation rate (fModRate, Hz) and modulation depth of (fModDepth, Hz) of specified duration (sec). If want amplitude modulation, enter a modulation rate (aModRate, Hz).
function wave = FM_stimGen(sampleRate,carrierFreq,fModRate,duration,fModDepth, varargin)

nVarargs = length(varargin);
% clear
% Variables to set
% sampleRate = 200000; % sample rate
% carrierFreq = 65000; % Carrier Frequency
phi = 3*pi/2; % phase of the carrier frequency, can change this to vary phase that the stimulus starts from
% fModRate = 20; % modulation rate
% duration =0.1; % in seconds
% fModDepth = 5000; % frequency depthof the modulation in Hz
% AM = 0; % change to 1 if you also want AM moduation


% make time vector
t = 1/sampleRate:1/sampleRate:duration;  % time

% use Isacc's magic code
freq = sin(2*pi*fModRate*t'+phi)*fModDepth+carrierFreq;
fa = ones(1,length(freq));
% fa = linspace(fd,-fd,length(freq)); % to add a upward or downward sweep
freq2 = freq+fa';
amp = ones(1,length(freq));
wave = vary_pure_tone( amp, freq2'/sampleRate );

if nVarargs>0
    aModRate = varargin{1};
    am = tone(aModRate,2*pi,duration,sampleRate);
    wave = wave.*am;
end

% figure; spectrogram(wave,200,20,1000,sampleRate,'yaxis');







