%% Compound Extraction!

%% Preliminary information on regular waves

% Input!
sample_frequency = [500,128];   % [Hz] [Qualysis,wave]
start_time = 10;    %[s]
Amplitude = [18,36];    % [mm]
 

% Fill me in here...
reg_coarse = [0.4,0.5,0.6,0.8,0.9];
reg_fine = 0.65:0.01:0.75;
frequenciesC = transpose([reg_coarse,reg_fine,reg_coarse,reg_fine]);
sz = length(frequenciesC);

filepath    = ('Users/jakehollins/Documents/MATLAB/RegCompound/');
folder = 'RegCompound/';

% Leave me alone! Add those pesky end frame anomalies below 
% (Idea: add a peak finder to find that weird peak at the end when the wave
% machine finishes its business for end time and subtract a wave period)
end_coarse = round(50./reg_coarse,0)+20;
end_fine = round(150./reg_fine,0)+20;

end_time = [end_coarse,end_fine,end_coarse,end_fine];
start_times = repelem(start_time,sz);


% Anomomolies :(
end_time(22) = 165;
end_time(32) = 140;

start_frame = transpose(sample_frequency).*start_times;    % [-]
end_frame = transpose(sample_frequency).*end_time;


T = struct();

T = extract_tsv(T,filepath,folder,sample_frequency,start_frame,end_frame,Amplitude,frequenciesC)

for i = 1:16
    T(i).Amplitude = 0.018;
end

%%
sample_frequency = [500,128];
diffThreshold = 0.15;
for i = 1:sz
    z = T(i).Motion.deHeave;
    t = T(i).Motion.Time;
    [analysis_start,analysis_end] = AnalysisWindow(z,T(i).RegFrequency,diffThreshold);

    T(i).Heave = z(analysis_start:analysis_end);
    
    %T(i).Heave = resample(z,sample_frequency(2),sample_frequency(1));

    w = resample(T(i).Wave.deAmplitude,sample_frequency(1),sample_frequency(2));
    T(i).WaveAmp = w(analysis_start:analysis_end)*1000;

    %wave_frame = round(analysis_start*128/500,0);
    T(i).Time = T(i).Motion.Time(analysis_start:analysis_end);
    %T(i).WaveAmp = T(i).Wave.deAmplitude(wave_frame:wave_frame+length(T(i).Heave)-1)*1000;
end

sample_frequency = sample_frequency(1);

%% RAO and Power
WECRadius = 0.4393/2;
RAOc = zeros(sz,1);
AvPowerc = zeros(sz,1); sdPowerc = zeros(sz,1);

cw = zeros(sz,1); k_cw = zeros(sz,1); cw_r = zeros(sz,1); 
Max_power = zeros(sz,1); AvPower = zeros(32,1); WavePower = zeros(sz,1);

sz = 32;
for i = 1:sz
    i
    
    z = T(i).Heave;
    w = T(i).WaveAmp;

    RAOc(i) = FFT_RAO(z,w,sample_frequency);
    T(i).RAO = RAOc(i);

    %[AvPowerc(i),sdPowerc(i),Mean_Power(i)] = RegularPower(4.1,z,[500,128]);
    AvPower(i) = RegularPower(4.1,z,500);
    T(i).AvPower = AvPower(i);
    

    [cw(i), k_cw(i), cw_r(i), Cw_max(i),WavePower(i)] = CaptureWidth(T(i).AvPower,T(i).Amplitude,T(i).RegFrequency,WECRadius);
end

%%
% Organise Data into different amplitudes
co_small = 16;

[fSCo,fBCo] = split(frequenciesC,co_small);

graph = [RAOc,AvPower,cw,k_cw,cw_r,Cw_max,WavePower];
[SGCo,BGCo] = split(graph,co_small);

[fSCo,SGCo] = sortit(fSCo,SGCo);
[fBCo,BGCo] = sortit(fBCo,BGCo);


%% Plot Graphs
% Plot RAO
figure(1)
plot(fSCo,SGCo(:,1),'r-')
hold on 
plot(fBCo,BGCo(:,1),'b-')
grid on
hold off
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf RAO','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm')
title(['Regular wave frequency and RAO for ',T(1).WEC])

% Plot Power
figure(2)
plot(fSCo,SGCo(:,2),'r-')
hold on 
plot(fBCo,BGCo(:,2),'b-')
hold off
grid on
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf Average Power [W]','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm')
title(['Regular wave frequency and power for ',T(1).WEC])


% Plot Capture Width
figure(3)
plot(fSCo,SGCo(:,3),'r-')
hold on 
plot(fBCo,BGCo(:,3),'b-')
hold off
grid on
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf Capture Width [m]','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm')
title(['Regular wave capture width for ',T(1).WEC])

% Plot capture width ratio (k.Cw)
figure(4)
plot(fSCo,SGCo(:,4),'r-')
hold on 
plot(fBCo,BGCo(:,4),'b-')
hold off
grid on
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf Capture Width Ratio $(k\frac{P}{P_I}$)','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm')
title(['Regular wave capture width for ',T(1).WEC])

% Plot capture width ratio (Cw/D)
figure(5)
plot(fSCo,SGCo(:,5),'r-')
hold on 
plot(fBCo,BGCo(:,5),'b-')
hold off
grid on
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf Capture Width Ratio $(\frac{P}{P_I*D}$)','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm')
title(['Regular wave capture width for ',T(1).WEC])


% Plot theoretical max power with power captured
AbPow1 = SGCo(:,6).*SGCo(:,7);
AbPow2 = BGCo(:,6).*BGCo(:,7);

figure(5)
plot(fSCo,SGCo(:,2),'r-')
hold on 
plot(fBCo,BGCo(:,2),'b-')
plot(fSCo,AbPow1,'r--')
plot(fBCo,AbPow2,'b--')
hold off
grid on
ylim([0 5])
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf Average Power [W]','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm','Maximum Available Power (18 mm)','Maximum Available Power (36 mm)')
title(['Regular wave capture width for ',T(1).WEC])
