from pathlib import Path
from time import sleep

from picamera2 import Picamera2
from libcamera import controls

PICTURE_DIR = Path.home() / "pictures"


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
        print("Camera started.")
        sleep(2)

    def get_frame(self):
        PICTURE_DIR.mkdir(exist_ok=True)
        filename = str(PICTURE_DIR / "mr_vein.jpg")
        self.camera.capture_file(filename)
        return filename

    def stop(self):
        self.camera.stop()
        print("Camera stopped.")

    def close(self):
        self.camera.stop()
        self.camera.close()
        print("Camera closed.")


# TIL TEST
#if __name__ == "__main__":
 #   cam = Camera()
  #  try:
   #     cam.start()
    #    print(cam.get_frame())
    #finally:
     #   cam.close()
