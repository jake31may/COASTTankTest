function Q = extract_tsv(Q,filepath,folder,sample_frequency,start_frame,end_frame,Amplitude,frequencies)

%% Import Motion and Wave Data from folder
% This script is capable of analysing multiple runs of data. Ensure all the
% files required for analysis (both Qualysis and wave gauge data) in a
% single folder.
% This script will extract relevent .tsv and .txt files for analysis when
% the the filepath is correct and selected when prompted.

end_time = end_frame(2,:)./sample_frequency(2);
start_time = start_frame(2,:)./sample_frequency(2);

f = waitbar(0,'Looking for that folder that your .tsv files are in 8-)')

d           = uigetdir(pwd, folder);

% Extracts Qualysis filenames (.tsv files)
files       = dir(fullfile(d, '*.tsv'));
filename    = {files.name}';

% Extracts Wave gauge filenames (.txt files) 
files2      = dir(fullfile(d, '*.txt'));
filename2   = {files2.name}';

% Determines structure size.
sz          = size(filename,1);

% Importing data from directory: 
for i= 1:sz
    i
    f = waitbar(i/sz,f,'I am slowly loading your .tsv files now.');
    len         = [length(filename{i,1}),length(filename2{i,1})];
    Q(i).Name   = filename{i,:};

    if Q(i).Name(1) == char('M')
        Q(i).WEC = 'Reference Cylinder';
    else
        if Q(i).Name(1) == 'P'
            Q(i).WEC = 'Compound Cylinder';
        else
            Q(i).WEC = 'Diamond';
        end
    end

    if str2num(Q(i).Name(2:3)) < (1+sz/2)
        Q(i).Amplitude = 0.018;
    else
        Q(i).Amplitude = 0.036;
    end

    Q(i).RegFrequency = frequencies(i);

    % Load the data for Qualysis and wave gauges into struct.
    allData     = readtable([filepath filename{i,1}(1:len(1))], 'FileType', 'text'); 
    allData2    = readtable([filepath filename2{i,1}(1:len(2))], 'FileType', 'text'); 
    
    Q(i).Motion.Time           = table2array(allData(start_frame(1,i):end_frame(1,i),2));               %[s]   Time 
    
    Q(i).Motion.Still = mean(table2array(allData(1:5*sample_frequency(1),5)));
    Q(i).Motion.Heave = table2array(allData(start_frame(1,i):end_frame(1,i),5));         %[mm]

    Q(i).Motion.deHeave = Q(i).Motion.Heave-Q(i).Motion.Still;
    
    % Load in wave data
    allData2(1:3,:) = [];
    Q(i).Wave.Amplitude = table2array(allData2(start_frame(2,i):end_frame(2,i),2));
    Q(i).Wave.Still = mean(table2array(allData2(1:5*sample_frequency(2),2)));

    Q(i).Wave.deAmplitude = Q(i).Wave.Amplitude - Q(i).Wave.Still;
    time_interval = (end_time(i)-start_time(i)).*sample_frequency(2)+1;
    Q(i).Wave.Time = transpose(linspace(start_time(i),end_time(i),time_interval));
end
f = waitbar(1,f,'Phew - All Done!');