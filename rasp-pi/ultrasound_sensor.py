from gpiozero import DistanceSensor
from time import sleep

class Distance:
    def __init__(self):
        self.sensor = DistanceSensor(
            echo=24,        # Der skal en spændingsdeler på mellem Echo og GPIO 24.
            trigger=23,
            max_distance=1
        )

    def get_distance(self):
        return self.sensor.distance

    def close(self):
        self.sensor.close()


# TIL TEST
#dist = Distance()
#try:
#    while True:
#        print(dist.get_distance())
#        sleep(1)
#except KeyboardInterrupt:
#	print("Stopping...")
