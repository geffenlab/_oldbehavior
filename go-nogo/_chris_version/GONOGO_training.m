function GONOGO_training(params)

try
    
    params.targetFs = 400e3;
    params.signalF = 10e3;
    params.signalDur = 1;
    params.noiseDur = 1;
    params.signalRMS = .1;
    params.noiseRMS = .1;
    params.rampDur = .01;
    params.ITI = 0.5;
    params.holdTime = 2;
    params.respWin = 1.2;
    params.rewDur = .1;
    params.timeoutDur = 7;
    
    % Setup
    p = setupSerialPort(params.port,9600);
    [s,params.fs] = setupNidaq([0 1],params.targetFs);
    fid = fopen(params.fullFile,'w');
    KbName('UnifyKeyNames');
    
    fprintf('PRESS ANY KEY TO START...\n');
    pause;
    
    % Pass task parameters
    fprintf(p,'%f ',[params.holdTime params.respWin ...
        params.rewDur params.timeoutDur]);
    
    % Trial loop
    tt = [];
    cnt = 0;
    flag = 0;
    while ~flag
        out = serialRead(p);
        
        fprintf(fid,'%s',out);
        fprintf('%s',out);
        
        if ~isempty(regexp(out,'TRIAL', 'once'))
            cnt = cnt + 1;
            % Determine trial type
            tt(cnt) = rand > .5;
            if cnt > 3 && range(tt(end-2:end)) == 0
                tt(cnt) = ~tt(cnt);
            end
            % Make stimulus and events
            stim = makeStim(params.fs,params.signalF,...
                params.signalDur,params.noiseDur,...
                params.signalRMS*tt(cnt),params.noiseRMS,...
                params.rampDur);
            fprintf(p,num2str(tt(cnt)));
        elseif ~isempty(regexp(out,'TON', 'once'))
            % Play stimulus at trial start
            queueOutputData(s,stim');
            startBackground(s);
        elseif ~isempty(regexp(out,'TOFF', 'once'))
            % At trial end, get ready for the next trial
            if s.IsRunning
                stop(s);
            end
            % Add random ITI
            pause(rand*params.ITI);
        end
        
        % Exit statement
        [~,~,keyCode] = KbCheck;
        if sum(keyCode) == 1
            if strcmp(KbName(keyCode),'ESCAPE') || cnt > 10
                flag = 1;
            end
        end
    end
    
    stop(s);
    fclose(p);
    delete(p);
    
    fclose('all');
    parseLog(params);
    
    
    clear all
    
catch ME
    rethrow(ME);
    keyboard
    
    stop(s);
    fclose(p);
    delete(p);
    
    fclose('all');
    parseLog(params);
    
    clear all
    
end

% delete(instrfindall)










