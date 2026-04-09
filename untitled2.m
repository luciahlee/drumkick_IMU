
%% 1c) %%
% provide a plot that shows the magnitude of the gyroscope, the magnitude of the
% accelerometers, and markers for your stride segmentation. State how many strides were found from
% your parsed data.

figure;
plot(time_s, omega_y, time_s, acc_global(:, 3));
xlabel('Time (s)');
ylabel('Angular Velocity (rad/s) and accelerometer');
title('Angular Velocity and Magnetometer Data with Stride Detection');
legend('Angular Velocity', 'Accelerometer');
grid on;

start = 120;
finish = 900;
Stance_Duration_Min = 90; %.1 seconds - 100 steps
Gyro_threshold = 0.7; %rad/sec
Acc_threshold = 0.4; %m/s^2
stride_plot = zeros(length(omega_y), 1);
on = 0;

for i = start:finish 
    if abs(omega_y(i)) < Gyro_threshold && abs(acc_y(i)) < Acc_threshold && i - on >= Stance_Duration_Min
        stride_plot(i) = 1; % Mark the stride in the stride_plot array
        % Mark the stride
        hold on;
        plot(time_s(i), 0, 'bo'); % Mark the point on the plot
        if stride_plot(i) == 1
            on = i;
        end
    end
end

figure;
plot(time_s, stride_plot);
title("Peaks when data meets gyro and acc threshold")
xlabel('Time (s)');
[row, col] = find(stride_plot);
[pks, locs] = findpeaks(stride_plot);

stride_count = length(pks);

fprintf('Number of strides detected: %d\n', stride_count);