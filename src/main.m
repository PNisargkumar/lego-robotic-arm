clear;
clc;
mylego = legoev3('usb');
% x & y co-orcinates of the flatforms
% heights of the platforms are variable and measured 
ax = 117.9;
ay = 0;
bx = 0;
by = 117.9;
cx = -117.9;
cy = 0;
disp('Calibrating Encoders and go to home')
robo = Robot(mylego,ax,ay,bx,by,cx,cy);
disp('Going to Home position')
robo.zuHause()
disp('Reading Platform Heights')
robo.hoehelesen();
disp('Performing Invverse kinematics using geometical approach')
robo.invKinT2();
disp('Performing action 5')
funf(robo);
disp('Performing action 6')
sechs(robo);
disp('Performing action 7')
sieben(robo);
disp('Performing action 8')
acht(robo);
disp('Performing action 9')
neun(robo);
disp('Performing action 10')
zehn(robo);
