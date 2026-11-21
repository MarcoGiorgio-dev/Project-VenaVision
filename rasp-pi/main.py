import time
from nir_led import NIR_led
from ultrasound_sensor import Distance
from camera import Camera
from stepper_motor import Stepper
from data_transfer import DataTransfer
from vibration_motor import VibrationMotor

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
vib = VibrationMotor()
TRIGGER_DISTANCE = 0.10     # 10 cm, men vi skal selv teste hvad der fungere bedst.
NOW = time.monotonic()
INTERVAL = 30
MARK_SET = False

def janitor():
    nir.close()
    dist.close()
    cam.close()
    step.close()

try:
    while True:
        # Resten af koden skal stå herinde.
        GAP = dist.get_distance()

        if GAP <= TRIGGER_DISTANCE:
            nir.on()
            cam.start()
            mr_vein = cam.get_frame()
            send.send_pic(mr_vein)
            cam.stop()
            if MARK_SET is False:
                step.mark(10)
                MARK_SET = True
                NOW = time.monotonic()
            elif time.monotonic() - NOW >= INTERVAL:
                MARK_SET = False
        else:
            nir.off()
            MARK_SET = False

except KeyboardInterrupt:
    print("Stopping VenaVision...")
finally:
    janitor()
