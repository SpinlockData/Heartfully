%Import signal from WFDB from physionet
data = readmatrix("100.csv");

%load sample rate
Fs = 360;
T = 1 / Fs;

%sample number located in column 2
%lead II in column 2
Samples = data(:,1);
t = Samples * T;
lII = data(:,2);

%Setup how many seconds
PlotTime = 5;
lII_sub = lII(1:(Fs * PlotTime));
t = t(1:(Fs * PlotTime));

%plot signals
plot(t,lII_sub)


