#!/bin/bash

# ==============================================================================
# S P E C T E R H U B   |   T A C T I C A L   C O N T R O L   S C R I P T
# ==============================================================================
# Optimized for Chromebook Linux (Crostini)
# Version: 2.1.0-Tactical
# ==============================================================================

# --- Configuration ---
BAUD="115200"
LOG_FILE="specter_live.log"
SESSION_LOG="specter_session_$(date +%Y%m%d_%H%M%S).log"

# --- Colors & Styling ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color
BOLD='\033[1m'
BLINK='\033[5m'

# --- ASCII Art ---
BANNER="
${CYAN}   _____                 _            _    _       _     
  / ____|               | |          | |  | |     | |    
 | (___  _ __   ___  ___| |_ ___ _ __| |__| |_   _| |__  
  \___ \| '_ \ / _ \/ __| __/ _ \ '__|  __  | | | | '_ \ 
  ____) | |_) |  __/ (__| ||  __/ |  | |  | | |_| | |_) |
 |_____/| .__/ \___|\___|\__\___|_|  |_|  |_|\__,_|_.__/ 
        | |                                              
        |_| ${WHITE}v2.1.0-TACTICAL | Chromebook Edition${NC}
"

# --- Functions ---

# Detect Serial Ports
detect_ports() {
    PORTS=$(ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null)
    if [ -z "$PORTS" ]; then
        echo -e "${RED}${BOLD}[!] ERROR: No ESP32/SpecterHub detected.${NC}"
        echo -e "${YELLOW}[*] Hint: On Chromebook, go to Settings > Advanced > Developers > Linux > Manage USB devices.${NC}"
        exit 1
    fi
    
    # If only one port, use it
    if [ $(echo "$PORTS" | wc -l) -eq 1 ]; then
        PORT=$PORTS
    else
        echo -e "${CYAN}[*] Multiple ports detected. Select one:${NC}"
        select opt in $PORTS; do
            if [ -n "$opt" ]; then
                PORT=$opt
                break
            else
                echo -e "${RED}Invalid selection.${NC}"
            fi
        done
    fi
}

# Check Permissions
check_permissions() {
    if [ ! -r "$PORT" ] || [ ! -w "$PORT" ]; then
        echo -e "${YELLOW}[!] Permission denied on $PORT. Attempting to fix...${NC}"
        sudo chmod 666 "$PORT"
        if [ $? -ne 0 ]; then
            echo -e "${RED}${BOLD}[!] ERROR: Failed to set permissions. Run 'sudo chmod 666 $PORT' manually.${NC}"
            exit 1
        fi
    fi
}

# Initialize Serial
init_serial() {
    stty -F "$PORT" "$BAUD" raw -echo -echoe -echok clocal cread
    if [ $? -ne 0 ]; then
        echo -e "${RED}${BOLD}[!] ERROR: Failed to configure serial port $PORT.${NC}"
        exit 1
    fi
    touch "$LOG_FILE"
    echo -e "${GRAY}[SYSTEM] Session started at $(date)${NC}" >> "$LOG_FILE"
}

# Background Listener with Timestamps
listen_serial() {
    (
        while read -r line; do
            # Filter out empty lines or garbage
            if [ -n "$line" ]; then
                TS=$(date +"%H:%M:%S")
                echo -e "${GRAY}[$TS]${NC} $line" | tee -a "$LOG_FILE" "$SESSION_LOG"
            fi
        done < "$PORT"
    ) &
    LISTENER_PID=$!
}

# Send Command to ESP32
send_cmd() {
    echo -e "$1\n" > "$PORT"
    echo -e "${GREEN}${BOLD}[+] COMMAND SENT: $1${NC}"
    sleep 0.5
}

# UI Components
draw_header() {
    echo -e "$BANNER"
    echo -e "${CYAN}================================================================${NC}"
    echo -e " STATUS: ${GREEN}CONNECTED${NC} | PORT: ${YELLOW}$PORT${NC} | TIME: ${WHITE}$(date +%H:%M:%S)${NC}"
    echo -e "${CYAN}================================================================${NC}"
}

show_menu() {
    echo -e "${BOLD}${WHITE}--- WIFI AUDITING ---${NC}        ${BOLD}${WHITE}--- RF / SUB-GHz ---${NC}"
    echo -e " 1) ${CYAN}wifi_scan${NC}               5) ${CYAN}sub_sniff${NC}"
    echo -e " 2) ${CYAN}wifi_evil_twin${NC}          6) ${CYAN}sub_jam${NC}"
    echo -e " 3) ${CYAN}wifi_deauth${NC}             7) ${CYAN}sub_rolljam${NC}"
    echo -e " 4) ${CYAN}wifi_beacon${NC}             8) ${CYAN}sub_replay${NC}"
    echo -e ""
    echo -e "${BOLD}${WHITE}--- OTHERS ---${NC}               ${BOLD}${WHITE}--- SYSTEM ---${NC}"
    echo -e " 9) ${CYAN}hid_mousejack${NC}          S) ${YELLOW}STOP ALL ATTACKS${NC}"
    echo -e "10) ${CYAN}ir_sniff${NC}               T) ${YELLOW}GET SYSTEM STATUS${NC}"
    echo -e "11) ${CYAN}ir_replay${NC}              L) ${PURPLE}VIEW LIVE LOGS${NC}"
    echo -e " 0) ${WHITE}HELP / COMMANDS${NC}        Q) ${RED}EXIT DASHBOARD${NC}"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
}

# Cleanup on Exit
cleanup() {
    echo -e "\n${YELLOW}[*] Shutting down tactical dashboard...${NC}"
    kill "$LISTENER_PID" 2>/dev/null
    echo -e "${GREEN}[+] Session log saved to: $SESSION_LOG${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM

# --- Execution ---

clear
detect_ports
check_permissions
init_serial
listen_serial

while true; do
    clear
    draw_header
    show_menu
    echo -ne "${BOLD}${YELLOW}SPECTER@HUB:${NC} "
    read -r opt

    case $opt in
        1) send_cmd "wifi_scan" ;;
        2) send_cmd "wifi_evil_twin" ;;
        3) send_cmd "wifi_deauth" ;;
        4) send_cmd "wifi_beacon" ;;
        5) send_cmd "sub_sniff" ;;
        6) send_cmd "sub_jam" ;;
        7) send_cmd "sub_rolljam" ;;
        8) send_cmd "sub_replay" ;;
        9) send_cmd "hid_mousejack" ;;
        10) send_cmd "ir_sniff" ;;
        11) send_cmd "ir_replay" ;;
        s|S) send_cmd "stop" ;;
        t|T) send_cmd "status" ;;
        0) send_cmd "help" ; sleep 2 ;;
        l|L) 
            echo -e "${CYAN}--- LIVE LOG ENTRY (Press Ctrl+C to Return) ---${NC}"
            # Use a temporary tail to avoid blocking the main loop
            tail -f "$LOG_FILE" &
            TAIL_PID=$!
            trap "kill $TAIL_PID; trap cleanup SIGINT SIGTERM" SIGINT
            wait $TAIL_PID 2>/dev/null
            ;;
        q|Q) 
            cleanup
            ;;
        *) 
            echo -e "${RED}[!] Invalid Option: $opt${NC}"
            sleep 1 
            ;;
    esac
done
