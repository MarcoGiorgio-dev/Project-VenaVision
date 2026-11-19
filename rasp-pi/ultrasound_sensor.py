from gpiozero import DistanceSensor

class Distance:
    def __init__(self):
        self.sensor = DistanceSensor(
            echo=24,        # Der skal en spændingsdeler på mellem Echo og GPIO 24.
            trigger=23,
            max_distance=1
        )

    def get_distance(self):
        return self.sensor.distance

    def stop(self):
        self.sensor.close()
