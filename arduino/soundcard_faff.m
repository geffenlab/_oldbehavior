function soundcard_faff

a =audiodevinfo
a.output(2)
fs = 384000;
sound2 = rand(2,fs)/2;
b = audioplayer(sound2,384000,24,3)
play(b)