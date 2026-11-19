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
dist = Distance()           # VIGTIGT: Tjek ultrasound_sensor.py før brug!
TRIGGER_DISTANCE = 0.10     # 10 cm, men vi skal selv teste hvad der fungere bedst.

def janitor():
    nir.close()
    dist.close()
    cam.close()

try:
    while True:
        # Resten af koden skal stå herinde.
        gap = dist.get_distance()

        if gap <= TRIGGER_DISTANCE:
            nir.on()
            cam.start()
            mr_vein = cam.get_frame()
            send.send_pic(mr_vein)
            cam.stop()
        else:
            nir.off()

except KeyboardInterrupt:
    print("Stopping VenaVision...")
finally:
    janitor()
