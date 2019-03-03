#!/bin/bash

# Helpful resources:
# http://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO-6.html#ss6.2

HOST=""
TIMEOUT=60
SCRIPT_DIR=""
STARTUP_DELAY=120 # two minutes
SLEEP=5           # time (in seconds) between each heartbeat
LAST_SEEN=""
NOW=$(date +%s)
DIFF_TIME=0
INITIALIZED=0

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

function log {
    TYPE=""

    if [[ "$1" = "INFO" ]]; then
        TYPE="${GREEN}$1${NC}"
    else
        if [[ "$1" = "WARN" ]]; then
            TYPE="${ORANGE}$1${NC}"
        else
            TYPE="${RED}$1${NC}"
        fi
    fi

    echo -e $(date '+%Y-%m-%d %H:%M:%S') \[${TYPE}\] $2
}

function log_info {
    log "INFO" "$1"
}

function log_warn {
    log "WARN" "$1"
}

function log_error {
    log "ERROR" "$1"
}

function log_void {
    echo "$1" > /dev/null
}

function usage {
    echo "Usage: $0 -h host -t 60 -s scripts_directory"
}

while getopts h:t:s: option
do
    case "${option}" in
    h) HOST=${OPTARG};;
    t) TIMEOUT=${OPTARG};;
    s) SCRIPT_DIR=${OPTARG};;
    [?]) usage
         exit 1;;
    esac
done

log_info "off-switch ready"
log_info "  -h: $HOST"
log_info "  -t: $TIMEOUT"
log_info "  -s: $SCRIPT_DIR"

if [[ "$HOST" = "" ]]; then
    echo Host not specified
    usage
    exit 1
fi

if [[ "$TIMEOUT" = "0" ]]; then
    echo Timeout must be greater than zero
    usage
    exit 1
fi

if [[ "$SCRIPT_DIR" = "" ]]; then
    echo Script directory not specified
    usage
    exit 1
fi

function pingaling {
    ping -c 1 ${HOST} &> /dev/null

    if [[ "$?" = "0" ]]; then
        LAST_SEEN=$(date +%s)
    fi
}

function run-scripts {
    log_info "Running scripts..."

    for file in ${SCRIPT_DIR}/*; do
        [[ -f "$file" ]] && [[ -x "$file" ]] && "$file"
    done
}

# Raspberry Pi time at start-up is somewhat broken. Allow
# clock to be set before we kick off.
log_info "Entering start-up sleep delay of $STARTUP_DELAY seconds"
sleep ${STARTUP_DELAY}

log_info "Start-up delay complete"
LAST_SEEN=$(date +%s)
INITIALIZED=1

while true; do

    if [[ "$INITIALIZED" = "1" ]]; then
        pingaling

        NOW=$(date +%s)
        DIFF_TIME=$((NOW - LAST_SEEN))

        if [[ ${DIFF_TIME} -le 15 ]]; then
            log_void "Host last seen $DIFF_TIME seconds ago"
        else
            if [[ ${DIFF_TIME} -lt ${TIMEOUT} ]]; then
                log_warn "Host last seen $DIFF_TIME seconds ago. Gearing up to swith stuff off..."
            else
                log_error "Host last seen $DIFF_TIME seconds ago. Shutting down NOW!"
                run-scripts
                log_info "Exiting..."
                exit 0
            fi
        fi
    fi

    sleep ${SLEEP}
done
