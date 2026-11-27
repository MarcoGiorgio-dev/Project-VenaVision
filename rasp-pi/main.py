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
    remote_dir = "/project_venavision/Project-VenaVision/flasksite/static"
)

nir = NIR_led()
cam = Camera()
dist = Distance()           # VIGTIGT: Tjek ultrasound_sensor.py før brug!
step = Stepper()
vib = VibrationMotor()
mark = False
pic = False
mark_time = time.monotonic()
MARK_INTERVAL = 30
TRIGGER_DISTANCE = 0.10     # 10 cm, men vi skal selv teste hvad der fungere bedst.

def janitor():
    nir.close()
    dist.close()
    cam.close()
    step.close()
    vib.close()

try:
    while True:
        GAP = dist.get_distance()
        print(f"Distance: {GAP}")

        if GAP <= TRIGGER_DISTANCE:
            if pic is False:
                nir.on()
                cam.start()
                mr_vein = cam.get_frame()
                send.send_pic(mr_vein)
                cam.stop()
                pic = True
                vib.vib()
            if mark is False:
                step.mark(10)
                mark = True
                mark_time = time.monotonic()
            elif time.monotonic() - mark_time >= MARK_INTERVAL:
                mark = False
        else:
            nir.off()
            mark = False
            pic = False

except KeyboardInterrupt:
    print("Stopping VenaVision...")
except Exception as e:
    print(f"Stopping VenaVision with error: {type(e).__name__}: {e}")
finally:
    janitor()
