x = 0:.01:1;
alpha = .1;
beta = .2;
y = 1./(1+exp(-((x-alpha)./beta)));
plot(x,y);