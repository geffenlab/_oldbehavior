function primeTube



p = setupSerialPort('COM6',9600);

str = {'CLOSED','OPEN'};
state = 0;
disp('Press ENTER to open/close lickport, ESC to exit');
while 1
    [~,~,keyCode] = KbCheck();
    if sum(keyCode) == 1
        switch KbName(keyCode)
            case 'return'
                state = ~state;
                fprintf(p,'%i',1);
                disp(['Lickport ' str{state+1}]);
            case 'esc' 
                disp('Exit.');
                break;
        end
        WaitSecs(.2);
    end
end

delete(p);
delete(instrfindall);


