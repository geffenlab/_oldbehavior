function runGONOGO(ID,stage)
delete(instrfindall)
close all
clearvars -except ID stage

if nargin < 2
    stage = 0;
elseif nargin < 1
    ID = 999;
end

% directory stuff:
params.ID       = ID;
params.IDstr    = sprintf('CA%03d',ID);
params.IDsess   = [params.IDstr '_' datestr(now,'yymmddHHMM')];
params.base     = pwd;
params.data     = [pwd filesep 'data' filesep params.IDstr];
params.hex      = [pwd filesep '_hex'];
params.stage    = stage;
params.fn       = [params.data filesep params.IDsess];
if ~exist(params.data,'dir')
    mkdir(params.data);
end

% start serial port and nidaq
params.comPort  = 'COM6';
params.fsTarget = 400e3;
disp('STARTING NIDAQ');
[params.n, params.fsActual] = setupNI_analog([0 1], params.fsTarget);
disp('STARTING SERIAL');
params.s = setupSerial(params.comPort);
params.n.IsContinuous = false;

% stimulus parameters
params.filt     = load('SMALL_BOOTH_FILT_70dB_200-9e3kHZ');
params.toneF    = 10e3;
params.toneD    = 1;
params.noiseD   = [0 .1 .5 1 2];
params.dbSteps  = linspace(0,-20,5);
params.dB       = 70 + params.dbSteps;
params.amp70    = .1;
params.toneA    = params.amp70 .* 10 .^ (params.dbSteps./20);
params.noiseA   = 1;
params.rampD    = .05;

% task parameters
params.holdD    = 1.5;
params.rewardD  = 0.1;
params.respD    = 1.2;
params.timeoutD = 7.0;

% go into task sequence
cnt = 0;
while cnt <= length(stage)
    cnt = cnt + 1;
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
    end
end

delete(s);



