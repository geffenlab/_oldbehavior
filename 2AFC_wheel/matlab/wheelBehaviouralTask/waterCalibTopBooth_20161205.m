%% Water calibration for the top booth - fill the tube to 60 ml with H2O

empty = 1.1152; % g - weight of empty eppendorf
durations = [6,7,7,10,10,15,20,50,100]; % ms - duration of solenoid opening
weights = [1.1973,1.2098,1.2096,1.2317,1.2315,1.2594,1.2894,1.4034,1.5920]; % weight of eppendorf with water from 100 openings of the valve
ulPerOpening = (weights - repmat(empty,1,length(weights)))*1000/100;

plot(durations,ulPerOpening,'ok','LineWidth',2)
xlabel('Time valve open (ms)')
ylabel('\mul per opening')

P = polyfit(durations,ulPerOpening,2);
x1 = 0:3:100;
y1 = polyval(P,x1);
hold on
plot(x1,y1,'r--','LineWidth',2)
set(gca,'FontSize',14)