% start nidaq
params.comPort  = 'COM8';
params.fsTarget = 400e3;
disp('STARTING NIDAQ');
[n, params.fsActual] = setupNI_analog([0 1], params.fsTarget);
n.IsContinuous = false;

% stimulus parameters
params.filt         = load('SMALL_BOOTH_FILT_70dB_200-9e3kHZ');
params.filt         = params.filt.filt;
params.toneF        = 10e3;
params.toneD        = 25e-3;
params.baseNoiseD   = 3;
params.noiseD       = [.05 .1 .25 .5 1 2 4 9] + params.baseNoiseD;
params.dbSteps      = linspace(0,-15,6); %linspace(0,-20,5);
params.dB           = 70 + params.dbSteps;
params.amp70        = .1;
params.toneA        = params.amp70 .* 10 .^ (params.dbSteps./20);
params.noiseA       = 1;
params.rampD        = .005;
params.nTones       = 34;
params.freqs        = 10^3 * (2 .^ (([0:params.nTones-1])/6)); % this is n freqs spaced 1/6 octave apart
params.mu           = 50;
params.sd           = [15 5];
params.chordDuration = .025;
params.nNoiseExemplars = 10;


% make noise
noise = makeDRC(params.fsActual,params.rampD,params.chordDuration,[3 2],...
                params.freqs,params.mu,params.sd,params.amp70, ...
                params.filt);
for i = 1:length(params.toneA)
    % Make tones
    tmp = makeTone(params.fsActual,params.toneF,params.toneD,...
        params.toneA(i),5,4,params.rampD,params.filt);
    tone{i} = [tmp zeros(1,.02*Fs)];
    
    % Queue and play
    queueOutputData(n,[(noise+tone{i})'*10 ...
        zeros(1,length(noise))'*5]);
    startForeground(n);
end
    