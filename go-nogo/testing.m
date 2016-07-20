function [ts,trialType] = Testing(comport,fs,mouseID)

delete(instrfindall)
KbName('UnifyKeyNames');

if ~exist('mouseID','var')
    mouseID = 999;
end

%Load corresponding Arduino sketch
[status, cmdOut] = loadArduinoSketch(comport,'Training');
disp(cmdOut)

%Establish connections
[s] = setupSerial(comport);
[n,Fs] = setupNI_analog([0,1],fs);
n.IsContinuous = false;

%Load Filter
FILT = load('SMALL_BOOTH_FILT_70dB_200-9e3kHZ');

%Set path for file by MouseNumber and Date, Save and write .txt File
time = datestr(now,'ddmmyyHHMMss');
datDir = sprintf('C:\\Users\\geffen-behaviour2\\Dropbox\\GeffenLab\\Nitay\\Data\\Testing\\%03d',mouseID);
if ~exist(datDir,'dir')
    mkdir(datDir);
end
fileGoto = sprintf('%s\\%03d_%s.txt',datDir,mouseID,time);
fn = fopen(fileGoto,'w');

%Send setup() variables to arduino
patientWait = 1.5;
rewardDur = 0.1;
responseDur = 1.2;
timeoutDur = 7.0;
varvect = [patientWait rewardDur responseDur timeoutDur];
fprintf(s,'%f %f %f %f ',varvect);

%Variables
t                   = 0;
ts                  = {};
timeoutState        = 0;
rewardState         = 0;

% Make stimuli
f           = 10e3;
sd          = 1;
nd          = [1];
dbSteps     = linspace(0,-20,5); % -5 to -20
dB          = 70 + dbSteps;
samp        = .1 .* 10 .^ (dbSteps./20);
namp        = 1;
rd          = .01;
durProbs    = [ones(1,length(nd)) ./ length(nd)];
dbProbs     = [.5 ones(1,length(dbSteps)) ./ (2*(length(dbSteps)))];

%Preallocate stimulus package
stim = cell(length(nd),length(samp)+1);
events = cell(length(nd),1);

fprintf('\nBuilding Stimuli...')

for i = 1:length(nd)
    %column 1 noise only
    [stim{i,1},events{i,1}] = makeStimFilt(Fs,f,sd,nd(i),0,namp,rd,FILT.filt);
    
    %columns 2:end
    for j = 1:length(samp)
        stim{i,j+1} = makeStimFilt(Fs,f,sd,nd(i),samp(j),namp,rd,FILT.filt);
    end
    fprintf('.')
end


fprintf('\nPress any key to start.');
pause;


taskState = 0;
disp(' ');
lickCount = [];
%%Task
while 1
    
    switch taskState
        
        case 0 %proceed when arduino signals (2s no licks)
            t = t + 1;
            lickCount = 0;
            
            if t ~= 1
                fprintf(' Waiting %g seconds with no licks to proceed...\n',patientWait)
            end
            
            while 1
                if s.BytesAvailable > 0
                    ardOutput = fscanf(s,'%c');
                    ts(t).trialstart = str2num(ardOutput(1:end-2));
                    taskState = 1;
                    break
                end
            end
            
        case 1 %generate random stimuli
            
            %Random Number to Determine Trial Type
            num = rand;
            
            % Choose duration
            intd = [0 cumsum(durProbs)];
            d = discretize(num,intd,'IncludedEdge','right');
            
            %Choose Signal Strength
            intl = [intd(d) intd(d) + (durProbs(d).*cumsum(dbProbs))];
            l = discretize(num,intl,'IncludedEdge','right');
            
            trialType{t} = [d (l-1)];
            
            %Prevent more than three trial or noise signals in a row
            ttype(t) = double(trialType{t}(2));
            tdur(t) = double(trialType{t}(1));
            
            if t > 4
                if all(ttype(end-3:end) == 0)
                    intx = [0 cumsum(ones(1,length(intl)-2) / (length(intl)-2))];
                    trialType{t}(2) = discretize(rand,intx,'IncludedEdge','right');
                    ttype(t) = double(trialType{t}(2));
                end
                if all(ttype(end-3:end) > 0);
                    trialType{t}(2) = 0;
                    ttype(t) = double(trialType{t}(2));
                end
                if range(tdur(end-3:end)) == 0 && length(nd) > 1
                    inty = [0 cumsum(ones(1,length(nd) - 1) / (length(nd) - 1))];
                    trialType{t}(1) = discretize(rand,inty,'IncludedEdge','right') + 1;
                    tdur(t) = double(trialType{t}(1));
                end
            end
            
            if trialType{t}(2) == 0 %Noise
                fprintf(s,'%i',0);
                queueOutputData(n,[stim{trialType{t}(1),trialType{t}(2)+1}'*10 events{trialType{t}(1),1}']);
                fprintf('%03d 0 %d %d %s NOISE_TRIAL\n',t,trialType{t}(1),trialType{t}(2),ardOutput(1:end-2));
                startForeground(n)
                taskState = 2;
            else                    %Signal
                fprintf(s,'%i',1);
                queueOutputData(n,[stim{trialType{t}(1),trialType{t}(2)+1}'*10 events{trialType{t}(1),1}']);
                fprintf('%03d 0 %d %d %s SIGNAL_TRIAL\n',t,trialType{t}(1),trialType{t}(2),ardOutput(1:end-2));
                startForeground(n)
                taskState = 2;
            end
            
        case 2 %Interpret Arduino Output for Display
            
            ardOutput = fscanf(s,'%c');
            if ardOutput(1) == 'L'
                fprintf('%03d 1 %d %d %s LICK\n',t,trialType{t}(1),trialType{t}(2),ardOutput(2:end-2))
                lickCount = lickCount + 1;
                ts(t).lick(lickCount) = str2double(ardOutput(2:end-2));
                fprintf(fn,'%03d %d %d %010d LICK\n',t,trialType{t}(1),trialType{t}(2),ts(t).lick(lickCount));
            elseif ardOutput(1) == 'R'
                fprintf('%03d 1 %d %d %s REWARD\n',t,trialType{t}(1),trialType{t}(2),ardOutput(2:end-2))
                ts(t).rewardstart = str2num(ardOutput(2:end-2));
                rewardState = 1;
                fprintf(fn,'%03d %d %d %010d REWARD_START\n',t,trialType{t}(1),trialType{t}(2),ts(t).rewardstart);
            elseif ardOutput(1) == 'W'
                ts(t).rewardend = str2num(ardOutput(2:end-2));
                fprintf(fn,'%03d %d %d %010d REWARD_END\n',t,trialType{t}(1),trialType{t}(2),ts(t).rewardend);
            elseif ardOutput(1) == 'T'
                if timeoutState ~= 1
                    fprintf('%03d 1 %d %d %s TIMEOUT\n',t,trialType{t}(1),trialType{t}(2),ardOutput(2:end-2))
                    timeoutState = 1;
                end
                ts(t).timeoutstart = str2num(ardOutput(2:end-2));
                fprintf(fn,'%03d %d %d %010d TIMEOUT_START\n',t,trialType{t}(1),trialType{t}(2),ts(t).timeoutstart);
            elseif ardOutput(1) == 'S'
                ts(t).stimstart = str2num(ardOutput(2:end-2));
                fprintf(fn,'%03d %d %d %010d STIM_START\n',t,trialType{t}(1),trialType{t}(2),ts(t).stimstart);
            elseif ardOutput(1) == 'O'
                ts(t).stimend = str2num(ardOutput(2:end-2));
                ts(t).respstart = str2num(ardOutput(2:end-2));
                fprintf(fn,'%03d %d %d %010d STIM_END_RESP_START\n',t,trialType{t}(1),trialType{t}(2),ts(t).stimend);
            elseif ardOutput(1) == 'C'
                fprintf('    %g Lick(s) Detected...',lickCount)
                ts(t).respend = str2num(ardOutput(2:end-2));
                fprintf(fn,'%03d %d %d %010d RESP_END\n',t,trialType{t}(1),trialType{t}(2),ts(t).respend);
                taskState = 3;
            end
            
        case 3 %Timeout, Reward
            while timeoutState == 1
                ardOutput = fscanf(s,'%c');
                if ardOutput(1) == 'T'
                    ts(t).timeoutstart = str2num(ardOutput(2:end-2));
                    fprintf(fn,'%03d %d %d %010d TIMEOUT_START\n',t,trialType{t}(1),trialType{t}(2),ts(t).timeoutstart);
                elseif ardOutput(1) == 'Q'
                    ts(t).timeoutend = str2num(ardOutput(2:end-2));
                    fprintf(fn,'%03d %d %d %010d TIMEOUT_END\n',t,trialType{t}(1),trialType{t}(2),ts(t).timeoutend);
                    timeoutState = 0;
                    break
                end
            end
            while rewardState == 1
                ardOutput = fscanf(s,'%c');
                if ardOutput(1) == 'W'
                    ts(t).rewardend = str2num(ardOutput(2:end-2));
                    fprintf(fn,'%03d %d %d %010d REWARD_END\n',t,trialType{t}(1),trialType{t}(2),ts(t).rewardend);
                    rewardState = 0;
                    break
                end
            end
            taskState = 4;
            
        case 4 %End Trial
            if n.IsRunning == 1
                stop(n)
            end
            taskState = 0;
    end
    
    [~,~,keyCode] = KbCheck;
    if sum(keyCode) == 1
        if strcmp(KbName(keyCode),'ESCAPE');
            disp('User exit...');
            break
        end
    end
    if t > 1000
        disp('Max trials reached...');
        break;
    end
end

save(sprintf('%s\\%03d_%s.mat',datDir,mouseID,time),'ts','trialType');
[f,pC] = plotPerformance(ts,ttype);
[h,psychCurve] = Psychometric_Curve(ts,trialType,mouseID,time);
fprintf('%g%% CORRECT\n',pC*100);
print(f,sprintf('%s\\%03d_%s_plot.png',datDir,mouseID,time),'-dpng','-r300');
print(h,sprintf('%s\\%03d_%s_psychCurve.png',datDir,mouseID,time),'-dpng','-r300');
pause
delete(s)
close('all')
clear all

