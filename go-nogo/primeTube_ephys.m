function primeTube(port)
delete(instrfindall);
KbName('UnifyKeyNames');

hexPath = 'C:\Users\geffen-behaviour2\Documents\GitHub\behavior\go-nogo\_hex\primeTube.ino.hex';
[status, cmdOut] = loadArduinoSketch(port,hexPath);
cmdOut

p = setupSerial(port);

str = {'CLOSED','OPEN'};
state = 0;
disp('Press ENTER to open/close lickport, ESC to exit');
while 1
    [~,~,keyCode] = KbCheck();
    if sum(keyCode) == 1
        switch KbName(keyCode)
            case 'Return'
                state = ~state;
                fprintf(p,'%i',1);
                disp(['Lickport ' str{state+1}]);
            case 'ESCAPE' 
                disp('Exit.');
                break;
        end
        WaitSecs(.2);
    end
end

delete(p);


