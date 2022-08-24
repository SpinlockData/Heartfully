% clear all;
% BSD 3-Clause License

% Copyright (c) 2022, SpinlockData
% All rights reserved.

% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:

% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.

% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.

% 3. Neither the name of the copyright holder nor the names of its
%    contributors may be used to endorse or promote products derived from
%    this software without specific prior written permission.

% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

%The following Matlab script file follows the Pan-Tomkin algorithm to detetc R-R interval in ECG
% Process: ECG->Low Pass Filter->High Pass filter->Deivative Filter->Squaring->Moving window Integration.
%https://en.wikipedia.org/wiki/Pan%E2%80%93Tompkins_algorithm

%TODO:
%   -After preliminary testing move into function.  
%   -Add last part of Algorithm where we detect viability of peak based on a criteria

clear all;
%Import signal from WFDB data base from physionet
%https://physionet.org/about/database/

data = readmatrix("100.csv");

%load sample rate
Fs = 360;
T = 1 / Fs;

%sample number located in column 2
%lead II in column 2
Samples = data(:,1);
t = Samples * T;
lII = data(:,2);

%Setup how many seconds to get look at
PlotTime = 20;
lII_sub = lII(1:(Fs * PlotTime));
t = t(1:(Fs * PlotTime));

%low pass and high pass butterworth  filter design to get flat passband 5-15 hz
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

%filter signal,  first low pass then high pass
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
        lmax(diy_count) = i_pk - 1;
        diy_count = diy_count + 1;
    end
    i_pk = i_pk + 1;
    last_diy = diy;
end

%now we have all posible peaks, time to find which is QRS or noise
% skip first 200 samples to avoid settling time of filters. 
l = length(lmax);

k = 1;
for i = 5:(l-1)
    N0 = iy(lmax(i-1));
    N1 = iy(lmax(i));
    N2 = iy(lmax(i+1));
    if(N1 > 100)
        if(N1 > N0 && N1 > N2)
            pk1_loc(k) = lmax(i);
            k = k + 1;
        end
    end
end

%calculate HR between to Peaks
BPM = RR_Detect(pk1_loc,360);

%Now mark all the point
figure(1)
plot(lII_sub)
hold on
for i = 1:length(pk1_loc)
        markpt = pk1_loc(i);
        plot(pk1_loc(i), lII_sub(markpt), '*r')
end
hold off



% %plot signals
% figure(2);
% subplot(411)
% n = length(lII_sub);
% plot(lII_sub(200:n));
% subplot(412)
% n = length(y);
% plot(y(200:n));
% hold on
% n = length(dy);
% plot(dy(200:n));
% hold off
% subplot(413)
% n = length(dys);
% plot(dys(200:n));
% subplot(414)
% n = length(iy);
% plot(iy);
% hold on
% plot(diy)

