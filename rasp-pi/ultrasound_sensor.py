from gpiozero import DistanceSensor
import time
test_time = time.monotonic()
test_interval = 2

class Distance:
    def __init__(self):
        self.sensor = DistanceSensor(
            echo=24,
            trigger=23,
            max_distance=1
        )

    def get_distance(self):
        if time.monotonic() - test_time >= test_interval:
            print(f"Distance: {DistanceSensor()}")
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
