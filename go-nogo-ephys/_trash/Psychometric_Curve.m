function [h,psychCurve] = Psychometric_Curve(ts,trialType,params)
% For fitting: http://davehunter.wp.st-andrews.ac.uk/2015/04/12/fitting-a-psychometric-function/#2
t = 1:length(ts);
dbSteps = params.dB;
fn = params.fn;

resp = zeros(1,length(ts));
hit = zeros(1,length(ts));
cr = zeros(1,length(ts));

for i = 1:length(trialType)
    resp(i) = ~isempty(ts(i).rewardend) || ~isempty(ts(i).timeoutend);
    tType(i) = double(trialType{i}(2));
    hit(i) = resp(i) == 1 && tType(i) ~= 0;
    cr(i) = resp(i) == 0 && tType(i) == 0;
end

hitr_1 = sum(hit(tType == 1) / sum(tType == 1));
hitr_2 = sum(hit(tType == 2) / sum(tType == 2));
hitr_3 = sum(hit(tType == 3) / sum(tType == 3));
hitr_4 = sum(hit(tType == 4) / sum(tType == 4));
hitr_5 = sum(hit(tType == 5) / sum(tType == 5));

psychCurve = [hitr_5,hitr_4,hitr_3,hitr_2,hitr_1];

h = figure;
plot(fliplr(dbSteps),psychCurve)
title(sprintf('%s Psychometric Curve',fn));
xlabel('dbSteps');
ylabel('pHit');
ylim([0 1]);
set(gca,'XTick',fliplr(dbSteps));



