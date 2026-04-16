%% ROB 435 Quantifying Human Motion Through Wearable Sensors
%% Final Project
%% Heel-Up vs Heel-Down Classification (Gyro Z Based)

%{
Analyzes IMU data to:
- Detect drum kicks
- Classify technique:
    Heel-Up  -> |negative gyro_z peak| > |positive peak|
    Heel-Down -> |positive peak| > |negative peak|

Expected CSV columns:
time, accl_x, accl_y, accl_z, gyro_x, gyro_y, gyro_z
%}

%% Setup
clear; clc; close all;

%% Load Data:
% DATA FOR EACH PARTICIPANT IS P1, P2, P3, AND P4
% pop1 data: Lush Life - Zara Larsson
%data = readtable('initial_data/p1p2/participant1/2026_04_14_04h_24m_19s_pop1p1.csv');
%data = readtable('initial_data/p1p2/participant2/2026_04_14_17h_46m_14s_pop1p2.csv');
%data = readtable('initial_data/p1p2/participant3/2026_04_14_21h_44m_59s_pop1p3.csv');
%data = readtable('initial_data/p1p2/participant4/2026_04_15_14h_10m_21s_pop1p4.csv');


%% pop2 data: Sugar - Maroon 5
%data = readtable('initial_data/p1p2/participant1/2026_04_14_04h_24m_19s_pop1p1.csv');
%data = readtable('initial_data/p1p2/participant2/2026_04_14_17h_46m_14s_pop1p2.csv');
%data = readtable('initial_data/p1p2/participant3/2026_04_14_21h_44m_59s_pop1p3.csv');
%data = readtable('initial_data/p1p2/participant4/2026_04_15_14h_18m_45s_pop2p4.csv');

%% jazz1 data: The Passenger - Iggy Pop
%data = readtable('initial_data/p1p2/participant1/2026_04_14_04h_55m_04s_jazzp1p1.csv');
%data = readtable('initial_data/p1p2/participant2/2026_04_14_17h_57m_35s_jazz1p2.csv');
%data = readtable('initial_data/p1p2/participant3/2026_04_14_21h_53m_42s_jazz1p3.csv');
%data = readtable('initial_data/p1p2/participant4/2026_04_15_14h_28m_48s_jazz1p4.csv');


%% shuffle1 data: Isn't She Lovely - Stevie Wonder
%data = readtable('initial_data/p1p2/participant1/2026_04_14_05h_06m_27s_shuffle1p1.csv');
%data = readtable('initial_data/p1p2/participant2/2026_04_14_18h_00m_08s_shuffle1p2.csv');
%data = readtable('initial_data/p1p2/participant3/2026_04_14_21h_57m_26s_shuffle1p3.csv');
%data = readtable('initial_data/p1p2/participant4/2026_04_15_14h_31m_44s_shuffle1p4.csv');

%% shuffle2 data: Drop it Like it's Hot - Snoop Dogg
%data = readtable('initial_data/p1p2/participant1/2026_04_14_05h_12m_12s_shuffle2p1.csv');
%data = readtable('initial_data/p1p2/participant2/2026_04_14_18h_02m_03s_shuffle2p2.csv');
%data = readtable('initial_data/p1p2/participant3/2026_04_14_22h_08m_27s_shuffle2p3.csv');
%data = readtable('initial_data/p1p2/participant4/2026_04_15_14h_35m_17s_shuffle2p4.csv');

%% rock1 data: Still Into You - Paramore
%data = readtable('initial_data/p1p2/participant1/2026_04_14_14h_09m_18s_rock1p1.csv');
%data = readtable('initial_data/p1p2/participant2/2026_04_14_17h_52m_21s_rock1p2.csv');
%data = readtable('initial_data/p1p2/participant3/2026_04_14_22h_10m_59s_rock1p3.csv')
%data = readtable('initial_data/p1p2/participant4/2026_04_15_14h_58m_00s_rock1p4.csv');


%% rock2 data: In the End - Linkin Park
%data = readtable('initial_data/p1p2/participant1/2026_04_14_14h_12m_23s_rock2p1.csv');
%data = readtable('initial_data/p1p2/participant2/2026_04_14_18h_06m_10s_rock2p2.csv');
%data = readtable('initial_data/p1p2/participant3/2026_04_14_22h_17m_25s_rock2p3.csv');
%data = readtable('initial_data/p1p2/participant4/') NO P4 DATA?


time = (data.timestamp - data.timestamp(1)) / 1000;

accels = data{:, {'accl_x','accl_y','accl_z'}};
gyros  = data{:, {'gyro_x','gyro_y','gyro_z'}};

fs = 1 / mean(diff(time)); % sampling frequency

% cutoff after the initial calibration drumkick
start_idx_global = 3000; % CHANGE THIS ACCORDING TO STARTING TIMESTAMP

time   = time(start_idx_global:end);
accels = accels(start_idx_global:end, :);
gyros  = gyros(start_idx_global:end, :);

%% Compute Acceleration Magnitude (for kick detection)
accel_mag = sqrt(sum(accels.^2, 2));

%% Filter Signals
fc = 0.5; % cutoff frequency (Hz)
[b,a] = butter(2, fc/(fs/2), 'high');

accel_filt = filtfilt(b, a, accel_mag);

% Use gyro_z for classification
gyro_z = gyros(:,3);
gyro_z_filt = filtfilt(b, a, gyro_z);

%% Detect Kicks (from acceleration)
minPeakHeight = std(accel_filt) * 2;
minPeakDistance = round(0.25 * fs);

[peaks, locs] = findpeaks(accel_filt, ...
    'MinPeakHeight', minPeakHeight, ...
    'MinPeakDistance', minPeakDistance);

kick_times = time(locs);
num_kicks = length(locs);

%% Extract Gyro Z Peaks per Kick
window = round(0.2 * fs);

pos_peak = zeros(num_kicks,1);
neg_peak = zeros(num_kicks,1);

for i = 1:num_kicks
    idx = locs(i);
    
    start_idx = max(1, idx - window);
    end_idx   = min(length(time), idx + window);
    
    segment = gyro_z_filt(start_idx:end_idx);
    
    pos_peak(i) = max(segment); % positive rotation
    neg_peak(i) = min(segment); % negative rotation
end

%% Heel-Up vs Heel-Down Classification
heel_type = strings(num_kicks,1);

margin = 1.1; % tuning parameter (1.1–1.5 recommended)

for i = 1:num_kicks
    
    if abs(neg_peak(i)) > margin * abs(pos_peak(i))
        heel_type(i) = "Heel-Up";
        
    elseif abs(pos_peak(i)) > margin * abs(neg_peak(i))
        heel_type(i) = "Heel-Down";
        
    else
        heel_type(i) = "Unclear";
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

%% Visualization

% Acceleration + detected kicks
figure;
subplot(2,1,1);
plot(time, accel_filt); hold on;
plot(kick_times, peaks, 'ro');
title('Kick Detection (Acceleration)');
xlabel('Time (s)');
ylabel('Accel');

% Gyro Z signal
subplot(2,1,2);
plot(time, gyro_z_filt);
title('Gyro Z (Foot Rotation)');
xlabel('Time (s)');
ylabel('Angular Velocity');

% Classification scatter
figure;
scatter(pos_peak, abs(neg_peak), 'filled');
xlabel('Positive Gyro Z Peak');
ylabel('|Negative Gyro Z Peak|');
title('Heel-Up vs Heel-Down Classification');
grid on;

%% Classification Summary

% Count each category
num_heel_up = sum(heel_type == "Heel-Up");
num_heel_down = sum(heel_type == "Heel-Down");
num_unclear = sum(heel_type == "Unclear");

counts = [num_heel_up, num_heel_down, num_unclear];
labels = {'Heel-Up', 'Heel-Down', 'Unclear'};

% Bar graph
figure;
bar(counts);
set(gca, 'XTickLabel', labels);
ylabel('Number of Kicks');
title('Kick Technique Distribution');
grid on;

% Add values on top of bars
for i = 1:length(counts)
    text(i, counts(i) + 0.5, num2str(counts(i)), ...
        'HorizontalAlignment', 'center');
end

%% Output Results
fprintf('Kicks detected: %d\n', num_kicks);
fprintf('Average tempo: %.2f kicks/sec\n', avg_tempo);

%% Results Table
results = table(kick_times, pos_peak, neg_peak, heel_type, ...
    'VariableNames', {'Time','PosPeak','NegPeak','Technique'});

disp(results);

%% Print Classification Breakdown

total_kicks = num_kicks;

pct_heel_up = (num_heel_up / total_kicks) * 100;
pct_heel_down = (num_heel_down / total_kicks) * 100;
pct_unclear = (num_unclear / total_kicks) * 100;

fprintf('\n--- Technique Breakdown ---\n');
fprintf('Heel-Up:   %d (%.1f%%)\n', num_heel_up, pct_heel_up);
fprintf('Heel-Down: %d (%.1f%%)\n', num_heel_down, pct_heel_down);
fprintf('Unclear:   %d (%.1f%%)\n', num_unclear, pct_unclear);