from gpiozero import OutputDevice
import time

class Stepper:
    def __init__(self):
        self.IN1 = OutputDevice(5)
        self.IN2 = OutputDevice(6)
        self.IN3 = OutputDevice(13)
        self.IN4 = OutputDevice(19)
        
        self.pins = [self.IN1, self.IN2, self.IN3, self.IN4]
        self.sequence = [[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]
        
    def move(self, steps, direction=1):
        sequence = self.sequence if direction == 1 else self.sequence[::-1]
        
        for x in range (steps):
            step = sequence[x % 4]
            
            for i in range(4):
                self.pins[i].value = step[i]
                
            time.sleep(0.005)
        
    def mark(self,steps):
        self.move(steps)
        time.sleep(1)
        self.move(steps, -1)
        self.close()
        
    def close(self):
        for pin in self.pins:
            pin.off()

# TIL TEST
#if __name__ == "__main__":
#    motor = Stepper()
#
#    try:
#        motor.move(500)          # Move 5 steps forward
#        time.sleep(1)
#        motor.move(500, -1)      # Move 5 steps backward
#
#    finally:
#        motor.close()          # Turn off all GPIO pins
