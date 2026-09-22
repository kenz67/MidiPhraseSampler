#!/bin/bash

# Default values
TARGET_NAME="Arduino"
CYAN='\x1b[36m'
GREEN='\x1b[32m'
MAGENTA='\x1b[35m'  
RED='\x1b[31m'       
YELLOW='\x1b[1;33m'
RESET='\x1b[0m'

# --- NEW: Ctrl+C Trap Handler ---
cleanup_and_exit() {
    echo -e "\n${RED}--> Monitoring aborted by user. Exiting cleanly...${RESET}"
    # Ensure any lingering background aseqdump tasks are killed
    pkill -f "aseqdump -p" 2>/dev/null
    exit 0
}
# Catch SIGINT (Ctrl+C) and route it to our function
trap cleanup_and_exit SIGINT

# Help function
show_help() {
    echo -e "Usage: $0 [OPTIONS]"
    echo -e ""
    echo -e "An auto-reconnecting MIDI live monitor for the Linux command line."
    echo -e ""
    echo -e "Options:"
    echo -e "  -h, --help               Show this help message and exit"
    echo -e "  -t, --target <name>      Set the target MIDI device keyword (Default: \"Arduino\")"
    echo -e "  --nocolor                Disable ANSI color highlighting output"
    echo -e ""
    exit 0
}

# Parse command line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            ;;
        --nocolor)
            CYAN=""
            GREEN=""
            MAGENTA=""
            RED=""
            YELLOW=""
            RESET=""
            shift 
            ;;
        -t|--target)
            if [[ -n "$2" && "$2" != -* ]]; then
                TARGET_NAME="$2"
                shift 2 
            else
                echo -e "Error: Argument $1 requires a non-empty value." >&2
                exit 1
            fi
            ;;
        *)
            echo -e "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

while true; do
    PORT=$(aseqdump -l | grep -i "$TARGET_NAME" | awk 'NR==1 {print $1}')

    if [ -n "$PORT" ] && [ "$PORT" != "Port" ]; then
        echo -e "${YELLOW}--> Monitoring MIDI on target '$TARGET_NAME' (port $PORT)...${RESET}"
        
        (
            aseqdump -p "$PORT" 2>&1 | awk -Winteractive \
                -v c="$CYAN" -v g="$GREEN" -v m="$MAGENTA" -v y="$YELLOW" -v x="$RESET" '
                /Port unsubscribed/ { 
                    print y $0 x; 
                    fflush(); 
                    system("pkill -f \"aseqdump -p\""); 
                    exit 
                }
                /Control change/    { print c $0 x; next }
                /Note on/           { print g $0 x; next }
                /Note off/          { print m $0 x; next }
                { print }
            '
        ) 2>/dev/null
            
        echo -e "${RED}--> Target disconnected! Reconnecting...${RESET}"
        sleep 1.5
    else
        sleep 0.5
    fi
done