%% ROB 435 Quantifying Human Motion Through Wearable Sensors %%
%% Final Project %%
%% Authors: Lucia Lee, Nathan Kuo, Keerthi Marri, Mason Niu
clear
close all;

% Load the data 
dataTab = readtable('initial_data/2026_03_31_11h_58m_55s_heeltoe.csv');

%Define gravity
g=9.80665; %m/s^s

%Pull out the time vector
tvec_ms=dataTab.timestamp-dataTab.timestamp(1); %Time was recorded in ms
tvec_s=tvec_ms/1000; %Convert time to s

%Pull out the angular velocity data and convert to rad/sec
omega_x=dataTab.gyro_x*pi/180;
omega_y=dataTab.gyro_y*pi/180;
omega_z=dataTab.gyro_z*pi/180;

%Pull out the accelerations, convert to units of m/s^2
acc_x=dataTab.accl_x*g;
acc_y=dataTab.accl_y*g;
acc_z=dataTab.accl_z*g;

%Pull out the magnetometer data
mag_x=dataTab.mag_x;
mag_y=dataTab.mag_y;
mag_z=dataTab.mag_z;

% Normalize the accelerometer data
IMU_accel_norm = sqrt(acc_x.^2 + acc_y.^2 + acc_z.^2);

%From the data that was loaded, we will organize the gyro data and
%accelerometer data
gyros=[omega_x omega_y omega_z];
accels=[acc_x acc_y acc_z];
mags=[mag_x mag_y mag_z];

figure;
subplot(311)
plot(tvec_s,mags)
legend('Mx', 'My', 'Mz')
xlabel('Time')
ylabel('Magnetometer')
sgtitle('Heel Toe')

subplot(312)
plot(tvec_s,gyros)
legend('Gx', 'Gy', 'Gz')
xlabel('Time')
ylabel('Gyro')

subplot(313)
plot(tvec_s,accels)
hold
plot(tvec_s,IMU_accel_norm)
legend('Ax', 'Ay', 'Az','Norm')
xlabel('Time')
ylabel('Accelerometer')

%{
Script to analyze drumkick data and send analysis like drum beats, type of
kick used.

IMU will be placed on the outside of the foot with the x-axis pointing to
the toes, y-axis pointing up, and the z axis pointing in towards the feet.
%}

N  = length(tvec_s);
dt = mean(diff(tvec_s));
% EKF parameters
noise_gyro  = 0.001;
noise_accel = 0.020;
noise_mag   = 0.2;

bias_w   = [0 0 0];   % estimated biases
bias_a   = 0;         % scalar accel bias 
initX    = [1;0;0;0]; % identity quaternion
initP    = 1e-4*eye(4);
epsilon_acc = 0.5;    % example threshold 

% Run EKF
[allX, allP, flags] = IMU_Orientation_EKF_agm_IOEROB( ...
    gyros, accels, mags, dt, ...
    bias_w, bias_a, initX, initP, ...
    noise_gyro, noise_accel, noise_mag, epsilon_acc);

% Kick detection
% Nathan HW code
gyro_mag = sqrt(sum(gyros.^2, 2));
T_gyro = 12.0;   % rad/s
is_stance = (gyro_mag < T_gyro);
stance_starts = find(diff([0; is_stance]) == 1);
stance_ends   = find(diff([is_stance; 0]) == -1);
% Lucia HW code
start = 1;
finish = 739;
Stance_Duration_Min = 90; %.1 seconds - 100 steps
Gyro_threshold = 1.4; %rad/sec
Acc_threshold = 0.8; %m/s^2
stride_plot = zeros(length(omega_y), 1);
on = 0;

% Stance intervals
for i = start:finish 
    if abs(omega_y(i)) < Gyro_threshold && abs(acc_y(i)) < Acc_threshold && i - on >= Stance_Duration_Min
        stride_plot(i) = 1; % Mark the stride in the stride_plot array
        % Mark the stride
        hold on;
        plot(tvec_s(i), 0, 'bo'); % Mark the point on the plot
        if stride_plot(i) == 1
            on = i;
        end
    end
end

figure;
plot(tvec_s, stride_plot);
title("Peaks when data meets gyro and acc threshold")
xlabel('Time (s)');
[row, col] = find(stride_plot);
[pks, locs] = findpeaks(stride_plot);

stride_count = length(pks);

fprintf('Number of strides detected: %d\n', stride_count);

% Nathan HW code
% Midpoints = stride markers
stance_mid = round((stance_starts + stance_ends)/2);

stride_start_idx = stance_mid(1:end-1);
stride_end_idx   = stance_mid(2:end);

num_strides = length(stride_start_idx);
fprintf('Detected %d strides\n', num_strides);

% Plot with markers
figure; hold on;
plot(tvec_s, gyro_mag, 'b');
yline(T_gyro, 'r--', 'Threshold');
for i = 1:num_strides
    xline(tvec_s(stride_start_idx(i)), 'k--');
end
title('Gyro Magnitude with Stride Boundaries')
xlabel('Time (s)')
ylabel('||\omega|| (rad/s)')
