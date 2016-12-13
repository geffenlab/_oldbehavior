% Setup function
targetFs = 200e3;
InitializePsychSound(1);pause(1); 
%h = PsychPortAudio('Open', [], 3, 3, fs, [3 1]);
h = PsychPortAudio('Open', [], 1, 3, targetFs, 2, [], [], [1 3]);
tmp = PsychPortAudio('GetStatus',h);
fs = tmp.SampleRate;

% When you want to play sounds
output = someOutput;
PsychPortAudio('FillBuffer', h, output); % fill buffer
PsychPortAudio('Start', h, 1);
PsychPortAudio('Close',h);