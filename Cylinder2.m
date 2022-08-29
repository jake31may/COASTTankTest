%% Cylinder Extraction!

%% Preliminary information on regular waves

% Input!
sample_frequency = [500,128];   % [Hz] [Qualysis,wave]
start_time = 10;    %[s]
Amplitude = [18,36];    % [mm]
WECRadius = 0.577/2;

%% Extract data for Cylinder

% Fill me in here...
reg_coarse = [0.4,0.5,0.6,0.8,0.9];
reg_fine1 = [0.65:0.01:0.75,0.67,0.68];
reg_fine2 = [0.65,0.66,0.69,0.7,0.72:0.01:0.75];

filepath    = ('Users/jakehollins/Documents/MATLAB/RegularCylinder2/');
folder = 'RegularCylinder2/';


frequencies = transpose([reg_coarse,reg_fine1,reg_coarse,reg_fine2]);
sz = length(frequencies);


% Leave me alone! Add those pesky end frame anomalies below 
% (Idea: add a peak finder to find that weird peak at the end when the wave
% machine finishes its business for end time and subtract a wave period)
end_coarse = round(50./reg_coarse,0)+20;
end_fine1 = round(150./reg_fine1,0)+20;
end_fine2 = round(150./reg_fine2,0)+20;

end_time = [end_coarse,end_fine1,end_coarse,end_fine2];
start_times = repelem(start_time,sz);

% Anomomolies :(
end_time(27) = 150;
start_times(5) = 52;
start_times(9) = 172;
start_times(24) = 40;
start_times(25) = 40;

start_frame = transpose(sample_frequency).*start_times;    % [-]
end_frame = transpose(sample_frequency).*end_time;

%% Extract data from files
M = struct();
M = extract_tsv(M,filepath,folder,sample_frequency,start_frame,end_frame,Amplitude,frequencies);

M(5).Motion.deHeave = []; M(5).Motion.deHeave = detrend(M(5).Motion.Heave);
M(30).Motion.deHeave = []; M(30).Motion.deHeave = detrend(M(30).Motion.Heave);

for i = 1:18
    M(i).Amplitude = Amplitude(1)/1000;
end

%% Resample motion data and find analysis window
diffThreshold = 0.2;
sample_frequency=[500,128];
sz = 31;
for i = 1:sz
    z = M(i).Motion.deHeave;
    t = M(i).Motion.Time;


    [analysis_start,analysis_end] = AnalysisWindow(z,M(i).RegFrequency,diffThreshold);

    M(i).Heave = z(analysis_start:analysis_end);

    w = resample(M(i).Wave.deAmplitude,sample_frequency(1),sample_frequency(2));
    M(i).WaveAmp = w(analysis_start:analysis_end)*1000;

    M(i).Time = M(i).Motion.Time(analysis_start:analysis_end);
end
sample_frequency = sample_frequency(2);

%% RAO and Power
sz = 31;
RAO = zeros(sz,1);
AvPower = zeros(sz,1); sdPower = zeros(sz,1);
cw = zeros(sz,1); k_cw = zeros(sz,1); cw_r = zeros(sz,1); 
Cw_max = zeros(sz,1); WavePower = zeros(sz,1);


for i = 1:sz
    
    z = M(i).Heave;
    w = M(i).WaveAmp;

    RAO(i) = FFT_RAO(z,w,sample_frequency);
    M(i).RAO = RAO(i);

    [AvPower(i)] = RegularPower(5.8,z,[500,128]);
    M(i).AvPower = AvPower(i);

    [cw(i), k_cw(i), cw_r(i), Cw_max(i),WavePower(i)] = CaptureWidth(M(i).AvPower,M(i).Amplitude,M(i).RegFrequency,WECRadius);
end

%% Organise Data into different amplitudes
cy_small = 18;

[fSCy,fBCy] = split(frequencies,cy_small);

graph = [RAO,AvPower,cw,k_cw,cw_r,Cw_max,WavePower];
[SGCy,BGCy] = split(graph,cy_small);

[fSCy,SGCy] = sortit(fSCy,SGCy);
[fBCy,BGCy] = sortit(fBCy,BGCy);


%% Plot Graphs
% Plot RAO
figure(1)
plot(fSCy,SGCy(:,1),'r-')
hold on 
plot(fBCy,BGCy(:,1),'b-')
grid on
hold off
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf RAO','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm')
title(['Regular wave frequency and RAO for ',M(1).WEC])

% Plot Power
figure(2)
plot(fSCy,SGCy(:,2),'r-')
hold on 
plot(fBCy,BGCy(:,2),'b-')
hold off
grid on
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf Average Power [W]','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm')
title(['Regular wave frequency and power for ',M(1).WEC])


% Plot Capture Width
figure(3)
plot(fSCy,SGCy(:,3),'r-')
hold on 
plot(fBCy,BGCy(:,3),'b-')
hold off
grid on
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf Capture Width [m]','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm')
title(['Regular wave capture width for ',M(1).WEC])

% Plot capture width ratio (k.Cw)
figure(4)
plot(fSCy,SGCy(:,4),'r-')
hold on 
plot(fBCy,BGCy(:,4),'b-')
hold off
grid on
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf Capture Width Ratio $(k\frac{P}{P_I}$)','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm')
title(['Regular wave capture width for ',M(1).WEC])

% Plot capture width ratio (Cw/D)
figure(5)
plot(fSCy,SGCy(:,5),'r-')
hold on 
plot(fBCy,BGCy(:,5),'b-')
hold off
grid on
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf Capture Width Ratio $(\frac{P}{P_I*D}$)','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm')
title(['Regular wave capture width for ',M(1).WEC])


% Plot theoretical max power with power captured
AbPow1 = SGCy(:,6).*SGCy(:,7);
AbPow2 = BGCy(:,6).*BGCy(:,7);

figure(5)
plot(fSCy,SGCy(:,2),'r-')
hold on 
plot(fBCy,BGCy(:,2),'b-')
plot(fSCy,AbPow1,'r--')
plot(fBCy,AbPow2,'b--')
hold off
grid on
ylim([0 5])
xlabel('\bf Frequency [Hz]','Interpreter','latex')
ylabel('\bf Average Power [W]','Interpreter','latex')
legend('Amplitude = 18mm','Amplitude = 36mm','Maximum Available Power (18 mm)','Maximum Available Power (36 mm)')
title(['Regular wave capture width for ',M(1).WEC])
