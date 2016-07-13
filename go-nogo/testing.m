function testing

p = setupSerialPort('COM6',9600);

vals = [1.5 .1 7 2];
fprintf(p,'%f ',vals);

while 1
    disp(fscanf(p));
end
