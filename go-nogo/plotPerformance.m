function [f, percentCorrect] = plotPerformance(ts,ttype)

t = 1:length(ttype);
windowSize = 20;
resp = zeros(1,length(t));
% Get responses
for i = 1:length(t)
    if ~isempty(ts(i).rewardend) || ~isempty(ts(i).timeoutend)
        resp(i) = 1;
    else
        resp(i) = 0;
    end
end

% Calculate hits and stuff
if size(ttype,1) > 2
    ttype = ttype(:,1)';
end
hits = ttype(ttype > 0) & resp(ttype > 0);
crs = ~ttype(ttype == 0) & ~resp(ttype == 0);

% Prepare plot vars
interpHit = interp1(t(ttype > 0),smooth(double(hits),windowSize),t);
interpCR = interp1(t(ttype == 0),smooth(double(crs),windowSize),t);
correct = (interpHit + interpCR)/2;

%Good Data Zone and Percent Correct
if length(t) > 150
    [percentCorrect,endValue] = goodDataZone(t,resp,ttype);
else
    percentCorrect = nanmean(correct);
    endValue = [];
end

% Plot
f = figure();
hold on
h(1) = plot(interpHit,'r-','LineWidth',2);
h(2) = plot(interpCR,'b-','LineWidth',2);
h(3) = plot(correct,'k','LineWidth',2);
h(4) = plot(smooth(double(resp),windowSize),'k--');
h(5) = plot([0 length(ts)],[.5 .5],'--','Color',[.5 .5 .5]);
if ~isempty(endValue)
    h(6) = plot([50 50],[0 1],'--','Color',[.5 .5 .5]);
    h(7) = plot([endValue endValue],[0 1],'--','Color',[.5 .5 .5]);
end
xlabel('Trial');
ylabel('Percent');
ylim([0 1]);
xlim([1 length(t)+200]);
legend('pHIT','pCR','pCORR','pRESP','chance');
hold off

