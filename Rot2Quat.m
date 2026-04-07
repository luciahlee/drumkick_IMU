function q_fromR=Rot2Quat(R)

%This function takes a Rotation matrix and converts to a quaternion
%If you input R_W2IMU it provides q_W2IMU
%If you input R_IMU2W it provides q_IMU2W

tr=trace(R);

m00=R(1,1);
m01=R(2,1);
m02=R(3,1);

m10=R(1,2);
m11=R(2,2);
m12=R(3,2);

m20=R(1,3);
m21=R(2,3);
m22=R(3,3);

if (tr > 0) 
      S = sqrt(tr+1.0) * 2; %S=4*qw 
      qw = 0.25 * S;
      qx = (m21 - m12) / S;
      qy = (m02 - m20) / S; 
      qz = (m10 - m01) / S; 
elseif ((m00 > m11)&&(m00 > m22))   
    S = sqrt(1.0 + m00 - m11 - m22) * 2; % S=4*qx 
    qw = (m21 - m12) / S;
    qx = 0.25 * S;
    qy = (m01 + m10) / S; 
    qz = (m02 + m20) / S; 
elseif (m11 > m22) 
    S = sqrt(1.0 + m11 - m00 - m22) * 2; % S=4*qy
    qw = (m02 - m20) / S;
    qx = (m01 + m10) / S; 
    qy = 0.25 * S;
    qz = (m12 + m21) / S; 
else  
  S = sqrt(1.0 + m22 - m00 - m11) * 2; % S=4*qz
  qw = (m10 - m01) / S;
  qx = (m02 + m20) / S;
  qy = (m12 + m21) / S;
  qz = 0.25 * S;
end

q_fromR=[qw;qx;qy;qz];