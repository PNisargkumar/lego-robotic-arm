classdef Robot < handle
    % Declaring all variable
    properties
        % Robot sensors & actuators
        mylego
        j1Sensor
        link3
        sonic
        eemotor
        j2motor
        j1motor
        % Links length
        l0 = 55
        l1 = 50
        l2 = 95
        l3 = 185
        l4 = 110 - 38
        % Gear Ratio or joint angles to encoder values (with error adjusted)
        j1scale = 3.33
        j2scale = 4
        % Current Robo Station
        cpos = 'A'
        p_a_a % Platform A angle
        p_b_a % Platform B angle
        p_c_a % Platform C angle
        p_a_h % Platform A height
        p_b_h % Platform B height
        p_c_h % Platform C height
        
    end
    methods
        % Initializing Robot Configuration
        function obj = Robot(input,ax,ay,bx,by,cx,cy)
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
            % Detemining Theta1 base angles
            if ax == 0
                obj.p_a_a = 90;
            elseif ax < 0 && ay <= 0
                obj.p_a_a = atand(ay / ax) + 180;
            else
                obj.p_a_a = atand(ay / ax);
            end
            
            if bx == 0
                obj.p_b_a = 90;
            elseif bx < 0 && by <= 0
                obj.p_b_a = atand(by / bx) + 180;
            else
                obj.p_b_a = atand(by / bx);
            end
            
            if cx == 0
                obj.p_c_a = 90;
            elseif cx < 0 && cy <= 0
                obj.p_c_a = atand(cy / cx) + 180;
            else
                obj.p_c_a = atand(cy / cx);
            end
        end
        % Go to Home Position
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
            % Converting base angles values to encoder values (Theta1)
            obj.p_a_a = floor(obj.p_a_a * obj.j1scale);
            obj.p_b_a = floor(obj.p_b_a * obj.j1scale);
            obj.p_c_a = floor(obj.p_c_a * obj.j1scale);
            obj.goto('B')
        end
        % Reading & calculating Platform Heights using sonic sensor
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
        % Detemining Theta2 angle & converting to encoder values
        function invKinT2(obj)
            obj.p_a_h = floor((asind((obj.p_a_h - obj.l0 - obj.l1 - (obj.l2 * sind(45)) + obj.l4) / obj.l3) + 45) * obj.j2scale);
            obj.p_b_h = floor((asind((obj.p_b_h - obj.l0 - obj.l1 - (obj.l2 * sind(45)) + obj.l4) / obj.l3) + 45) * obj.j2scale);
            obj.p_c_h = floor((asind((obj.p_c_h - obj.l0 - obj.l1 - (obj.l2 * sind(45)) + obj.l4) / obj.l3) + 45) * obj.j2scale);
        end
        function opengripper(obj)
            while (readRotation(obj.eemotor) < 80)
                obj.eemotor.Speed = 10;
            end
            obj.eemotor.Speed = 0;
        end
        function closegripper(obj)
            while (readRotation(obj.eemotor) > 14)
                obj.eemotor.Speed = -10;
            end
            obj.eemotor.Speed = 0;
        end
        % Goto Station A or B or C
        function goto(obj, station)
            switch station
                case 'A'
                    while (readRotation(obj.j1motor) < obj.p_a_a)
                        obj.j1motor.Speed = 30;
                    end
                    obj.j1motor.Speed = 0;
                    obj.cpos = 'A';
                case 'B'
                    if obj.cpos == 'A'
                        readRotation(obj.j1motor);
                        while (readRotation(obj.j1motor) > -1 * obj.p_b_a)
                            obj.j1motor.Speed = -30;
                        end
                        obj.j1motor.Speed = 0;
                    elseif obj.cpos == 'C'
                        while (readRotation(obj.j1motor) < -1 * obj.p_b_a)
                            obj.j1motor.Speed = 30;
                        end
                        obj.j1motor.Speed = 0;
                    end
                    obj.cpos = 'B';
                case 'C'
                    while (readRotation(obj.j1motor) > -1 * obj.p_c_a)
                        obj.j1motor.Speed = -30;
                    end
                    obj.j1motor.Speed = 0;
                    obj.cpos = 'C';
                otherwise
                    print('error');
            end
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
