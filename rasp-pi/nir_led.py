from gpiozero import LED, PWMLED

sensor = DistanceSensor(        # -||-
    echo = 24,                    
    trigger = 23, 
    max_distance = 1
    )

class nIR_LED:
    def __init__(self):
        self.nIR = PWMLED(18, frequency = 1000)
        self.led = LED(17)

    def on(self):
        self.nIR.value = 0.75
        self.led.on()

    def off(self):
        self.nIR.value = 0
        self.led.off()

    def close(self):
        self.nIR.close()
        self.led.close()


""" if sensor.distance <= trigger_distance:
    nIR_LED.on

else:
    nIR_LED.off """