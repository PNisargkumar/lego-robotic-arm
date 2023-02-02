classdef Robot_pid < handle
    properties
        % Robot sensors & actuators
        mylego
        j1Sensor
        link3
        sonic
        eemotor
        j2motor
        j1motor

        % Link lengths
        l0 = 55
        l1 = 50
        l2 = 95
        l3 = 185
        l4 = 110 - 45

        % Gear Ratio or joint angles to encoder values (with error adjusted)
        j1scale = 3.33
        j2scale = 4

        % Variables for station and control
        cpos = 'A'
        p_a_a % Platform A angle
        p_b_a % Platform B angle
        p_c_a % Platform C angle
        p_a_h % Platform A height
        p_b_h % Platform B height
        p_c_h % Platform C height

        % variables for PID controller
        kp = 0.25
        ki = 0.08
        kd = 0.03
        currentTime
        previousTime
        elapsedTime
        error
        prevError
        input
        output
        Setpoint
        cumError
        rateError
        SetPoint
    end
    methods
        % Initializing Robot Configuration
        function obj = Robot_pid(input,ax,ay,bx,by,cx,cy)
            obj.mylego = input;
            obj.j1Sensor = touchSensor(obj.mylego, 1);
            obj.link3 = touchSensor(obj.mylego, 3);
            obj.sonic = sonicSensor(obj.mylego, 2);
            obj.eemotor = motor(obj.mylego, 'A');
            obj.j2motor = motor(obj.mylego, 'B');
            obj.j1motor = motor(obj.mylego, 'C');
            start(obj.j2motor)
            start(obj.j1motor)
            start(obj.eemotor)

            % Inverse kinematics for Theta 1
            obj.p_a_a = atan2d(ay, ax);
            obj.p_b_a = atan2d(by, bx);
            obj.p_c_a = atan2d(cy, cx);
        end
        function zuHause(obj)
            % Calibrating motor B
            while(~readTouch(obj.link3))
                obj.j2motor.Speed = -30;
            end
            obj.j2motor.Speed = 0;
            resetRotation(obj.j2motor)

            % Calibrating motor A
            while(~readTouch(obj.j1Sensor))
                obj.j1motor.Speed = 30;
            end
            obj.j1motor.Speed = 0;
            resetRotation(obj.j1motor)

            % Calibrating Gripper Motor
            obj.eemotor.Speed = -30;
            pause(1)
            obj.eemotor.Speed = 0;
            resetRotation(obj.eemotor);

            % Converting Theta 1 values to encoder values
            obj.p_a_a = floor(obj.p_a_a * obj.j1scale);
            obj.p_b_a = floor(obj.p_b_a * obj.j1scale);
            obj.p_c_a = floor(obj.p_c_a * obj.j1scale);
            obj.goto('B')
            pause(1)
        end
        function hoehelesen(obj)
            obj.goto('A')
            pause(1);
            obj.p_a_h = readDistance(obj.sonic) * 1000;
            obj.goto('B')
            pause(1);
            obj.p_b_h = readDistance(obj.sonic) * 1000;
            obj.goto('C')
            pause(1);
            obj.p_c_h = readDistance(obj.sonic) * 1000;
            obj.goto('B')
        end

        % Detemining Theta2 & converting to encoder values
        function invKinT2(obj)
            obj.p_a_h = floor((asind((obj.p_a_h - obj.l0 - obj.l1 - (obj.l2 * sind(45)) + obj.l4) / obj.l3) + 45) * obj.j2scale);
            obj.p_b_h = floor((asind((obj.p_b_h - obj.l0 - obj.l1 - (obj.l2 * sind(45)) + obj.l4) / obj.l3) + 45) * obj.j2scale);
            obj.p_c_h = floor((asind((obj.p_c_h - obj.l0 - obj.l1 - (obj.l2 * sind(45)) + obj.l4) / obj.l3) + 45) * obj.j2scale);
        end
        function opengripper(obj)
            while (readRotation(obj.eemotor) < 80)
                obj.eemotor.Speed = 20;
            end
            obj.eemotor.Speed = 0;
        end
        function closegripper(obj)
            while (readRotation(obj.eemotor) > 14)
                obj.eemotor.Speed = -20;
            end
            obj.eemotor.Speed = 0;
        end

        % Goto Station A or B or C
        function goto(obj, station)
            obj.SetPoint = station;
            if obj.SetPoint == 'A'
                obj.Setpoint = obj.p_a_a;
            elseif obj.SetPoint == 'B'
                obj.Setpoint = obj.p_b_a;
            else
                obj.Setpoint = obj.p_c_a;
            end
            obj.error = obj.Setpoint +  readRotation(obj.j1motor);
            tic();
            obj.previousTime = 0;
            obj.cumError = 0;
            obj.prevError = 0; 
            while(obj.error > 2 || obj.error < -2)
                obj.currentTime = toc;                                                                  % get current time
                obj.error = readRotation(obj.j1motor) + obj.Setpoint;                                   % determine error
                obj.elapsedTime = (obj.currentTime - obj.previousTime);                                 % compute time elapsed from previous computation
                obj.rateError = (obj.error - obj.prevError) / obj.elapsedTime;                          % rate error
                obj.cumError = obj.cumError + (obj.error * obj.elapsedTime);                            % compute integral
                obj.j1motor.Speed = -(obj.kp * obj.error + obj.ki * obj.cumError + obj.kd * obj.rateError);   % PID output
                obj.prevError = obj.error;                                                              % remember current error
                obj.previousTime = obj.currentTime;                                                     % remember current time
            end
            obj.j1motor.Speed = 0;
            obj.cpos = obj.SetPoint;
        end
        function oben(obj)
            while (readRotation(obj.j2motor) > 0)
                obj.j2motor.Speed = -40;
                readRotation(obj.j2motor);
            end
            obj.j2motor.Speed = 0;
        end
        function unten(obj)
            if obj.cpos == 'A'
                temp = obj.p_a_h;
            elseif obj.cpos == 'B'
                temp = obj.p_b_h;
            else
                temp = obj.p_c_h;
            end

            while (readRotation(obj.j2motor) < temp)
                obj.j2motor.Speed = 20;
                readRotation(obj.j2motor);
            end
            obj.j2motor.Speed = 0;
        end
        function holen(obj)
            obj.opengripper();
            obj.unten();
            obj.closegripper();
            obj.oben();
        end
        function legen(obj)
            obj.unten();
            obj.opengripper();
            obj.oben();
            obj.closegripper();
        end
    end
end