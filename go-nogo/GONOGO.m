function GONOGO_training(params)

makeStim(192e3,10e3,1,2,.1,.1,.01);

% Setup
p = setupSerialPort('COM4',9600);
[s,params.fs] = setupNidaq(1,params.targetFs);
fid = fopen(params.fullFile,'w');

fprintf('PRESS ANY KEY TO START...\n');
pause;

tt = [];
cnt = 0;
while cnt < 1000
    out = serialRead(p);
    
    fprintf(fid,'%s',out);
    fprintf('%s',out);
    
    if ~isempty(regexp(out,'TRIAL', 'once'))
        % Send trial type
        tt = rand > .5;
        fprintf(p,tt);
    elseif ~isempty(regexp(out,'TON', 'once')) 
        % Play stimulus
        queueOutputData(s,stim(2,:)');
        startBackground(s);
    elseif ~isempty(regexp(out,'TOFF', 'once'))
        % Make sure we're ready for the next trial
        if s.IsRunning
            stop(s);
        end
    end
end
            
stop(s);           
fclose(p);
delete(p);
clear all

% delete(instrfindall)










function stim = makeStim(fs,f,sd,nd,srms,nrms,ramp)

% Make ramp
r = genRamp(fs,ramp);

% Make noise
nr = [r ones(1,nd*fs) fliplr(r)];
noise = rand(1,(nd + (2*ramp))*fs);
noise = noise - mean(noise);
noise = noise * (nrms/rms(noise));
noiseR = noise .* nr;

% Make signal
sr = [r ones(1,sd*fs) fliplr(r)];
signal = genTone(fs,f,sd + 2*ramp,1);
signal = signal * (srms/rms(signal));
signal = signal .* sr;

% Combine them (assuming signal goes on at the end end)
signal = [zeros(1,length(noiseR)-length(signal)) signal];
stim = signal + noiseR;
t = (1:length(stim)) / fs;

% hold on
% plot(t,stim);
% plot([ramp ramp], ylim,'k');
% plot([nd/2 + ramp nd/2 + ramp], ylim,'k');
% plot([nd + ramp nd + ramp],ylim,'k');