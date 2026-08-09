import pychromecast
from pychromecast.discovery import discover_chromecasts
from pychromecast.socket_client import CAST_TYPE_CHROMECAST
import time

# Target IP
TV_IP = "REDACTED_INTERNAL_IP"

def get_tv_status():
    try:
        # Step 1: Discover the cast object specifically for this IP
        # We use a 2-second timeout to find it
        chromecasts, browser = pychromecast.get_listed_chromecasts(ips=[TV_IP])
        
        if not chromecasts:
            print(f"[-] Could not find the TV at {TV_IP}. Is it on?")
            return

        cast = chromecasts[0]
        # Step 2: Start the connection
        cast.wait()
        
        print(f"[*] Connected to: {cast.name}")
        print(f"[*] Status: {cast.status.status_text if cast.status.status_text else 'Idle'}")

        while True:
            # Step 3: Check for media
            mc = cast.media_controller
            # Force a refresh of the media status
            mc.block_until_active(timeout=0.5)
            
            if mc.status.player_state == "PLAYING":
                print("\n" + "!"*40)
                print(f"WATCHING: {mc.status.title}")
                print(f"APP:      {cast.app_display_name}")
                if mc.status.series_title:
                    print(f"SERIES:   {mc.status.series_title}")
                if mc.status.content_id:
                    print(f"VIDEO ID: {mc.status.content_id}")
                print("!"*40)
            else:
                print(f"[*] TV is {mc.status.player_state if mc.status.player_state else 'IDLE'}...", end="\r")
            
            time.sleep(2)

    except KeyboardInterrupt:
        print("\n[*] Stopping...")
    except Exception as e:
        print(f"\n[-] Error: {e}")
    finally:
        if 'browser' in locals():
            browser.stop_discovery()

if __name__ == "__main__":
    get_tv_status()