import asyncio
import sys
import pychromecast
from androidtvremote2 import AndroidTVRemote, AndroidTVRemoteConfig

IP = "REDACTED_INTERNAL_IP"

async def remote_loop():
    print(f"--- [SPECTER FULL REMOTE] Target: {IP} ---")
    
    # Corrected constructor for newer androidtvremote2 versions
    remote = AndroidTVRemote(host=IP, name="SpecterConsole")
    
    try:
        # This will trigger the PIN code on the TV if not already paired
        await remote.connect()
        print("[OK] Remote Protocol Connected.")
        
        # Initialize Chromecast for status monitoring
        cast = pychromecast.Chromecast(IP)
        cast.wait()

        while True:
            # Force Volume 100%
            if cast.status.volume_level < 1.0:
                cast.set_volume(1.0)
            
            app = cast.status.display_name or "Home"
            m = cast.media_controller.status
            title = m.title if m.title else "Idle/Menu"
            
            # Interactive Prompt
            print(f"\n[LIVE] App: {app} | Watching: {title[:40]}")
            cmd = input("CMD (H:Home, B:Back, U/D/L/R:Arrows, E:Enter, T:Type, Q:Quit): ").upper()
            
            if cmd == 'H': await remote.send_key("HOME", "SHORT")
            elif cmd == 'B': await remote.send_key("BACK", "SHORT")
            elif cmd == 'U': await remote.send_key("DPAD_UP", "SHORT")
            elif cmd == 'D': await remote.send_key("DPAD_DOWN", "SHORT")
            elif cmd == 'L': await remote.send_key("DPAD_LEFT", "SHORT")
            elif cmd == 'R': await remote.send_key("DPAD_RIGHT", "SHORT")
            elif cmd == 'E': await remote.send_key("DPAD_CENTER", "SHORT")
            elif cmd == 'T':
                text = input("Enter text to type: ")
                await remote.send_text(text)
            elif cmd == 'Q': 
                break
                
    except Exception as e:
        print(f"\n[!] Error: {e}")

if __name__ == "__main__":
    try:
        asyncio.run(remote_loop())
    except KeyboardInterrupt:
        pass