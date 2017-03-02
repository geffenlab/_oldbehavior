function runGONOGO(ID,stage)
close all
clearvars -except ID stage
delete(instrfindall)

%try
    
    if nargin < 2
        stage = 0;
    end
    if nargin < 1
        ID = 'CA999';
    end
    
    % directory stuff:
    params.IDstr    = ID;
    params.IDsess   = [params.IDstr '_' datestr(now,'yymmddHHMM')];
    params.base     = pwd;
    params.data     = [pwd filesep 'data' filesep params.IDstr];
    params.hex      = [pwd filesep '_hex'];
    params.stage    = stage;
    params.fn       = [params.data filesep params.IDsess];
    if ~exist(params.data,'dir')
        mkdir(params.data);
    end
    params.stim = 'C:\stimuli\gainBehavior\170202_stim.mat';
    
    % start nidaq
    params.comPort  = 'COM8';
    params.fsTarget = 400e3;
    disp('STARTING NIDAQ');
    [params.n, params.fsActual] = setupNI_analog([0 1], params.fsTarget);
    params.n.IsContinuous = false;
    
    % stimulus parameters
    params.filt         = load('SMALL_BOOTH_FILT_70dB_200-9e3kHZ');
    params.filt         = params.filt.filt;
    params.toneF        = 15e3;
    params.toneD        = 25e-3;
    params.baseNoiseD   = 3;
    params.noiseD       = [.05 .1 .25 .5 1 2 4 9] + params.baseNoiseD;
    params.dbSteps      = [5 linspace(0,-15,6)]; %linspace(0,-20,5);
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
    params.postTargetTime = 1;
    
    % task parameters
    params.holdD    = 1.5;
    params.rewardD  = 0.0125;
    params.respD    = 1.2;
    params.timeoutD = 7.0;
    
    % go into task sequence
    cnt = 1;
    while cnt <= length(stage)
        switch stage(cnt)
            case 0
                disp('RUNNING HABITUATION');
                Habituation(params);
            case 1
                disp('RUNNING TRAINING');
                Training(params);
            case 2
                disp('RUNNING TESTING');
                Testing(params);
            case 3
                disp('RUNNING VARIABLE NOISE');
                testingVarOffsets(params);
        end
        cnt = cnt + 1;
    end
    
    close('all')
    clear all
    
% catch err
%     rethrow(err);
%     keyboard
%     
%     delete(s);
%     close('all')
%     clear all
% end



