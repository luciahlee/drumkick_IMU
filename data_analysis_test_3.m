%% ROB 435 – Drum Kick Technique Analysis (Orientation-Aware, PDR-Based)
% IMU on right foot, side-mounted:
% X -> toes (forward), Y -> floor (down), Z -> inward (medial)

clear; clc; close all;

%% Load Data
data = readtable('initial_data/2026_03_31_11h_58m_11s_bearing the beater.csv');

time = (data.timestamp - data.timestamp(1)) / 1000;  % s

accels = data{:, {'accl_x','accl_y','accl_z'}};
gyros  = data{:, {'gyro_x','gyro_y','gyro_z'}};

fs = 1 / mean(diff(time));   % sampling frequency

%% Filter Signals (orientation-aware)
accel_raw = accels;
gyro_raw  = gyros;

% High-pass to remove drift
fc = 0.5;  % Hz
[b,a] = butter(2, fc/(fs/2), 'high');

accel_mag = sqrt(sum(accel_raw.^2,2));
gyro_mag  = sqrt(sum(gyro_raw.^2,2));

accel_filt = filtfilt(b,a, accel_mag);
gyro_filt  = filtfilt(b,a, gyro_mag);

% Axis-specific filtering
accel_x = filtfilt(b,a, accel_raw(:,1));  % toes direction
accel_y = filtfilt(b,a, accel_raw(:,2));  % vertical
accel_z = filtfilt(b,a, accel_raw(:,3));  % inward

gyro_x = filtfilt(b,a, gyro_raw(:,1));
gyro_y = filtfilt(b,a, gyro_raw(:,2));
gyro_z = filtfilt(b,a, gyro_raw(:,3));    % primary kick axis

%% Personal Dead Reckoning–Style Kick Detection
% Impact = spike in gyro Z * vertical accel
impact_signal = abs(gyro_z) .* abs(accel_y);
impact_signal = impact_signal / max(impact_signal);  % normalize

minPeakHeight   = 0.25;
minPeakDistance = round(0.25 * fs);

[impact_peaks, locs] = findpeaks(impact_signal, ...
    'MinPeakHeight', minPeakHeight, ...
    'MinPeakDistance', minPeakDistance);

kick_times = time(locs);
num_kicks  = length(locs);

%% Feature Extraction + Orientation-Aware Classification
pre   = round(0.05 * fs);   % 50 ms before impact
post  = round(0.12 * fs);   % 120 ms after impact
quiet = round(0.25 * fs);   % 250 ms after impact

peak_accel = zeros(num_kicks,1);
peak_gyro  = zeros(num_kicks,1);
duration   = zeros(num_kicks,1);
energy     = zeros(num_kicks,1);
stillness_ratio = zeros(num_kicks,1);
technique  = strings(num_kicks,1);

for i = 1:num_kicks
    idx = locs(i);

    % Local window around impact for basic features
    win = round(0.2 * fs);
    start_idx = max(1, idx - win);
    end_idx   = min(length(time), idx + win);

    acc_seg  = accel_filt(start_idx:end_idx);
    gyro_seg = gyro_filt(start_idx:end_idx);

    peak_accel(i) = max(acc_seg);
    peak_gyro(i)  = max(gyro_seg);
    duration(i)   = (end_idx - start_idx) / fs;
    energy(i)     = sum(acc_seg.^2);

    % Pre-impact motion (gyro magnitude)
    pre_start = max(1, idx - pre);
    pre_end   = max(pre_start, idx - 1);
    pre_motion = mean(abs(gyro_filt(pre_start:pre_end)));

    % Post-impact quiet window (gyro magnitude)
    quiet_start = min(length(gyro_filt), idx + post);
    quiet_end   = min(length(gyro_filt), idx + quiet);
    if quiet_end > quiet_start
        post_motion = mean(abs(gyro_filt(quiet_start:quiet_end)));
    else
        post_motion = pre_motion; % fallback
    end

    stillness_ratio(i) = post_motion / pre_motion;

    % Orientation-aware classification
    if stillness_ratio(i) < 0.20
        technique(i) = "Burying Beater";
    elseif gyro_z(idx) > median(gyro_z) && accel_x(idx) > median(accel_x)
        technique(i) = "Heel-Up";
    else
        technique(i) = "Heel-Down";
    end
end

%% Tempo Analysis
if num_kicks > 1
    intervals = diff(kick_times);
    tempo = 1 ./ intervals;   % kicks per second
else
    tempo = [];
end

avg_tempo = mean(tempo, 'omitnan');
tempo_std = std(tempo, 'omitnan');

%% Visualization – Signals and Kick Detection
figure;
subplot(3,1,1);
plot(time, accel_filt); hold on;
plot(kick_times, accel_filt(locs), 'ro');
title('Filtered Acceleration Magnitude with Kick Detection');
xlabel('Time (s)'); ylabel('Accel Mag');

subplot(3,1,2);
plot(time, gyro_z);
hold on; stem(kick_times, gyro_z(locs), 'r');
title('Gyro Z (Primary Kick Axis)');
xlabel('Time (s)'); ylabel('Gyro Z');

subplot(3,1,3);
plot(time, impact_signal); hold on;
plot(kick_times, impact_peaks, 'ro');
title('Impact Signal (|Gyro Z| * |Accel Y|)');
xlabel('Time (s)'); ylabel('Impact Signal');

%% Bar Graph – Technique Distribution
% Count each technique
cats = categories(categorical(technique));
counts = countcats(categorical(technique));

% Bar graph
figure;
bar(counts);
set(gca, 'XTickLabel', cats);
xlabel('Technique');
ylabel('Count');
title('Kick Technique Distribution');


%% Bar/Stem – Technique Over Time
figure;
stem(kick_times, double(categorical(technique)), 'filled');
title('Kick Technique Over Time');
xlabel('Time (s)');
ylabel('Technique ID');
yticks([1 2 3]);
yticklabels({'Burying Beater','Heel-Down','Heel-Up'});

%% Results Table
results = table(kick_times, peak_accel, peak_gyro, duration, energy, ...
                stillness_ratio, technique, ...
    'VariableNames', {'Time','PeakAccel','PeakGyro','Duration','Energy', ...
                      'StillnessRatio','Technique'});

disp(results);

fprintf('Kicks detected: %d\n', num_kicks);
fprintf('Average tempo: %.2f kicks/sec\n', avg_tempo);
fprintf('Tempo std dev: %.2f\n', tempo_std);
