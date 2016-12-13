function fillWaterTube  

InitializePsychSound(1);
fs=200000;
sc = PsychPortAudio('Open', [], 1, 3, fs, 2); %'Open' [, deviceid][, mode][, reqlatencyclass][, freq][, channels]
s=setupSerial('COM5'); % windows

% Initialise variables:
trialNumber = 0;
newTrial = 1;
KbName('UnifyKeyNames');   

disp(['Press space bar until water starts to come out of the end of the tube',...
'or all the bubbles are gone. Press escape to finish'])
flag = 0;

while ~flag
    
 
  [~,~,keyCode] = KbCheck;
     disp(KbName(keyCode))
    if sum(keyCode) == 1
        if strcmp(KbName(keyCode),'ESCAPE') 
            flag = 1;
        elseif strcmp(KbName(keyCode),'space')
            disp('opening valve')
            openValve = 0.1; % open time in s
            if openValve>1
                break
                disp('Valve open for too long')
            end
             fprintf(s,'%s',openValve);
             pause(0.01)
        end
    end
    
end

disp('finished')
delete(instrfindall)
clear all