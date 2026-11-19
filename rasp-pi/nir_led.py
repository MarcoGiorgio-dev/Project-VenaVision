from gpiozero import LED, PWMLED

class NIR_LED:
    def __init__(self):
        self.NIR = PWMLED(18, frequency = 1000)
        self.led = LED(17)

    def on(self):
        self.NIR.value = 0.75
        self.led.on()

    def off(self):
        self.NIR.value = 0
        self.led.off()

    def close(self):
        self.NIR.close()
        self.led.close()


""" if sensor.distance <= trigger_distance:
    nIR_LED.on

else:
    nIR_LED.off """