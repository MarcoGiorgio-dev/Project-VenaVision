import time
from nir_led import NIR_led
from ultrasound_sensor import Distance
from camera import Camera
from stepper_motor import Stepper
from data_transfer import DataTransfer

send = DataTransfer(
    server_ip = "192.168.1.10",
    username = "gruppe4",
    p_key = None,
    remote_dir = "/project_venavision/Project-VenaVision/flasksite"
)
nir = NIR_led()
cam = Camera()
dist = Distance()           # VIGTIGT: Tjek ultrasound_sensor.py før brug!
step = Stepper()
TRIGGER_DISTANCE = 0.10     # 10 cm, men vi skal selv teste hvad der fungere bedst.
now = time.monotonic()
interval = 30
mark_set = False

def janitor():
    nir.close()
    dist.close()
    cam.close()
    step.close()

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
            if mark_set == False:
                step.mark(10)
                mark_set = True
                now = time.monotonic()
            elif time.monotonic() - now >= interval:
                mark_set = False
        else:
            nir.off()
            mark_set = False

except KeyboardInterrupt:
    print("Stopping VenaVision...")
finally:
    janitor()
