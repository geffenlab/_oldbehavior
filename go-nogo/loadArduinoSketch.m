function [status, cmdOut] = loadArduinoSketch(comport,sketchPath)

cmdIn = sprintf('cmd /C ""C:\Program Files (x86)\Arduino\hardware\tools\avr\bin\avrdude.exe" -C"C:\Program Files (x86)\Arduino\hardware\tools\avr/etc/avrdude.conf" -v -patmega328p -carduino -P %s -b115200 -D -Uflash:w:%s',comport,sketchPath);
[status,cmdOut] = dos(cmdIn);

end