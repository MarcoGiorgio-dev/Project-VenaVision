from nir_led import NIR_led
from ultrasound_sensor import Distance
from camera import Camera
from data_transfer import DataTransfer

send = DataTransfer(
    server_ip = "192.168.20.x",
    username = "gruppe4",
    p_key = "path/til/privat_ssh/nøglen",
    remote_dir = "path/til/flask"
)
nir = NIR_led()
cam = Camera()
dist = Distance()
trigger_distance = 0.10

def janitor():
    nir.stop()
    dist.stop()
    cam.stop()

try:
    # Rest of code when its done
    gap = dist.get_distance()
    if gap <= trigger_distance:
        nir.on()
        cam.start()
        mr_vein = cam.get_frame()

    pass
except KeyboardInterrupt:
    print("Stopping VenaVision...")
finally:
    janitor()