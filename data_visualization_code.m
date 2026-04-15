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
analyzeAndPlotIMU('initial_data/p1p2/participant1/2026_04_14_04h_24m_19s_pop1p1.csv', 'P1 Pop 1', 'p1pop1', 45, 70);
analyzeAndPlotIMU('initial_data/p1p2/participant1/2026_04_14_04h_40m_00s_pop2p1.csv', 'P1 Pop 2', 'p1pop2', 10, 35);

% Jazz
analyzeAndPlotIMU('initial_data/p1p2/participant1/2026_04_14_04h_55m_04s_jazzp1p1.csv', 'P1 Jazz 1', 'p1jazz1', 18, 35);

% Shuffle
analyzeAndPlotIMU('initial_data/p1p2/participant1/2026_04_14_05h_06m_27s_shuffle1p1.csv', 'P1 Shuffle 1', 'p1shuffle1', 35, 80);
analyzeAndPlotIMU('initial_data/p1p2/participant1/2026_04_14_05h_12m_12s_shuffle2p1.csv', 'P1 Shuffle 2', 'p1shuffle2', 17, 40);

% Rock
analyzeAndPlotIMU('initial_data/p1p2/participant1/2026_04_14_14h_09m_18s_rock1p1.csv', 'P1 Rock 1', 'p1rock1', 15, 47);
analyzeAndPlotIMU('initial_data/p1p2/participant1/2026_04_14_14h_12m_23s_rock2p1.csv', 'P1 Rock 2', 'p1rock2', 0, 60); % Data is weird (initial range)



% PARTICIPANT 2 DATA

% Pop
analyzeAndPlotIMU('initial_data/p1p2/participant2/2026_04_14_17h_46m_14s_pop1p2.csv', 'P2 Pop 1', 'p2pop1', 59, 83);
analyzeAndPlotIMU('initial_data/p1p2/participant2/2026_04_14_17h_49m_59s_pop2p2.csv', 'P2 Pop 2', 'p2pop2', 22, 65);

% Jazz
analyzeAndPlotIMU('initial_data/p1p2/participant2/2026_04_14_17h_57m_35s_jazz1p2.csv', 'P2 Jazz 1', 'p2jazz1', 32, 79);

% Shuffle
analyzeAndPlotIMU('initial_data/p1p2/participant2/2026_04_14_18h_00m_08s_shuffle1p2.csv', 'P2 Shuffle 1', 'p2shuffle1', 17, 60);
analyzeAndPlotIMU('initial_data/p1p2/participant2/2026_04_14_18h_02m_03s_shuffle2p2.csv', 'P2 Shuffle 2', 'p2shuffle2', 36, 60);

% Rock
analyzeAndPlotIMU('initial_data/p1p2/participant2/2026_04_14_17h_52m_21s_rock1p2.csv', 'P2 Rock 1', 'p2rock1', 45, 110);
analyzeAndPlotIMU('initial_data/p1p2/participant2/2026_04_14_18h_06m_10s_rock2p2.csv', 'P2 Rock 2', 'p2rock2', 55, 80);



% PARTICIPANT 3 DATA

% Pop
analyzeAndPlotIMU('initial_data/p1p2/participant3/2026_04_14_21h_44m_59s_pop1p3.csv', 'P3 Pop 1', 'p3pop1', 30, 53);
analyzeAndPlotIMU('initial_data/p1p2/participant3/2026_04_14_21h_47m_23s_pop2p3.csv', 'P3 Pop 2', 'p3pop2', 8, 40);

% Jazz
analyzeAndPlotIMU('initial_data/p1p2/participant3/2026_04_14_21h_53m_42s_jazz1p3.csv', 'P3 Jazz 1', 'p3jazz1', 16, 37);

% Shuffle 
analyzeAndPlotIMU('initial_data/p1p2/participant3/2026_04_14_21h_57m_26s_shuffle1p3.csv', 'P3 Shuffle 1', 'p3shuffle1', 13, 54);
analyzeAndPlotIMU('initial_data/p1p2/participant3/2026_04_14_22h_08m_27s_shuffle2p3.csv', 'P3 Shuffle 2', 'p3shuffle2', 11, 34);

% Rock
analyzeAndPlotIMU('initial_data/p1p2/participant3/2026_04_14_22h_10m_59s_rock1p3.csv', 'P3 Rock 1', 'p3rock1', 22, 67);
analyzeAndPlotIMU('initial_data/p1p2/participant3/2026_04_14_22h_17m_25s_rock2p3.csv', 'P3 Rock 2', 'p3rock2', 16, 37);



% PARTICIPANT 4 DATA 

% Pop
analyzeAndPlotIMU('initial_data/p1p2/participant4/2026_04_15_14h_10m_21s_pop1p4.csv', 'P4 Pop 1', 'p4pop1', 30, 56);
analyzeAndPlotIMU('initial_data/p1p2/participant4/2026_04_15_14h_18m_45s_pop2p4.csv', 'P4 Pop 2 (Run 1)', 'p4pop2_run1', 20, 51);
analyzeAndPlotIMU('initial_data/p1p2/participant4/2026_04_15_14h_23m_51s_pop2p4.csv', 'P4 Pop 2 (Run 2)', 'p4pop2_run2', 0, 280); % idk its long

% Jazz
analyzeAndPlotIMU('initial_data/p1p2/participant4/2026_04_15_14h_28m_48s_jazz1p4.csv', 'P4 Jazz 1', 'p4jazz1', 26, 60);

% Shuffle
analyzeAndPlotIMU('initial_data/p1p2/participant4/2026_04_15_14h_31m_44s_shuffle1p4.csv', 'P4 Shuffle 1', 'p4shuffle1', 20, 60);
analyzeAndPlotIMU('initial_data/p1p2/participant4/2026_04_15_14h_35m_17s_shuffle2p4.csv', 'P4 Shuffle 2', 'p4shuffle2', 9, 30);

% Rock
analyzeAndPlotIMU('initial_data/p1p2/participant4/2026_04_15_14h_58m_00s_rock1p4.csv', 'P4 Rock 1', 'p4rock1', 20, 55);

fprintf('=== ALL DATA PROCESSED AND SAVED ===\n');


function analyzeAndPlotIMU(filename, trialName, filePrefix, startTime, endTime)
    fprintf('--- Processing: %s ---\n', trialName);
    
    % Extract the directory path from the filename
    [filepath, ~, ~] = fileparts(filename);

    % Load the data 
    dataTab = readtable(filename);

    % Define gravity
    g = 9.80665; %m/s^2

    % Pull out the full time vector
    tvec_ms_full = dataTab.timestamp - dataTab.timestamp(1); 
    tvec_s_full = tvec_ms_full / 1000; 

    % Handle missing start/end times (defaults to full file)
    if nargin < 4 || isempty(startTime)
        startTime = 0;
    end
    if nargin < 5 || isempty(endTime)
        endTime = tvec_s_full(end);
    end

    % Create logical mask to crop data within the specified time window
    time_idx = (tvec_s_full >= startTime) & (tvec_s_full <= endTime);

    % Apply mask to time vector
    tvec_s = tvec_s_full(time_idx);

    % Format strings for titles and filenames
    timeStrTitle = sprintf('(%.1fs - %.1fs)', startTime, endTime);
    timeStrFile = sprintf('_%g-%gs', startTime, endTime);

    % Pull out and crop the angular velocity data
    omega_x = dataTab.gyro_x(time_idx) * pi/180;
    omega_y = dataTab.gyro_y(time_idx) * pi/180;
    omega_z = dataTab.gyro_z(time_idx) * pi/180;

    % Pull out and crop the accelerations
    acc_x = dataTab.accl_x(time_idx) * g;
    acc_y = dataTab.accl_y(time_idx) * g;
    acc_z = dataTab.accl_z(time_idx) * g;

    % Pull out and crop the magnetometer data
    mag_x = dataTab.mag_x(time_idx);
    mag_y = dataTab.mag_y(time_idx);
    mag_z = dataTab.mag_z(time_idx);

    % Normalize the cropped accelerometer data
    IMU_accel_norm = sqrt(acc_x.^2 + acc_y.^2 + acc_z.^2);

    % Organize the cropped gyro, accel, and mag data
    gyros = [omega_x omega_y omega_z];
    accels = [acc_x acc_y acc_z];
    mags = [mag_x mag_y mag_z];

    % PLOT 1: All Sensors Over Time (Combined Axes)
    fig1 = figure('Name', [trialName ' - All Sensor Data'], 'visible', 'off');
    sgtitle([trialName ' ' timeStrTitle ' - Magnetometer, Gyroscope, and Accelerometer']);
    
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

    % Save to the exact directory where the CSV lives with timestamp in name
    saveName1 = fullfile(filepath, [filePrefix timeStrFile '_main.png']);
    exportgraphics(fig1, saveName1, 'Resolution', 300);
    close(fig1);

    % PLOT 2: Angular Velocity Separated by Axis (Spread Apart)
    fig2 = figure('Name', [trialName ' - Angular Velocity Separated'], 'visible', 'off');
    sgtitle([trialName ' ' timeStrTitle ' - Angular Velocity Separated by Axis']);

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

    saveName2 = fullfile(filepath, [filePrefix timeStrFile '_ang.png']);
    exportgraphics(fig2, saveName2, 'Resolution', 300);
    close(fig2);

    % PLOT 3: Acceleration Separated by Axis (Spread Apart)
    fig3 = figure('Name', [trialName ' - Acceleration Separated'], 'visible', 'off');
    sgtitle([trialName ' ' timeStrTitle ' - Acceleration Separated by Axis']);

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
    plot(tvec_s, IMU_accel_norm, 'k', 'LineWidth', 1.5)
    xlabel('Time (s)')
    ylabel('Norm (m/s^2)')
    grid on

    saveName3 = fullfile(filepath, [filePrefix timeStrFile '_acc.png']);
    exportgraphics(fig3, saveName3, 'Resolution', 300);
    close(fig3);

end