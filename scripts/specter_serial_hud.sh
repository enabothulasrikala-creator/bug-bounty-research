#!/bin/bash

# Configuration
PORT="/dev/ttyUSB0"
BAUD="115200"
LOG_FILE="specter_live.log"

# Colors for the HUD
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Initialize Serial Port
stty -F $PORT $BAUD raw -echo -echoe -echok

clear

draw_header() {
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${BOLD}${WHITE}  S P E C T E R H U B   |   T A C T I C A L   D A S H B O A R D  ${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo -e " STATUS: ${GREEN}CONNECTED${NC} | PORT: ${YELLOW}$PORT${NC} | LOG: ${PURPLE}$LOG_FILE${NC}"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
}

show_menu() {
    echo -e "${BOLD}WIFI ATTACKS${NC}            ${BOLD}SUB-GHz / RF${NC}         ${BOLD}OTHERS${NC}"
    echo -e "1) Scan/PCAP           5) Sub-G Sniff       8) Mousejack"
    echo -e "2) Evil Twin           6) Sub-G Jammer      9) IR Sniffer"
    echo -e "3) Deauth Attack       7) LoRa Sniff        10) IR Replay"
    echo -e "4) Beacon Spam"
    echo -e "${CYAN}----------------------------------------------------------------${NC}"
    echo -e "S) STOP ALL ATTACKS    L) VIEW LIVE LOGS    Q) EXIT"
}

send_cmd() {
    echo -e "$1\n" > $PORT
    echo -e "${GREEN}[+] Command Sent: $1${NC}"
    sleep 1
}

# Background listener for Serial output
listen_serial() {
    tail -f $PORT >> $LOG_FILE &
    LISTENER_PID=$!
}

# Main Loop
listen_serial
while true; do
    clear
    draw_header
    show_menu
    echo -ne "${BOLD}${YELLOW}SPECTER@HUB:${NC} "
    read -r opt

    case $opt in
        1) send_cmd "wifi_scan" ;;
        2) send_cmd "evil_twin" ;;
        3) send_cmd "deauth" ;;
        4) send_cmd "beacon" ;;
        5) send_cmd "sub_sniff" ;;
        6) send_cmd "sub_jam" ;;
        7) send_cmd "lora_sniff" ;;
        8) send_cmd "mousejack" ;;
        9) send_cmd "ir_sniff" ;;
        10) send_cmd "ir_replay" ;;
        s|S) send_cmd "stop" ;;
        l|L) 
            echo -e "${CYAN}--- LIVE LOG ENTRY (Press Ctrl+C to Return) ---${NC}"
            tail -n 20 $LOG_FILE
            read -n 1 -s -r -p ""
            ;;
        q|Q) 
            kill $LISTENER_PID
            exit 0 
            ;;
        *) echo -e "${RED}Invalid Option${NC}" ; sleep 1 ;;
    esac
done
