from gpiozero import DigitalOutputDevice

VIB_PIN = 22

class VibrationMotor:
    def __init__(self, pin=VIB_PIN):
        self.motor = DigitalOutputDevice(pin)

    def double_vib(self, pulse=0.2, delay=0.15):
        self.motor.blink(on_time=pulse, off_time=delay, n=2, background=True)

    def stop(self):
        self.motor.off()

    def close(self):
        self.motor.off()
        self.motor.close()