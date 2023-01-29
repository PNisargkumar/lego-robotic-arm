classdef Robot < handle
    properties
        % Robot links and joints
        mylego
        j1Sensor
        link3
        sonic
        eemotor
        j2motor
        j1motor
<<<<<<< HEAD
        l0 = 55
        l1 = 50
        l2 = 95
        l3 = 185
        l4 = 110 - 40
        j1scale = 3.33
        j2scale = 4
        % Variables for station and control
        cpos = 'A'
=======
        % Variables for station and control
        cpos = 'A' % Current Position
>>>>>>> 3ad755b3df2dc63f2967a76170479bbfea6f9e35
        p_a_a % Platform A angle
        p_b_a % Platform B angle
        p_c_a % Platform C angle
        p_a_h % Platform A height
        p_b_h % Platform B height
        p_c_h % Platform C height
        
    end
    methods
        function obj = Robot(input,ax,ay,bx,by,cx,cy)
            % Initializing Robot Configuration
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
<<<<<<< HEAD
            % Initializing Variables
=======

            % Initializing Platform Location in Degrees
>>>>>>> 3ad755b3df2dc63f2967a76170479bbfea6f9e35
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
<<<<<<< HEAD
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
            obj.l0 = 55;
            obj.l1 = 50;
            obj.l2 = 95;
            obj.l3 = 185;
            obj.l4 = 110 - 35;
            obj.j1scale = 3.33;
            obj.j2scale = 4;
=======
                obj.p_b_a =atand(by/bx)+180;
            else
                obj.p_b_a = atand( by/bx );
            end
            
            if cx == 0
                obj.p_c_a =90;
            elseif cx < 0 && cy <= 0
                obj.p_c_a =atand(cy/cx)+180;
            else
                obj.p_c_a = atand( cy/cx );
            end
>>>>>>> 3ad755b3df2dc63f2967a76170479bbfea6f9e35
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
<<<<<<< HEAD
            obj.eemotor.Speed = -30;
            pause(1)
            obj.eemotor.Speed = 0;
            resetRotation(obj.eemotor);
            obj.p_a_a = floor(obj.p_a_a * obj.j1scale);
            obj.p_b_a = floor(obj.p_b_a * obj.j1scale);
            obj.p_c_a = floor(obj.p_c_a * obj.j1scale);
            obj.goto('B')
        end
        function hoehelesen(obj)
            obj.goto('A')
            pause(1);
            obj.p_a_h = readDistance(obj.sonic) *1000;
            obj.goto('B')
            pause(1);
            obj.p_b_h = readDistance(obj.sonic)*1000;
            obj.goto('C')
            pause(1);
            obj.p_c_h = readDistance(obj.sonic)*1000;
            obj.goto('B')
        end
        function invKinT2(obj)
            obj.p_a_h = floor((asind((obj.p_a_h - obj.l0 - obj.l1 - (obj.l2 * sind(45)) + obj.l4) / obj.l3) + 45) * obj.j2scale);
            obj.p_b_h = floor((asind((obj.p_b_h - obj.l0 - obj.l1 - (obj.l2 * sind(45)) + obj.l4) / obj.l3) + 45) * obj.j2scale);
            obj.p_c_h = floor((asind((obj.p_c_h - obj.l0 - obj.l1 - (obj.l2 * sind(45)) + obj.l4) / obj.l3) + 45) * obj.j2scale);
=======
            obj.eemotor.Speed = -20;
            pause(1)
            obj.eemotor.Speed = 0;
            resetRotation(obj.eemotor);

            % Converting angles to encoder counts
            obj.p_a_a = floor(obj.p_a_a * 3.33);
            obj.p_b_a = floor(obj.p_b_a * 3.33);
            obj.p_c_a = floor(obj.p_c_a * 3.33);
            obj.goto('B')
        end
        function hoehelesen(obj)
            % Measuring Platform Heights
            obj.goto('A')
            pause(1);
            obj.p_a_h = readDistance(obj.sonic);
            obj.goto('B')
            pause(1);
            obj.p_b_h = readDistance(obj.sonic);
            obj.goto('C')
            pause(1);
            obj.p_c_h = readDistance(obj.sonic);
            obj.goto('B')
        end
        function invKinT2(obj)
            % Calculating encoder values for the measured platform heights
            obj.p_a_h = floor((asind((obj.p_a_h * 1000 - 132.175) / 185) + 45) * 4.05);
            obj.p_b_h = floor((asind((obj.p_b_h * 1000 - 132.175) / 185) + 45) * 4.05);
            obj.p_c_h = floor((asind((obj.p_c_h * 1000 - 132.175) / 185) + 45) * 4.05);
>>>>>>> 3ad755b3df2dc63f2967a76170479bbfea6f9e35
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
        function goto(obj, station)
            switch station
                case 'A'
                    while (readRotation(obj.j1motor) < obj.p_a_a)
<<<<<<< HEAD
                        obj.j1motor.Speed = 30;
=======
                        obj.j1motor.Speed = 20;
>>>>>>> 3ad755b3df2dc63f2967a76170479bbfea6f9e35
                    end
                    obj.j1motor.Speed = 0;
                    obj.cpos = 'A';
                case 'B'
                    if obj.cpos == 'A'
                        readRotation(obj.j1motor);
                        while (readRotation(obj.j1motor) > -1 * obj.p_b_a)
<<<<<<< HEAD
                            obj.j1motor.Speed = -30;
=======
                            obj.j1motor.Speed = -20;
>>>>>>> 3ad755b3df2dc63f2967a76170479bbfea6f9e35
                        end
                        obj.j1motor.Speed = 0;
                    elseif obj.cpos == 'C'
                        while (readRotation(obj.j1motor) < -1 * obj.p_b_a)
<<<<<<< HEAD
                            obj.j1motor.Speed = 30;
=======
                            obj.j1motor.Speed = 20;
>>>>>>> 3ad755b3df2dc63f2967a76170479bbfea6f9e35
                        end
                        obj.j1motor.Speed = 0;
                    end
                    obj.cpos = 'B';
                case 'C'
                    while (readRotation(obj.j1motor) > -1 * obj.p_c_a)
<<<<<<< HEAD
                        obj.j1motor.Speed = -30;
=======
                        obj.j1motor.Speed = -20;
>>>>>>> 3ad755b3df2dc63f2967a76170479bbfea6f9e35
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
            % function pick the object
            obj.opengripper();
            obj.unten();
            obj.closegripper();
<<<<<<< HEAD
            obj.oben();
=======
            obj.oben();            
>>>>>>> 3ad755b3df2dc63f2967a76170479bbfea6f9e35
        end
        function legen(obj)
            % function place the object
            obj.unten();
            obj.opengripper();
            obj.oben();
            obj.closegripper();
        end
    end
end