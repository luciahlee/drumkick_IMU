%% ROB 435 Quantifying Human Motion Through Wearable Sensors %%
%% Final Project %%
%% Authors: Lucia Lee, Nathan Kuo, Keerthi Marri, Mason Niu

%{
Script to analyze drumkick data and send analysis like drum beats, type of
kick used

IMU will be placed on the outside of the foot with the x-axis pointing to
the toes, y-axis pointing down to the ground, and z-axis pointing towards
the inside of the leg
%}

%% setup
clear;
clc;

% load data from csv file
data = readtable('initial_data/2026_03_31_11h_58m_55s_heeltoe.csv'); % change to actual data filename
time = (data.timestamp - data.timestamp(1)) / 1000;
gyros = data{:, {'gyro_x', 'gyro_y', 'gyro_z'}};  
accels = data{:, {'accl_x', 'accl_y', 'accl_z'}}; 
mags = data{:, {'mag_x', 'mag_y', 'mag_z'}};    

fs = 1 / mean(diff(time)); % sampling frequency

%% Compute Magnitudes
accel_mag = sqrt(sum(accels.^2, 2));
gyro_mag  = sqrt(sum(gyros.^2, 2));

%% Filter Signals (remove noise + gravity drift)
fc = 0.5; % cutoff frequency (Hz)
[b,a] = butter(2, fc/(fs/2), 'high');

accel_filt = filtfilt(b, a, accel_mag);
gyro_filt  = filtfilt(b, a, gyro_mag);

%% Detect Kicks (Peak Detection)
minPeakHeight = std(accel_filt) * 2;
minPeakDistance = round(0.25 * fs); % ~250 ms spacing

[peaks, locs] = findpeaks(accel_filt, ...
    'MinPeakHeight', minPeakHeight, ...
    'MinPeakDistance', minPeakDistance);

kick_times = time(locs);
num_kicks = length(locs);

%% Feature Extraction
window = round(0.2 * fs); % 200 ms window

features = zeros(num_kicks, 4);
% [peak_accel, peak_gyro, duration, energy]

for i = 1:num_kicks
    idx = locs(i);
    
    start_idx = max(1, idx - window);
    end_idx   = min(length(time), idx + window);
    
    acc_seg = accel_filt(start_idx:end_idx);
    gyro_seg = gyro_filt(start_idx:end_idx);
    
    features(i,1) = max(acc_seg);              % peak accel
    features(i,2) = max(gyro_seg);             % peak gyro
    features(i,3) = (end_idx - start_idx)/fs;  % duration
    features(i,4) = sum(acc_seg.^2);           % energy
end

%% Tempo Analysis
if num_kicks > 1
    intervals = diff(kick_times);
    tempo = 1 ./ intervals; % kicks per second
else
    tempo = [];
end

avg_tempo = mean(tempo, 'omitnan');
tempo_std = std(tempo, 'omitnan');

%% Kick Classification (Simple)
strength = features(:,1);
threshold = mean(strength);

kick_type = strings(num_kicks,1);
for i = 1:num_kicks
    if strength(i) > threshold
        kick_type(i) = "Hard";
    else
        kick_type(i) = "Soft";
    end
end

%% Visualization
figure;

subplot(3,1,1);
plot(time, accel_filt); hold on;
plot(kick_times, peaks, 'ro');
title('Acceleration (Filtered) with Kick Detection');
xlabel('Time (s)'); ylabel('Accel');

subplot(3,1,2);
plot(time, gyro_filt);
title('Gyroscope Magnitude');
xlabel('Time (s)'); ylabel('Gyro');

subplot(3,1,3);
if ~isempty(tempo)
    plot(kick_times(2:end), tempo, '-o');
    ylabel('Kicks/sec');
else
    text(0.5,0.5,'Not enough kicks','HorizontalAlignment','center');
end
title('Tempo Over Time');
xlabel('Time (s)');

%% Output Summary
fprintf('Kicks detected: %d\n', num_kicks);
fprintf('Average tempo: %.2f kicks/sec\n', avg_tempo);
fprintf('Tempo std dev: %.2f\n', tempo_std);

%% Results Table
results = table(kick_times, ...
                features(:,1), ...
                features(:,2), ...
                features(:,3), ...
                features(:,4), ...
                kick_type, ...
    'VariableNames', {'Time','PeakAccel','PeakGyro','Duration','Energy','Type'});

disp(results);