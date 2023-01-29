clear;
clc;
mylego = legoev3('usb');
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
disp('Performing Inverse kinematics using geometical approach')
robo.invKinT2();
disp('Performing action 5  -- B -> C')
funf(robo);
disp('Performing action 6  -- C -> A')
sechs(robo);
disp('Performing action 7  -- A -> B')
sieben(robo);
disp('Performing action 8  -- B -> A')
acht(robo);
disp('Performing action 9  -- A -> C')
neun(robo);
disp('Performing action 10 -- C -> A')
zehn(robo);
