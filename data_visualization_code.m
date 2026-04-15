%% ROB 435 Quantifying Human Motion Through Wearable Sensors %%
%% Final Project %%
%% Authors: Lucia Lee, Nathan Kuo, Keerthi Marri, Mason Niu

clear;
close all;

% INITIAL CALIBRATION / TEST DATA
analyzeAndPlotIMU('initial_data/heel_down_side.csv', 'Heel Down Side', 'heeldown');
analyzeAndPlotIMU('initial_data/heel_up_side.csv', 'Heel Up Side', 'heelup');
analyzeAndPlotIMU('initial_data/heel_up_down_side.csv', 'Heel Up/Down Side', 'heelupdown');

% PARTICIPANT 1 DATA

% Pop
analyzeAndPlotIMU('initial_data/p1p2/participant1/2026_04_14_04h_24m_19s_pop1p1.csv', 'P1 Pop 1', 'p1pop1');
analyzeAndPlotIMU('initial_data/p1p2/participant1/2026_04_14_04h_40m_00s_pop2p1.csv', 'P1 Pop 2', 'p1pop2');

% Jazz
analyzeAndPlotIMU('initial_data/p1p2/participant1/2026_04_14_04h_55m_04s_jazzp1p1.csv', 'P1 Jazz 1', 'p1jazz1');

% Shuffle
analyzeAndPlotIMU('initial_data/p1p2/participant1/2026_04_14_05h_06m_27s_shuffle1p1.csv', 'P1 Shuffle 1', 'p1shuffle1');
analyzeAndPlotIMU('initial_data/p1p2/participant1/2026_04_14_05h_12m_12s_shuffle2p1.csv', 'P1 Shuffle 2', 'p1shuffle2');

% Rock
analyzeAndPlotIMU('initial_data/p1p2/participant1/2026_04_14_14h_09m_18s_rock1p1.csv', 'P1 Rock 1', 'p1rock1');
analyzeAndPlotIMU('initial_data/p1p2/participant1/2026_04_14_14h_12m_23s_rock2p1.csv', 'P1 Rock 2', 'p1rock2');


% PARTICIPANT 2 DATA

% Pop
analyzeAndPlotIMU('initial_data/p1p2/participant2/2026_04_14_17h_46m_14s_pop1p2.csv', 'P2 Pop 1', 'p2pop1');
analyzeAndPlotIMU('initial_data/p1p2/participant2/2026_04_14_17h_49m_59s_pop2p2.csv', 'P2 Pop 2', 'p2pop2');

% Rock
analyzeAndPlotIMU('initial_data/p1p2/participant2/2026_04_14_17h_52m_21s_rock1p2.csv', 'P2 Rock 1', 'p2rock1');
analyzeAndPlotIMU('initial_data/p1p2/participant2/2026_04_14_18h_06m_10s_rock2p2.csv', 'P2 Rock 2', 'p2rock2');

% Jazz
analyzeAndPlotIMU('initial_data/p1p2/participant2/2026_04_14_17h_57m_35s_jazz1p2.csv', 'P2 Jazz 1', 'p2jazz1');

% Shuffle
analyzeAndPlotIMU('initial_data/p1p2/participant2/2026_04_14_18h_00m_08s_shuffle1p2.csv', 'P2 Shuffle 1', 'p2shuffle1');
analyzeAndPlotIMU('initial_data/p1p2/participant2/2026_04_14_18h_02m_03s_shuffle2p2.csv', 'P2 Shuffle 2', 'p2shuffle2');


% PARTICIPANT 3 DATA

% Pop
analyzeAndPlotIMU('initial_data/p1p2/participant3/2026_04_14_21h_44m_59s_pop1p3.csv', 'P3 Pop 1', 'p3pop1');
analyzeAndPlotIMU('initial_data/p1p2/participant3/2026_04_14_21h_47m_23s_pop2p3.csv', 'P3 Pop 2', 'p3pop2');

% Jazz
analyzeAndPlotIMU('initial_data/p1p2/participant3/2026_04_14_21h_53m_42s_jazz1p3.csv', 'P3 Jazz 1', 'p3jazz1');

% Shuffle
analyzeAndPlotIMU('initial_data/p1p2/participant3/2026_04_14_21h_57m_26s_shuffle1p3.csv', 'P3 Shuffle 1', 'p3shuffle1');
analyzeAndPlotIMU('initial_data/p1p2/participant3/2026_04_14_22h_08m_27s_shuffle2p3.csv', 'P3 Shuffle 2', 'p3shuffle2');

% Rock
analyzeAndPlotIMU('initial_data/p1p2/participant3/2026_04_14_22h_10m_59s_rock1p3.csv', 'P3 Rock 1', 'p3rock1');
analyzeAndPlotIMU('initial_data/p1p2/participant3/2026_04_14_22h_17m_25s_rock2p3.csv', 'P3 Rock 2', 'p3rock2');

fprintf('=== ALL DATA PROCESSED AND SAVED ===\n');


function analyzeAndPlotIMU(filename, trialName, filePrefix)
    fprintf('--- Processing: %s ---\n', trialName);
    
    % Extract the directory path from the filename
    [filepath, ~, ~] = fileparts(filename);

    % Load the data 
    dataTab = readtable(filename);

    % Define gravity
    g = 9.80665; %m/s^2

    % Pull out the time vector
    tvec_ms = dataTab.timestamp - dataTab.timestamp(1); % Time was recorded in ms
    tvec_s = tvec_ms / 1000; % Convert time to s

    % Pull out the angular velocity data and convert to rad/sec
    omega_x = dataTab.gyro_x * pi/180;
    omega_y = dataTab.gyro_y * pi/180;
    omega_z = dataTab.gyro_z * pi/180;

    % Pull out the accelerations, convert to units of m/s^2
    acc_x = dataTab.accl_x * g;
    acc_y = dataTab.accl_y * g;
    acc_z = dataTab.accl_z * g;

    % Pull out the magnetometer data
    mag_x = dataTab.mag_x;
    mag_y = dataTab.mag_y;
    mag_z = dataTab.mag_z;

    % Normalize the accelerometer data
    IMU_accel_norm = sqrt(acc_x.^2 + acc_y.^2 + acc_z.^2);

    % Organize the gyro, accel, and mag data
    gyros = [omega_x omega_y omega_z];
    accels = [acc_x acc_y acc_z];
    mags = [mag_x mag_y mag_z];

    % PLOT 1: All Sensors Over Time (Combined Axes)
    fig1 = figure('Name', [trialName ' - All Sensor Data'], 'visible', 'off');
    sgtitle([trialName ' - Magnetometer, Gyroscope, and Accelerometer']);
    
    subplot(311)
    plot(tvec_s, mags)
    legend('Mx', 'My', 'Mz')
    ylabel('Mag (\muT)')

    subplot(312)
    plot(tvec_s, gyros)
    legend('Gx', 'Gy', 'Gz')
    ylabel('Gyro (rad/s)')

    subplot(313)
    plot(tvec_s, accels)
    hold on
    plot(tvec_s, IMU_accel_norm, 'k', 'LineWidth', 1.5)
    legend('Ax', 'Ay', 'Az','Norm')
    xlabel('Time (s)')
    ylabel('Accel (m/s^2)')

    % Save to the exact directory where the CSV lives
    exportgraphics(fig1, fullfile(filepath, [filePrefix 'main.png']), 'Resolution', 300);
    close(fig1);

    % PLOT 2: Angular Velocity Separated by Axis (Spread Apart)
    fig2 = figure('Name', [trialName ' - Angular Velocity Separated'], 'visible', 'off');
    sgtitle([trialName ' - Angular Velocity Separated by Axis']);

    subplot(311)
    plot(tvec_s, omega_x, 'r')
    ylabel('Gx (rad/s)')
    grid on

    subplot(312)
    plot(tvec_s, omega_y, 'g')
    ylabel('Gy (rad/s)')
    grid on

    subplot(313)
    plot(tvec_s, omega_z, 'b')
    xlabel('Time (s)')
    ylabel('Gz (rad/s)')
    grid on

    exportgraphics(fig2, fullfile(filepath, [filePrefix 'ang.png']), 'Resolution', 300);
    close(fig2);

    % PLOT 3: Acceleration Separated by Axis (Spread Apart)
    fig3 = figure('Name', [trialName ' - Acceleration Separated'], 'visible', 'off');
    sgtitle([trialName ' - Acceleration Separated by Axis']);

    subplot(411)
    plot(tvec_s, acc_x, 'r')
    ylabel('Ax (m/s^2)')
    grid on

    subplot(412)
    plot(tvec_s, acc_y, 'g')
    ylabel('Ay (m/s^2)')
    grid on

    subplot(413)
    plot(tvec_s, acc_z, 'b')
    ylabel('Az (m/s^2)')
    grid on

    subplot(414)
    plot(tvec_s, IMU_accel_norm, 'k')
    xlabel('Time (s)')
    ylabel('Norm (m/s^2)')
    grid on

    exportgraphics(fig3, fullfile(filepath, [filePrefix 'acc.png']), 'Resolution', 300);
    close(fig3);

end
