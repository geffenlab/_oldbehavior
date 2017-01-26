 function runGONOGO(id)
delete(instrfindall)

if nargin < 1
    id = 999;
end

% Data parameters
params.ID = ['CA' sprintf('%03d',id)];
params.sessID = datestr(now,'YYmmDDhhMM');
params.dir = [pwd filesep 'data' filesep params.ID];
params.fn = [params.ID '-' params.sessID];
params.fullFile = [params.dir filesep params.fn '.txt'];
params.mat = [params.dir filesep params.fn '.mat'];

% Presentation parameters
params.targetFs = 400e3;
params.signalF = 10e3;
params.signalDur = 1;
params.noiseDur = 1;
params.signalRMS = .1;
params.noiseRMS = .1;
params.rampDur = .01;
params.ITI = 0.5;

% Task parameters
params.port = 'COM8';
params.holdTime = 2;
params.respWin = 1.2;
params.rewDur = .1;
params.timeoutDur = 7;

if ~exist(params.dir,'dir')
    mkdir(params.dir);
end

GONOGO_training(params);



