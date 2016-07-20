 function runGONOGO(id)

if nargin < 1
    id = 999;
end

% Parameters
params.ID = ['CA' sprintf('%03d',id)];
params.sessID = datestr(now,'YYmmDDhhMM');
params.dir = [pwd filesep 'data' filesep params.ID];
params.fn = [params.ID '-' params.sessID];
params.fullFile = [params.dir filesep params.fn '.txt'];
params.mat = [params.dir filesep params.fn '.mat'];
params.port = 'COM6';

if ~exist(params.dir,'dir')
    mkdir(params.dir);
end

GONOGO_training(params);



