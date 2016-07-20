function parseLog(params)

fid = fopen(params.fullFile,'r');
C = textscan(fid,'%f %s');
fclose(fid);
times = C{1};
events = C{2};

% Get trial indices
x = regexp(events,'TT');
tind = find(~cellfun(@isempty,x));
tind(end+1) = length(x);

% for each trial:
for i = 1:length(tind)-1
    tmpTimes = times(tind(i):tind(i+1)-1);
    tmpEvents = events(tind(i):tind(i+1)-1);
    
    if ~isempty(tmpTimes)
        t(i).lickTimes = tmpTimes(strcmp(tmpEvents,'LICK'));
        t(i).trialTimes = [tmpTimes(strcmp(tmpEvents,'TON'))
            tmpTimes(strcmp(tmpEvents,'TOFF'))];
        t(i).stimTimes = [tmpTimes(strcmp(tmpEvents,'STIMON'))
            tmpTimes(strcmp(tmpEvents,'STIMOFF'))];
        t(i).respWin = [tmpTimes(strcmp(tmpEvents,'STIMOFF'))
            tmpTimes(strcmp(tmpEvents,'RESPOFF'))];
        t(i).rewardTimes = [tmpTimes(strcmp(tmpEvents,'REWARDON'))
            tmpTimes(strcmp(tmpEvents,'REWARDOFF'))];
        t(i).toStart = [tmpTimes(strcmp(tmpEvents,'TOSTART'))
            tmpTimes(strcmp(tmpEvents,'TOEND'))];
        t(i).trialType = tmpEvents{1};
        
        trialType(i) = char(str2num(tmpEvents{1}(end-1:end)));
        response(i) = any(t(i).lickTimes > t(i).respWin(1) & t(i).lickTimes < t(i).respWin(2));
    end
end

trialType = strcmp('SIGNALTRIAL',{t.trialType});

fprintf('Saving .mat file...\n');
save(params.mat,'t','trialType','response','params');

