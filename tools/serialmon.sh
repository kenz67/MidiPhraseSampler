#!/bin/bash

BAUD_RATE="115200"
YELLOW='\x1b[1;33m'
RED='\x1b[31m'
RESET='\x1b[0m'

cleanup_and_exit() {
    echo -e "\n${RED}--> Serial monitoring aborted by user. Exiting...${RESET}"
    exit 0
}
trap cleanup_and_exit SIGINT

show_help() {
    echo -e "Usage: $0 [OPTIONS]"
    echo -e ""
    echo -e "  -n, --nocolor  Disable colored output."
    echo -e "An auto-reconnecting Serial Log Monitor that allows automatic Arduino uploads."
    exit 0
}

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_help ;;
        -n|--nocolor)
            YELLOW=''
            RED=''
            RESET=''
            shift
            ;;
        -b|--baud) BAUD_RATE="$2"; shift 2 ;;
        *) echo -e "Unknown option: $1"; exit 1 ;;
    esac
done

# Checks if you are either compiling OR uploading right now
is_arduino_busy() {
    # cc1plus/compiler = Arduino IDE is compiling. avrdude/arduino-cli/bossac = uploading.
    pgrep -f "avrdude|arduino-cli|bossac|teensy_post_compile|cc1plus|compiler" >/dev/null
}

while true; do
    # 1. Preemptive backing off: If you hit 'Upload' (even during compile phase), yield the port immediately
    if is_arduino_busy; then
        echo -e "${RED}--> Arduino IDE busy (Compiling/Uploading)! Releasing port...${RESET}"
        while is_arduino_busy; do
            sleep 1.0
        done
        echo -e "${YELLOW}--> IDE finished. Waiting 3 seconds for board to settle...${RESET}"
        sleep 3.0
    fi

    PORT_PATH=$(ls /dev/ttyACM* /dev/ttyUSB* 2>/dev/null | head -n 1)

    if [ -n "$PORT_PATH" ]; then
        echo -e "${YELLOW}--> Found serial device at $PORT_PATH. Speed: ${BAUD_RATE}...${RESET}"
        stty -F "$PORT_PATH" "$BAUD_RATE" raw -clocal -echo 2>/dev/null
        echo -e "${YELLOW}--> Streaming Log Output...${RESET}"
        
        # Read loop: Read in chunks, checking if the IDE becomes busy
        while [ -e "$PORT_PATH" ] && ! is_arduino_busy; do
            timeout 0.5 cat "$PORT_PATH" 2>/dev/null
        done
        
        # 2. Add a heavy back-off pause whenever we drop the connection 
        # This leaves a wide, open window for the IDE to claim the port
        echo -e "${RED}--> Connection dropped. Backing off for 2 seconds...${RESET}"
        sleep 2.0
    else
        sleep 1.0
    fi
done
