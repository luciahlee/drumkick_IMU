%% ROB 435 Quantifying Human Motion Through Wearable Sensors %%
%% Final Project %%
%% Authors: Lucia Lee, Nathan Kuo, Keerthi Marri, Mason Niu
clear

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