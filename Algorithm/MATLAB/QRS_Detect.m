clear all;
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



%butter filter design to get flat passband 5-15 hz

fc = 15;     
wn = fc / (Fs/2);
poles = 3;
[b,a] = butter(poles,wn);
%freqz(b,a);


fc = 5;
wn = fc / (Fs/2);
poles = 3;
[bh,ah] = butter(poles,wn,'high');
%freqz(bh,ah);

%filter signal first low pass then high pass
y = filter(b,a,lII_sub);
y = filter(bh,ah,y);
n = length(y);
dy = ecgderive(y);
n = length(dy);

%now do a point by point squaring
for i=1:n
    dys(i) = dy(i) * dy(i);
end

%moving integration
win = 15;
i = 1;
z = 1;
while i < (n - win)
    iy(z) = movingInt(dys(i:(i + win)), win);
    i = i + 1;
    z = z + 1;
end

%here we find the peaks which is the loca maxmum
len = length(iy);
i_pk = 3;
diy_count = 1;
last_diy = 1;
for i = 3:(len)
    if (iy(i) - iy(i - 1)) > 0
        diy = 1;
    else
        diy = -1;
    end
    if last_diy == 1 &&  diy == -1
        lmax(diy_count) = i_pk;
        diy_count = diy_count + 1;
    end
    i_pk = i_pk + 1;
    last_diy = diy;
end

%lets mark all the point
figure(1)
subplot(211)
plot(lII_sub)
subplot(212)
plot(iy)
hold on
for i = 1:length(lmax)
        markpt = lmax(i);
        plot(lmax(i), iy(markpt), '*r')
end
hold off
%plot signals
figure(2);
subplot(411)
n = length(lII_sub);
plot(lII_sub(200:n));
subplot(412)
n = length(y);
plot(y(200:n));
hold on
n = length(dy);
plot(dy(200:n));
hold off
subplot(413)
n = length(dys);
plot(dys(200:n));
subplot(414)
n = length(iy);
plot(iy);
hold on
plot(diy)

