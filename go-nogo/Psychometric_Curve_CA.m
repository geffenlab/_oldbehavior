function [h,fit] = Psychometric_Curve_CA(ts,trialType,params)
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

% Count the number of hits for each trialtype
conditions = unique(tType);
nConditions = length(conditions);
for i = 1:nConditions
    respSum(i) = sum(hit(tType == conditions(i)));
    reps(i) = sum(tType == conditions(i));
    hr(i) = respSum(i)/reps(i);
end

% Fix the first value to reflect the actual false alarm rate
hr(1) = 1-(sum(cr) / sum(tType == 0));

% Fit the psychometric function
fit = psychometricFit(fliplr(respSum(2:end)),fliplr(reps(2:end)), ...
                      fliplr(params.dB));

h = figure;
hold on
plot(fit.x,fit.y,'k','LineWidth',2);
plot(min(dbSteps)-5, hr(1),'.k','MarkerSize',30);
xLimits = xlim;
plot([xLimits(1) fit.thresh],[.5 .5],'--k');
plot([fit.thresh fit.thresh],[0 .5],'--k');
plot(fliplr(dbSteps),fliplr(hr(2:end)),'.r','MarkerSize',30);
title(sprintf('%s Psychometric Curve',fn));
xlabel('dbSteps');
ylabel('pHit');
ylim([0 1]);
set(gca,'XTick',fliplr(dbSteps));


