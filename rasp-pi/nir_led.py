from gpiozero import LED, PWMLED

class NIR_led:
    def __init__(self):
        self.nir = PWMLED(18, frequency = 1000)
        self.led = LED(17)

    def on(self):
        self.nir.value = 0.75
        self.led.on()

    def off(self):
        self.nir.value = 0
        self.led.off()

    def stop(self):
        self.nir.close()
        self.led.close()


""" if sensor.distance <= trigger_distance:
    nIR_LED.on

else:
    nIR_LED.off """