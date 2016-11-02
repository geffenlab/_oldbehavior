function logWheelTrial_WL(fid,trialNumber, correctionTrial, trialType, mouseStillTime,...
    soundOnset,soundOffset,responseTime,responseOutcome)


trialData = [trialNumber, correctionTrial, trialType, mouseStillTime,...
    soundOnset,soundOffset,responseTime,responseOutcome];

 headers ={'trialNo', 'corrTrial?', 'trialType','stillTime','stimOnset', 'stimOffset',...
     'respTime' , 'correct?'};
 
 data(trialNumber,:)=trialData;
 data=data;

 
fprintf(fid,'\n%03d\t%i\t%i\t%g\t%g\t%g\t%g\t%i',trialData); 
 
%  save('data.mat','headers','data','-append');
