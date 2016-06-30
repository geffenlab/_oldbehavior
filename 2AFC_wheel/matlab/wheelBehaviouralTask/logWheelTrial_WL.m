function logWheelTrial_WL(trialNumber, correctionTrial, trialType, mouseStillTime,...
    soundOnset,soundOffset,responseTime,responseOutcome)


trialData = [trialNumber, correctionTrial, trialType, mouseStillTime,...
    soundOnset,soundOffset,responseTime,responseOutcome];

 headers ={'trialNo', 'corrTrial?', 'trialType','stillTime','stimOnset', 'stimOffset',...
     'respTime' , 'correct?'};
 
 data(trialNumber,:)=trialData;
 data=data;

 
 % fprintf(fid,'%03d %i %i %g %g %g %g %i\n',trialData); 
 
 save('data.mat','headers','data','-append');
