function [allX,allP,flags]=IMU_Orientation_EKF_agm_IOEROB(gyros,accels,mags,dt,bias_w, bias_a, initX,initP,noise_gyro, noise_accel,noise_mag,epsilon_acc)
%The quaternions over time (allX) are from the Global reference frame to the Local/Sensor reference frame

%gyros is the vector of the angular velocities (rows are time, columns are x/y/z)
%accels is the vector of the accelerations (rows are time, columns are x/y/z)
%mags is the vector of the magnetometers (rows are time, columns are x,y,z)
%bias_w is the bias for the gyroscope and is a 1 x 3 vector, example: [0 0 0]
%bias_a is the bias for the accelerometer and is a 1 x 1 Scalar, example: 0
%initX is the initial value for the quaternion state and is a 4 x 1 vector, example: initX=[1; 0; 0; 0];
%initP is the initial error covariance matrix and is a 4 x 4 matrix, example: initP=(1e-4)*eye(4);
%noise_gyro is the error variance of the gyroscope and is a 1x1 value
%noise_accel is the error variance of the accelerometer and is a 1x1 value
%noise_mag is the error variance of the magnetometers and is a 1x1 value
%grav_meas is the magnitude of the gravity measured by the magnetometer when the sensor is static
%epsilon_acc is the threshold used for comparing the accelerometer data to assess motion condition

% set filter parameters
gc = 9.80665;      % Gravity magnitude, m/s^2

% Preallocation of the array
N = length(gyros);
allX = zeros(N, 4);
allP=zeros(4,4,N);

% Initialization
if ~isempty(initX) % you put in what you wanted the first quaternion to be.
    x=initX(:);
else
    x = [1 0 0 0]'; % else call it the "zero" orientation
end

if ~isempty(initP) % same with initial covariance
    P=initP;
else
    P = 1e-4 * eye(4); % else use this as default initial covariance
end

%Set the initializations into the arrays
allX(1,:) = x'; 
allP(:,:,1)=P; 
flags=zeros(4,1);

% begin loop
for k = 2:N
    % --- gyroscope propogation (prediction) ---
    w = gyros(k,:) - bias_w; % gyro measurements

    % FD matrix (propogation dynamics)
    Omega =[0     -w(1)   -w(2)   -w(3);...
        w(1)  0       w(3)    -w(2); ...
        w(2)  -w(3)   0        w(1); ...
        w(3)  w(2)    -w(1)    0  ];
    FD = eye(4) + dt * Omega / 2;
    
    % Process noise matrix Q
    C = [-x(2)  -x(3)  -x(4); ...
        x(1)  -x(4)   x(3); ...
        x(4)   x(1)  -x(2); ...
        -x(3)   x(2)   x(1)] / 2;
    Q=(dt^2).*C*(noise_gyro*eye(3))*C';
    
    % Propgate the state and covariance
    x = FD * x;
    x = x./norm(x); % normalize 
    P = FD * P * FD' + Q;
    
    % --- Measurement update ---
    a = accels(k,:); % Accelerometer measurements
    
    %Use the non-linear equation to estimate the prediction
    a_predict = gc*[2*(x(2)*x(4)-x(1)*x(3)); ...
                 2*(x(3)*x(4)+x(1)*x(2)); ...
                 x(1)^2-x(2)^2-x(3)^2+x(4)^2];

    m_predict = [x(1)^2+x(2)^2-x(3)^2-x(4)^2;...
                 2*x(2)*x(3)-2*x(1)*x(4);...
                 2*x(2)*x(4)+2*x(1)*x(3)];
    
    % measurement matrix H
    H = 2*[-gc*x(3)    gc*x(4)    -gc*x(1)   gc*x(2); ...
            gc*x(2)    gc*x(1)     gc*x(4)   gc*x(3); ...
            gc*x(1)   -gc*x(2)    -gc*x(3)   gc*x(4);...
               x(1)       x(2)       -x(3)     -x(4);...
              -x(4)       x(3)        x(2)     -x(1);...
               x(3)       x(4)        x(1)      x(2)];
    
    % Measurement noise R is appropriate when the acceleration magnitude is
    % approximately equal to gravity for accelerometer update and when
    % magnetic interference isn't present

    %First check for static
    check_acc=abs(norm(a)-bias_a-gc);

    %Now we check to see if there is a magnetometer disturbance
    m_curr = mags(k,:);
    m_last = mags(k-1,:);
    %Estimate angle from the magnetometer
    theta_mag(k)=acos(dot(m_curr,m_last)/(norm(m_curr)*norm(m_last)));

    %Estimate the angle using the angular velocity quaternion
    q_prev= allX(k-1,:);
    q_prev_conj= [q_prev(1), -q_prev(2), -q_prev(3), -q_prev(4)];
    q_curr=x;
    q_delta=quatmultiply(q_prev_conj,q_curr');
    theta_gyro(k)=2*acos(q_delta(1));

    %determine the difference in the angle moved between the magnetometer
    %and the gyroscope
    check_mag=abs(theta_mag(k)-theta_gyro(k));

    epsilon_mag_deg=10; %deg/s
    epsilon_mag_rad=epsilon_mag_deg*pi/180;

    if (check_mag< epsilon_mag_rad) && (check_acc<epsilon_acc)
        %We don't have magnetic interference
        %Here we can assume static, we are measuring gravity with the
        %accelerometer

        R=[noise_accel 0 0 0 0 0;...
           0 noise_accel 0 0 0 0;...
           0 0 noise_accel  0 0 0;...
           0 0 0 noise_mag 0 0;...
           0 0 0 0 noise_mag 0;...
           0 0 0 0 0 noise_mag];

        flags(1)=flags(1)+1;

    elseif (check_mag< epsilon_mag_rad) && (check_acc>epsilon_acc)
        %HEre we do not have magnetic interference, and we cannot
        %assume static

         R=[1000 0 0 0 0 0;...
           0 1000 0 0 0 0;...
           0 0 1000  0 0 0;...
           0 0 0 noise_mag 0 0;...
           0 0 0 0 noise_mag 0;...
           0 0 0 0 0 noise_mag];

           flags(2)=flags(2)+1;


    elseif (check_mag> epsilon_mag_rad) && (check_acc<epsilon_acc)
        %Here we have magnetic interference and we can assume static
        R=[noise_accel 0 0 0 0 0;...
           0 noise_accel 0 0 0 0;...
           0 0 noise_accel  0 0 0;...
           0 0 0 1000 0 0;...
           0 0 0 0 1000 0;...
           0 0 0 0 0 1000];

        flags(3)=flags(3)+1;

    elseif (check_mag> epsilon_mag_rad) && (check_acc>epsilon_acc)
        %Here we have magnetic interference and we cannot assume static
        R=eye(6)*1000;

        flags(4)=flags(4)+1;
    end
        
    % --- Kalman update ---
    K = P * H' *inv(H * P * H' + R);
    x = x + K * [a'-a_predict; m_curr'-m_predict];
    x = x / norm(x);    % Normalize 
    P = (eye(4) - K * H) * P;
    
    % --- package variables for output ---
    allX(k,:) = x';
    allP(:,:,k)=P;
end
end
