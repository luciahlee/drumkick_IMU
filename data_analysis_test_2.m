%% ROB 435 – Drum Kick Technique Analysis (Improved Version)

clear; clc; close all;

%% Load Data
data = readtable('initial_data/2026_03_31_11h_46m_13s_heel_up.csv');

time = (data.timestamp - data.timestamp(1)) / 1000;
accels = data{:, {'accl_x','accl_y','accl_z'}};
gyros  = data{:, {'gyro_x','gyro_y','gyro_z'}};

fs = 1 / mean(diff(time));

%% Magnitudes
accel_mag = sqrt(sum(accels.^2, 2));
gyro_mag  = sqrt(sum(gyros.^2, 2));

%% Filtering
fc = 0.5;
[b,a] = butter(2, fc/(fs/2), 'high');
accel_filt = filtfilt(b,a,accel_mag);
gyro_filt  = filtfilt(b,a,gyro_mag);

%% Kick Detection
minPeakHeight = 2 * std(accel_filt);
minPeakDistance = round(0.25 * fs);

[peaks, locs] = findpeaks(accel_filt, ...
    'MinPeakHeight', minPeakHeight, ...
    'MinPeakDistance', minPeakDistance);

kick_times = time(locs);
num_kicks = length(locs);

%% Feature Extraction
window = round(0.2 * fs);

peak_accel = zeros(num_kicks,1);
peak_gyro  = zeros(num_kicks,1);
duration   = zeros(num_kicks,1);
energy     = zeros(num_kicks,1);
decay_time = zeros(num_kicks,1);
post_energy = zeros(num_kicks,1);
stillness = zeros(num_kicks,1);

for i = 1:num_kicks
    idx = locs(i);
    start_idx = max(1, idx - window);
    end_idx   = min(length(time), idx + window);

    acc_seg = accel_filt(start_idx:end_idx);
    gyro_seg = gyro_filt(start_idx:end_idx);

    peak_accel(i) = max(acc_seg);
    peak_gyro(i)  = max(gyro_seg);
    duration(i)   = (end_idx - start_idx) / fs;
    energy(i)     = sum(acc_seg.^2);

    % Decay time
    seg = accel_filt(idx:min(length(time), idx + round(0.3*fs)));
    peak_val = seg(1);
    threshold = 0.3 * peak_val;
    below_idx = find(seg < threshold, 1);

    if isempty(below_idx)
        decay_time(i) = length(seg)/fs;
    else
        decay_time(i) = below_idx/fs;
    end

    % Post-impact energy
    post_energy(i) = sum(seg.^2);

    % Stillness metric (gyro after impact)
    tail_len = min(10, length(gyro_seg));
    stillness(i) = mean(abs(gyro_seg(end-tail_len+1:end)));
end

%% Technique Classification (Improved)
%% ORIENTATION-AWARE CLASSIFICATION (SIDE-MOUNTED IMU)

technique = strings(num_kicks,1);

% Pre/post windows (in samples)
pre  = round(0.05 * fs);   % 50 ms before impact
post = round(0.12 * fs);   % 120 ms after impact
quiet = round(0.25 * fs);  % 250 ms after impact

stillness_ratio = zeros(num_kicks,1);

for i = 1:num_kicks
    idx = locs(i);

    % --- PRE-IMPACT MOTION (gyro magnitude) ---
    pre_start = max(1, idx - pre);
    pre_end   = idx - 1;
    pre_motion = mean(abs(gyro_mag(pre_start:pre_end)));

    % --- POST-IMPACT QUIET WINDOW ---
    quiet_start = idx + post;
    quiet_end   = min(length(gyro_mag), idx + quiet);
    post_motion = mean(abs(gyro_mag(quiet_start:quiet_end)));

    % --- STILLNESS RATIO ---
    stillness_ratio(i) = post_motion / pre_motion;

    % --- CLASSIFICATION RULES ---
    if stillness_ratio(i) < 0.20
        technique(i) = "Burying Beater";

    elseif peak_gyro(i) > median(peak_gyro) && duration(i) > 0.15
        technique(i) = "Heel-Up";

    else
        technique(i) = "Heel-Down";
    end
end


%% Tempo
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

%% Technique Clustering
figure;
gscatter(peak_gyro, peak_accel, technique);
xlabel('Peak Gyro'); ylabel('Peak Accel');
title('Kick Technique Classification');

%% Results Table
results = table(kick_times, peak_accel, peak_gyro, duration, energy, ...
                decay_time, post_energy, stillness, technique, ...
    'VariableNames', {'Time','PeakAccel','PeakGyro','Duration','Energy', ...
                      'DecayTime','PostEnergy','Stillness','Technique'});

disp(results);

fprintf('Kicks detected: %d\n', num_kicks);
fprintf('Average tempo: %.2f kicks/sec\n', avg_tempo);
fprintf('Tempo std dev: %.2f\n', tempo_std);
