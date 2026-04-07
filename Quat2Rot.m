function [RotMat]=Quat2Rot(q)
%This function is for taking a quaternion that is a representation between
%reference frames and provides the direction cosine matrix 

%Inputting q_G2L provides R_G2L

for i = 1:size(q,1)

    q0=q(i,1);
    q1=q(i,2);
    q2=q(i,3);
    q3=q(i,4);
    
    RotMat(:,:,i)=[q0^2+q1^2-q2^2-q3^2, 2*q1*q2+2*q0*q3,     2*q1*q3-2*q0*q2;...
            2*q1*q2 - 2*q0*q3,   q0^2-q1^2+q2^2-q3^2, 2*q2*q3+2*q0*q1;...
            2*q1*q3 + 2*q0*q2,   2*q2*q3-2*q0*q1,     q0^2-q1^2-q2^2+q3^2];

end %for loop

end
