clearvars
close all 
clc

%% Script to understand Gemma's Qualysis data

Scale_factor = 1/70;
Wave_Amplitude_FS = 1.5/2;                          % [m]
Wave_Amplitude = Wave_Amplitude_FS*Scale_factor;    % [m]

sample_rate = 128;                                  % [Hz]

start_frame = 20*sample_rate;                       % [-]
end_frame = 150 * sample_rate;

DOFs = categorical(["Surge","Sway",'Heave','Yaw','Pitch','Roll']);

%% Import Motion Data

filepath   = ('Users/jakehollins/Documents/MATLAB/Gemz Data/');

d = uigetdir(pwd, 'Gemz Data/');
files = dir(fullfile(d, '*.tsv'));
filename = {files.name}';

files2 = dir(fullfile(d, '*.txt'));
filename2 = {files2.name}';

sz= size(filename,1);

for i= 1:sz
    len = length(filename{i,1});
    len2 = length(filename2{i,1});
    Q(i).Name = filename{i,:};
    % Load the data for Qualysis and wave gauges into struct.
    allData = readtable([filepath filename{i,1}(1:len)], 'FileType', 'text'); 
    allData2 = readtable([filepath filename2{i,1}(1:len2)], 'FileType', 'text'); 
    
    Q(i).test(1).Time           = table2array(allData(start_frame:end_frame,2));               %[s]   Time 
    
    for dof = 1:6
        Q(i).test.Motion(:,dof) = table2array(allData(start_frame:end_frame,dof+2));         %[mm]   Position and normalization
    end

    Q(i).wave.Data              = table2array(allData2(start_frame:end_frame,2));
end

%% Analyse Qualysis displacement
len = length(Q(i).test.Time);
% No Normalisation
for dof = 1:6
    figure()

    for i = 2
        
        Q(i).test.detrendMotion(:,dof) = detrend(Q(i).test.Motion(:,dof));

        time    = Q(i).test.Time;
        yms     = Q(i).test.detrendMotion(:,dof);
        yws     = Q(i).wave.Data(1:len,1)*1000;

        plot(time,yms,'b')

        hold on
        plot(time,yws,'r')
        hold off

        title(['Wave amplitude and displacement of FOWT in ',DOFs(dof)])
        ylabel('Displacement [mm]')
        xlabel('Time [s]')
        
        legend('Model','Wave')
        

    end
end

%% Find amplitudes
% For wave data
n = 40;                      % number of waves
for i = 1:sz
    [W_peak,] = findpeaks(Q(i).wave.Data,'NPeaks',n,'SortStr','descend','MinPeakProminence',0.005);
    [W_trough,] = findpeaks(-Q(i).wave.Data,'NPeaks',n,'SortStr','descend','MinPeakProminence',0.005);
    MaxWave(i) = mean(W_peak(5:n));
    MinWave(i) = mean(W_trough(5:n));
end
WaveAmplitude = ((MaxWave+MinWave)/2)';
disp('Model Wave Amplitudes [m] for each run: ')
disp("________________________________________")
C = cell2mat(filename); C1 = char(repelem("   :   ",10)');C2 = char(num2str(WaveAmplitude));
disp([C,C1,C2])
disp("   ")



% For FOWT data
prominence = [0.05,0.05,0.05,0.05,0.005,0.005];
for dof = 1:6
    for i = 1:sz
        [peak,] = findpeaks(Q(i).test.Motion(:,dof),'NPeaks',n,'SortStr','descend','MinPeakProminence',prominence(dof));
        [trough,] = findpeaks(-Q(i).test.Motion(:,dof),'NPeaks',n,'SortStr','descend','MinPeakProminence',0.005);
        MaxHeave(i) = mean(peak(5:n));
        MinHeave(i) = mean(trough(5:n));
    end
Amplitude(1:sz,dof) = ((MaxHeave+MinHeave)/2)';
end
disp('   FOWT Amplitudes for each run: ')
disp('    Surge      Sway      Heave     Yaw      Pitch       Roll')
disp('    ________________________________________________________')
disp(Amplitude)

%% RAO

RAO = Amplitude./(WaveAmplitude*1000)
disp('   FOWT RAOs for each run: ')
disp('    Surge      Sway      Heave     Yaw      Pitch       Roll')
disp('    ________________________________________________________')
disp(RAO)