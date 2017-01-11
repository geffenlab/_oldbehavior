close all
clear all
clc

io.fs = 192000;
fs = io.fs;
InitializePsychSound(1);pause(1); 
io.h = PsychPortAudio('Open', [], 1, 3, io.fs, [3]);

PsychPortAudio('GetAudioData', io.h, 2);

load('C:\Users\geffen-behaviour2\Documents\MATLAB\miniBooth2Calib\20170109_upperBoothLeftSpkrInvFilt_3k-80k_fs192k.mat')

 outputSignal1 = FM_stimGen(fs,20000,20,1,10000);
%  outputSignal1 = tone(20000,1,2,fs);
 outputSignal1 = conv(outputSignal1,FILT_LEFT,'same');
 outputSignal1 = envelopeKCW(outputSignal1,5,fs);
        outputSignal2 = FM_stimGen(fs,1000,20,1,50);
        outputSignal3 = [ones(50,1)*3; zeros(length(outputSignal1)-100,1); ones(50,1)*3];
        
        outputSignal1 = rand(1,io.fs)/20;
        
         PsychPortAudio('FillBuffer', io.h, [outputSignal1;outputSignal1;zeros(1,length(outputSignal1))]);
        
        % Start presentation
        [t1] = PsychPortAudio('Start', io.h, 1); % 'Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0]
         [data, ~, ~, t.rec] = PsychPortAudio('GetAudioData', io.h);