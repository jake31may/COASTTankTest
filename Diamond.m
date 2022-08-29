%% Diamond Extraction!

% Input!
sample_frequency = [500,128];   % [Hz] [Qualysis,wave]
start_time = 10;    %[s]
Amplitude = [18,36];    % [mm]


% Fill me in here...
reg_coarse = [0.2,0.25,0.3:0.1:1.1];
reg_fine = [0.30:0.01:0.36,0.38];
frequenciesD = transpose([reg_coarse,reg_fine,reg_coarse,reg_fine]);
sz = length(frequenciesD);

filepath    = ('Users/jakehollins/Documents/MATLAB/RegDiamond/');
folder = 'RegDiamond/';

% Leave me alone! Add those pesky end time anomalies below 
end_coarse = round(50./reg_coarse,0)+20;
end_fine = round(150./reg_fine,0)+20;

end_time = [end_coarse,end_fine,end_coarse,end_fine];
start_times = repelem(start_time,sz);
%end_time = end_time-repelem(30,length(end_time));

end_time(34) = 150;
start_times(21) = 70;

start_frame = transpose(sample_frequency).*start_times;    % [-]
end_frame = transpose(sample_frequency).*end_time;

% Anomomolies :(
end_frame(1,1) = end_time(1).*100; % Measured @ 100 Hz instead
end_frame(1,18) = end_time(18).*100;
end_frame(1,19) = end_time(19).*100;

%%
H = struct();
H = extract_tsv(H,filepath,folder,sample_frequency,start_frame,end_frame,Amplitude,frequenciesD)

%%
sample_frequency = repmat([500,128],sz,1);
sample_frequency(1,1) = 100;
sample_frequency(18,1) = 100;
sample_frequency(19,1) = 100;

diffThreshold = 0.15;
for i = 1:sz
    z = H(i).Motion.deHeave;
    t = H(i).Motion.Time;

    z = resample(z,500,sample_frequency(i,1));
    t = resample(t,500,sample_frequency(i,1));

    [analysis_start,analysis_end] = AnalysisWindow(z,H(i).RegFrequency,diffThreshold);

    H(i).Heave = z(analysis_start:analysis_end);


    w = resample(H(i).Wave.deAmplitude,500,sample_frequency(i,2));
    H(i).WaveAmp = w(analysis_start:analysis_end)*1000;

    H(i).Time = t(analysis_start:analysis_end);
end

   

%% RAO and Power
sz = 38;
RAOd = zeros(sz,1);
AvPowerd = zeros(sz,1); sdPowerd = zeros(sz,1);
cw = zeros(sz,1); k_cw = zeros(sz,1); cw_r = zeros(sz,1); 
Max_power = zeros(sz,1); Cw_max = zeros(sz,1); WavePower = zeros(sz,1);

WECRadius = 0.4176/2;

for i = 1:sz
    i;
    z = H(i).Heave;
    w = H(i).WaveAmp;

    RAOd(i) = FFT_RAO(z,w,500);
    H(i).RAO = RAOd(i);

    AvPowerd(i) = RegularPower(4.1,z,500);
    H(i).AvPower = AvPowerd(i);

    [cw(i), k_cw(i), cw_r(i), Cw_max(i),WavePower(i)] = CaptureWidth(H(i).AvPower,H(i).Amplitude,H(i).RegFrequency,WECRadius);
end

%% Plot RAO!
% Organise Data into different amplitudes
di_small = 19;

[fSDi,fBDi] = split(frequenciesD,di_small);

graph = [RAOd,AvPowerd,cw,k_cw,cw_r,Cw_max,WavePower];
[SGDi,BGDi] = split(graph,di_small);

[fSDi,SGDi] = sortit(fSDi,SGDi);
[fBDi,BGDi] = sortit(fBDi,BGDi);


%% Plot Graphs
% Plot RAO
figure(1)
plot(fSDi,SGDi(:,1),'r-')
hold on 
plot(fBDi,BGDi(:,1),'b-')
grid on
hold off
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf RAO','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm')
title(['Regular wave frequency and RAO for ',H(1).WEC])

% Plot Power
figure(2)
plot(fSDi,SGDi(:,2),'r-')
hold on 
plot(fBDi,BGDi(:,2),'b-')
hold off
grid on
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf Average Power [W]','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm')
title(['Regular wave frequency and power for ',H(1).WEC])


% Plot Capture Width
figure(3)
plot(fSDi,SGDi(:,3),'r-')
hold on 
plot(fBDi,BGDi(:,3),'b-')
hold off
grid on
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf Capture Width [m]','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm')
title(['Regular wave capture width for ',H(1).WEC])

% Plot capture width ratio (k.Cw)
figure(4)
plot(fSDi,SGDi(:,4),'r-')
hold on 
plot(fBDi,BGDi(:,4),'b-')
hold off
grid on
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf Capture Width Ratio $(k\frac{P}{P_I}$)','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm')
title(['Regular wave capture width for ',H(1).WEC])

% Plot capture width ratio (Cw/D)
figure(5)
plot(fSDi,SGDi(:,5),'r-')
hold on 
plot(fBDi,BGDi(:,5),'b-')
hold off
grid on
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf Capture Width Ratio $(\frac{P}{P_I*D}$)','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm')
title(['Regular wave capture width for ',H(1).WEC])


% Plot theoretical max power with power captured
AbPow1 = SGDi(:,6).*SGDi(:,7);
AbPow2 = BGDi(:,6).*BGDi(:,7);

figure(5)
plot(fSDi,SGDi(:,2),'r-')
hold on 
plot(fBDi,BGDi(:,2),'b-')
plot(fSDi,AbPow1,'r--')
plot(fBDi,AbPow2,'b--')
hold off
grid on
ylim([0 1])
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf Average Power [W]','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm','Maximum Available Power (18 mm)','Maximum Available Power (36 mm)')
title(['Regular wave capture width for ',H(1).WEC])