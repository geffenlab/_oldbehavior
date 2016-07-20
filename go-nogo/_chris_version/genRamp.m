function r = genRamp(fs,d)

n = floor(d*fs);
r = sin(linspace(0,pi/2,n));