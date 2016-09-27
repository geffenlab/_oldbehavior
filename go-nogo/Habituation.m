function Habituation(params)
KbName('UnifyKeyNames');
dbstop if error
delete(instrfindall)

% Load arduino sketch and start the serial port
hexPath = [params.hex filesep 'Habituation.ino.hex'];
[status, cmdOut] = loadArduinoSketch(params.comPort,hexPath);
cmdOut
disp('STARTING SERIAL');
s = setupSerial(params.comPort);

%Open txt file
fileGoto = [params.fn '_habituation.txt'];
fn = fopen(fileGoto,'w');

%Send setup() variables to arduino
varvect = [params.holdD params.rewardD];
fprintf(s,'%f %f ',varvect);

%Other Variables
trialNumber = 1;
sessionStatus = 1;
inputType = {'REWARD','LICK'};
disp(' ')
disp('Starting habituation...')
disp(' ')

while sessionStatus == 1
    
    %Start if-loop when bytes Available
    x = s.bytesAvailable;
    
    if x > 1
        
        %Read arduino's serial output
        ardOutput = fscanf(s,'%c');
        
        %Display variables and command
        inputPrint = inputType{(str2double(ardOutput(1))+1)};
        ts = str2double(ardOutput(3:end));
        disp(sprintf('%03d %d %s',trialNumber,ts,inputPrint))
        fprintf(fn,'%03d %d %s\n',trialNumber,ts,inputPrint);
        if strcmp(inputPrint,'REWARD')
            %Increase trial count
            trialNumber = trialNumber + 1;
        end
    end
    
    [~,~,keyCode] = KbCheck;
    if sum(keyCode) == 1 || trialNumber > 10000
        if trialNumber > 10000 || strcmp(KbName(keyCode),'ESCAPE');
            break
        end
    end
    
end

delete(s);


