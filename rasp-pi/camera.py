from picamera2 import Picamera2
from time import sleep
from libcamera import controls

class Camera:
    def __init__(self):
        self.camera = Picamera2()
        config = self.camera.create_video_configuration(
            main={"size": (1280, 720),
                  "format": "RGB888"}
        )
        self.camera.configure(config)
	self.camera.set_controls({"AfMode": controls.AfModeEnum.Continuous})

    def start(self):
        self.camera.start()
        sleep(2)

    def get_frame(self):
        frame = self.camera.capture_array()
        return frame

    def stop(self):
        self.camera.stop()
        self.camera.close()
        print("Kamera stoppet.")
