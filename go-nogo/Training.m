function Training_ephys(params)
KbName('UnifyKeyNames');
dbstop if error
delete(instrfindall)

%Load corresponding Arduino sketch
hexPath = [params.hex filesep 'trainingWithOutput.ino.hex'];
[~, cmdOut] = loadArduinoSketch(params.comPort,hexPath);
cmdOut
disp('STARTING SERIAL');
s = setupSerial(params.comPort);
n = params.n;

% Open text file
fileGoto = [params.fn '_training.txt'];
fn = fopen(fileGoto,'w');

%Send setup() variables to arduino
varvect = [params.holdD params.rewardD params.respD params.timeoutD];
fprintf(s,'%f %f %f %f ',varvect);

% modify params to reflect actual stimuli used
params.dbSteps = params.dbSteps(1);
params.dB = params.dB(1);
params.toneA = params.toneA(1);
params.noiseD = params.noiseD(1);

% Make stimuli
Fs = params.fsActual;
f = params.toneF;
sd = params.toneD;
nd = params.noiseD;
samp = params.toneA;
namp = params.noiseA;
rd = params.rampD;
% make tone
offset = params.noiseD(1)/2 - params.toneD/2;
tone = makeTone(Fs,f,sd,samp,nd,offset,rd,params.filt);
tone = [tone zeros(1,.02*Fs)];

disp(' ');
disp('Press any key to start TRAINING...');
disp(' ');
pause;


% Preallocate some variables
t                   = 0;
ts                  = {};
timeoutState        = 0;
rewardState         = 0;
taskState           = 0;
lickCount           = [];
disp(' ');
%%Task
while 1
    
    switch taskState
        
        case 0 %proceed when arduino signals (2s no licks)
            t = t + 1;
            lickCount = 0;
            
            if t ~= 1
                fprintf(' Waiting %g seconds with no licks to proceed...\n',params.holdD)
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
            % make new noise each time
            [noise,events] = makeNoise(Fs,nd,namp,rd,params.filt);
            
            trialChoice(t) = rand < 0.5;
            if t > 3 && range(trialChoice(end-3:end-1)) == 0
                trialChoice(t) = ~trialChoice(t-1);
            end
            if ~trialChoice(t) %Noise, stim{1}
                fprintf(s,'%i',0);
                queueOutputData(n,[noise'*10 events']);
                startBackground(n)
                trialType(t) = 0;
                disp(sprintf('%03d 0 %i %s NOISE_TRIAL',t,trialType(t),ardOutput(1:end-2)));
                taskState = 2;
            else  %Signal, stim{2}
                fprintf(s,'%i',1);
                queueOutputData(n,[(tone+noise)'*10 events']);
                startBackground(n)
                trialType(t) = 1;
                disp(sprintf('%03d 0 %i %s SIGNAL_TRIAL',t,trialType(t),ardOutput(1:end-2)));
                taskState = 2;
            end
            
        case 2 %Interpret Arduino Output for Display
            ardOutput = fscanf(s,'%c');
            if ardOutput(1) == 'L'
                disp(sprintf('%03d 1 %i %s LICK',t,trialType(t),ardOutput(2:end-2)))
                lickCount = lickCount + 1;
                ts(t).lick(lickCount) = str2double(ardOutput(2:end-2));
                fprintf(fn,'%03d %i %010d LICK\n',t,trialType(t),ts(t).lick(lickCount));
            elseif ardOutput(1) == 'R'
                disp(sprintf('%03d 1 %i %s REWARD',t,trialType(t),ardOutput(2:end-2)))
                ts(t).rewardstart = str2num(ardOutput(2:end-2));
                rewardState = 1;
                fprintf(fn,'%03d %i %010d REWARD_START\n',t,trialType(t),ts(t).rewardstart);
            elseif ardOutput(1) == 'W'
                ts(t).rewardend = str2num(ardOutput(2:end-2));
                fprintf(fn,'%03d %i %010d REWARD_END\n',t,trialType(t),ts(t).rewardend);
            elseif ardOutput(1) == 'T'
                if timeoutState ~= 1
                    disp(sprintf('%03d 1 %i %s TIMEOUT',t,trialType(t),ardOutput(2:end-2)))
                    timeoutState = 1;
                end
                ts(t).timeoutstart = str2num(ardOutput(2:end-2));
                fprintf(fn,'%03d %i %010d TIMEOUT_START\n',t,trialType(t),ts(t).timeoutstart);
            elseif ardOutput(1) == 'S'
                ts(t).stimstart = str2num(ardOutput(2:end-2));
                fprintf(fn,'%03d %i %010d STIM_START\n',t,trialType(t),ts(t).stimstart);
            elseif ardOutput(1) == 'O'
                ts(t).stimend = str2num(ardOutput(2:end-2));
                ts(t).respstart = str2num(ardOutput(2:end-2));
                fprintf(fn,'%03d %i %010d STIM_END_RESP_START\n',t,trialType(t),ts(t).stimend);
            elseif ardOutput(1) == 'C'
                fprintf('    %g Lick(s) Detected...',lickCount)
                ts(t).respend = str2num(ardOutput(2:end-2));
                fprintf(fn,'%03d %i %010d RESP_END\n',t,trialType(t),ts(t).respend);
                taskState = 3;
            end
            
        case 3 %Timeout, Reward
            while timeoutState == 1
                ardOutput = fscanf(s,'%c');
                if ardOutput(1) == 'T'
                    ts(t).timeoutstart = str2num(ardOutput(2:end-2));
                    fprintf(fn,'%03d %i %010d TIMEOUT_START\n',t,trialType(t),ts(t).timeoutstart);
                elseif ardOutput(1) == 'Q'
                    ts(t).timeoutend = str2num(ardOutput(2:end-2));
                    fprintf(fn,'%03d %i %010d TIMEOUT_END\n',t,trialType(t),ts(t).timeoutend);
                    timeoutState = 0;
                    break
                end
            end
            while rewardState == 1
                ardOutput = fscanf(s,'%c');
                if ardOutput(1) == 'W'
                    ts(t).rewardend = str2num(ardOutput(2:end-2));
                    fprintf(fn,'%03d %i %010d REWARD_END\n',t,trialType(t),ts(t).rewardend);
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
            fprintf(fn,'USER_EXIT');
            disp('User exit...');
            break
        end
    end
    if t > 2000
        fprintf(fn,'MAX_TRIALS');
        disp('Max trials reached...');
        break;
    end
end

if t > 10
    save(sprintf('%s_training.mat',params.fn),'ts','trialType','params');
    [f,pC] = plotPerformance(ts,trialType);
    fprintf('%g%% CORRECT\n',pC*100);
    print(f,sprintf('%s_performance.png',params.fn),'-dpng','-r300');
end
fclose(fn);
delete(s);
pause



