classdef Robot < handle
    properties
        mylego
        j1Sensor
        link3
        sonic
        eemotor
        j2motor
        j1motor
        cpos = 'A'
        
    end
    methods
        function obj = Robot(input)
            obj.mylego = input;
            obj.j1Sensor = touchSensor(obj.mylego,1);
            obj.link3 = touchSensor(obj.mylego,3);
            obj.sonic = sonicSensor(obj.mylego,2);
            obj.eemotor = motor(obj.mylego,'A');
            obj.j2motor = motor(obj.mylego,'B');
            obj.j1motor = motor(obj.mylego,'C');
            start(obj.j2motor)
            start(obj.j1motor)
            start(obj.eemotor)

        end
        function zuHause(obj)
            while(~readTouch(obj.link3))
                obj.j2motor.Speed = -30;
            end
            obj.j2motor.Speed = 0;
            resetRotation(obj.j2motor)
            while(~readTouch(obj.j1Sensor))
                obj.j1motor.Speed = 20;
            end
            obj.j1motor.Speed = 0;
            resetRotation(obj.j1motor)
            obj.eemotor.Speed = -20;
            pause(1)
            obj.eemotor.Speed = 0;
            resetRotation(obj.eemotor);
            while (readRotation(obj.j1motor) >= -300)
                obj.j1motor.Speed = -20;
                %                 readRotation(obj.j1motor)
            end
            obj.j1motor.Speed = 0;
            obj.cpos = 'B';
        end
        function dist = leseDistanz(obj)
            dist = readDistance(obj.sonic);
        end
        function opengripper(obj)
            while (readRotation(obj.eemotor) < 80)
                obj.eemotor.Speed = 10;
                %                 readRotation(obj.eemotor)
            end
            obj.eemotor.Speed = 0;
        end
        function closegripper(obj)
            while (readRotation(obj.eemotor) > 14)
                obj.eemotor.Speed = -10;
                %                 readRotation(obj.eemotor)
            end
            obj.eemotor.Speed = 0;
        end
        function goto(obj,station)
            switch station
                case 'A'
                    while (readRotation(obj.j1motor) < 0)
                        obj.j1motor.Speed = 20;
                    end
                    obj.j1motor.Speed = 0;
                    obj.cpos = 'A';
                    
                case 'B'
                    if obj.cpos == 'A'
                        readRotation(obj.j1motor);
                        while (readRotation(obj.j1motor) > -300)
                            obj.j1motor.Speed = -20;
                        end
                        obj.j1motor.Speed = 0;
                        
                    elseif obj.cpos == 'C'
                        while (readRotation(obj.j1motor) < -300)
                            obj.j1motor.Speed = 20;
                        end
                        obj.j1motor.Speed = 0;
                        
                    end
                    obj.cpos = 'B';
                    
                case 'C'
                    while (readRotation(obj.j1motor) > -600)
                        obj.j1motor.Speed = -20;
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
            while (readDistance(obj.sonic) > 0.058)
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