from gpiozero import LED, DistanceSensor, PWMLED
from time import sleep

nIR = PWMLED(18, frequency=1000)
led = LED(17)
sensor = DistanceSensor(
    echo=18,
    trigger=17,
    max_distance=1
    )

if sensor.distance == 0.1:
    nIR.value = 0.75
    led.on()

else:
    led.off()
    nIR.value = 0