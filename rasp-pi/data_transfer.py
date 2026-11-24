import paramiko
from pathlib import Path


class DataTransfer:
    def __init__(self, server_ip, username, p_key, remote_dir):
        self.server_ip = server_ip
        self.username = username
        self.p_key = p_key
        self.remote_dir = remote_dir

    def send_pic(self, img_path):
        client = paramiko.SSHClient()
        client.load_system_host_keys()

        try:
            client.connect(
                hostname=self.server_ip,
                username=self.username,
                key_filename=self.p_key,
            )

            sftp = client.open_sftp()

            try:
                filename = Path(img_path).name
                remote_path = f"{self.remote_dir}/{filename}"

                # Temporary filename prevents displaying image while uploading.
                temp_path = remote_path + ".tmp"

                sftp.put(img_path, temp_path)
                sftp.posix_rename(temp_path, remote_path)

                print(f"Successfully transferred image: {filename}")

            finally:
                sftp.close()

        except (OSError, paramiko.SSHException) as error:
            print(f"Image transfer via SFTP failed: {error}")

        finally:
            client.close()


# TIL TEST
#if __name__ == "__main__":
#    data = DataTransfer(
#        server_ip="192.168.1.10",
#        username="gruppe4",
#        p_key=str(Path.home() / ".ssh" / "id_ed25519"),
#        remote_dir="/project_venavision/Project-VenaVision/flasksite/static",
#    )
#    data.send_pic(str(Path.home() / "pictures" / "mr_vein.jpg"))
