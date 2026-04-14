%% ROB 435 Quantifying Human Motion Through Wearable Sensors
%% Final Project
%% Drum Kick Technique Analysis

%{
Analyzes IMU data to detect drum kicks and classify technique:
- Heel-Up
- Heel-Down
- Burying the Beater

Expected CSV columns:
time, accl_x, accl_y, accl_z, gyro_x, gyro_y, gyro_z
%}

%% Setup
clear; clc; close all;

%% Load Data
data = readtable('initial_data/2026_03_31_11h_58m_55s_heeltoe.csv');

time = (data.timestamp - data.timestamp(1)) / 1000;

accels = data{:, {'accl_x','accl_y','accl_z'}};
gyros  = data{:, {'gyro_x','gyro_y','gyro_z'}};

fs = 1 / mean(diff(time)); % sampling frequency

%% Compute Magnitudes
accel_mag = sqrt(sum(accels.^2, 2));
gyro_mag  = sqrt(sum(gyros.^2, 2));

%% Filter Signals (remove drift + noise)
fc = 0.5; % Hz cutoff
[b,a] = butter(2, fc/(fs/2), 'high');

accel_filt = filtfilt(b, a, accel_mag);
gyro_filt  = filtfilt(b, a, gyro_mag);

%% Detect Kicks
minPeakHeight = std(accel_filt) * 2;
minPeakDistance = round(0.25 * fs);

[peaks, locs] = findpeaks(accel_filt, ...
    'MinPeakHeight', minPeakHeight, ...
    'MinPeakDistance', minPeakDistance);

kick_times = time(locs);
num_kicks = length(locs);

%% Feature Extraction
window = round(0.2 * fs);

features = zeros(num_kicks, 4);
% [peak_accel, peak_gyro, duration, energy]

for i = 1:num_kicks
    idx = locs(i);
    
    start_idx = max(1, idx - window);
    end_idx   = min(length(time), idx + window);
    
    acc_seg = accel_filt(start_idx:end_idx);
    gyro_seg = gyro_filt(start_idx:end_idx);
    
    features(i,1) = max(acc_seg);
    features(i,2) = max(gyro_seg);
    features(i,3) = (end_idx - start_idx) / fs;
    features(i,4) = sum(acc_seg.^2);
end

%% Advanced Features (for technique classification)
decay_time = zeros(num_kicks,1);
post_energy = zeros(num_kicks,1);

for i = 1:num_kicks
    idx = locs(i);
    
    end_window = min(length(time), idx + round(0.3 * fs));
    segment = accel_filt(idx:end_window);
    
    peak_val = segment(1);
    
    threshold = 0.3 * peak_val;
    below_idx = find(segment < threshold, 1);
    
    if ~isempty(below_idx)
        decay_time(i) = below_idx / fs;
    else
        decay_time(i) = (end_window - idx) / fs;
    end
    
    post_energy(i) = sum(segment.^2);
end

%% Technique Classification
technique = strings(num_kicks,1);

for i = 1:num_kicks
    
    peak_accel = features(i,1);
    peak_gyro  = features(i,2);
    dur        = features(i,3);
    decay      = decay_time(i);
    energy_post = post_energy(i);
    
    % Heuristic classification
    if decay > 0.15 && energy_post > mean(post_energy)
        technique(i) = "Burying Beater";
        
    elseif peak_gyro > mean(features(:,2)) && dur > 0.15
        technique(i) = "Heel-Up";
        
    else
        technique(i) = "Heel-Down";
    end
end

%% Tempo Analysis
if num_kicks > 1
    intervals = diff(kick_times);
    tempo = 1 ./ intervals;
else
    tempo = [];
end

avg_tempo = mean(tempo, 'omitnan');
tempo_std = std(tempo, 'omitnan');

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

%% Technique Clustering Plot
figure;
gscatter(features(:,2), features(:,1), technique);
xlabel('Peak Gyro');
ylabel('Peak Accel');
title('Kick Technique Classification');
legend;

%% Output Results
fprintf('Kicks detected: %d\n', num_kicks);
fprintf('Average tempo: %.2f kicks/sec\n', avg_tempo);
fprintf('Tempo std dev: %.2f\n', tempo_std);

%% Results Table
results = table(kick_times, ...
                features(:,1), ...
                features(:,2), ...
                features(:,3), ...
                features(:,4), ...
                decay_time, ...
                post_energy, ...
                technique, ...
    'VariableNames', {'Time','PeakAccel','PeakGyro','Duration','Energy','DecayTime','PostEnergy','Technique'});

disp(results);