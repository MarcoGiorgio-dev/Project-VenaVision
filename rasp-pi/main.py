from nir_led import NIR_led
from ultrasound_sensor import Distance
from camera import Camera

nir = NIR_led()
dist = Distance()
cam = Camera()

def janitor():
    nir.stop()
    dist.stop()
    cam.stop()

try:
    # Rest of code when its done
    pass
except KeyboardInterrupt:
    print("Stopping VenaVision...")
finally:
    janitor()