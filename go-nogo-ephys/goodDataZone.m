function [pc,endv] = goodDataZone(t,resp,ttype)

% Set trial index for good data zone
startv = 50;
crit = 7;
count_back = sum(resp) - cumsum(resp);
endnum = find(count_back == crit);
endv = endnum(1);

% Good Data Zone
respG = resp(startv:endv);
ttypeG = ttype(startv:endv);

% Calculate Hits and Correct Rejects
hitsG = ttypeG(ttypeG > 0) & respG(ttypeG > 0);
crsG = ~ttypeG(ttypeG == 0) & ~respG(ttypeG == 0);

% Calculate percentCorrect within goodDataZone
windowSize = 20;
interpHitG = interp1(t(ttypeG > 0),smooth(double(hitsG),windowSize),t);
interpCRG = interp1(t(ttypeG == 0),smooth(double(crsG),windowSize),t);
correct = (interpHitG + interpCRG)/2;
pc = nanmean(correct);
