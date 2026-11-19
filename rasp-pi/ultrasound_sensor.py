from gpiozero import DistanceSensor

#trigger_distance = 0.10 (Denne skal med i main.py, og står her så vi husker det.)

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