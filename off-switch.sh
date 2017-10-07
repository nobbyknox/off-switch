#!/bin/bash

# Helpful resources:
# http://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO-6.html#ss6.2

HOST=192.168.10.221
SLEEP=5         # time (in seconds) between each heartbeat
LAST_SEEN=$(date +%s)
NOW=$(date +%s)
DIFF_TIME=0
MAX_UNSEEN=60   # maximum number of elapsed seconds since last seeing
                # the host before shutdown action(s) will commence

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
    if [ "$1" = "INFO" ]; then
        TYPE="${GREEN}$1${NC}"
    else
        if [ "$1" = "WARN" ]; then
            TYPE="${ORANGE}$1${NC}"
        else
            TYPE="${RED}$1${NC}"
        fi
    fi

    echo -e $(date '+%Y-%m-%d %H:%M:%S') [$TYPE] $2
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

function pingaling {
    ping -c 4 -oq $HOST &> /dev/null

    if [ "$?" = "0" ]; then
        LAST_SEEN=$(date +%s)
    fi
}

while true; do
    pingaling
    NOW=$(date +%s)
    DIFF_TIME=$((NOW - LAST_SEEN))

    if [ $DIFF_TIME -le 10 ]; then
        log_info "Host last seen $DIFF_TIME seconds ago"
    else
        if [ $DIFF_TIME -le 30 ]; then
            log_warn "Host last seen $DIFF_TIME seconds ago. Gearing up to swith stuff off..."
        else
            log_error "Host last seen $DIFF_TIME seconds ago. Shutting down NOW!"
            exit 0
        fi
    fi

    sleep $SLEEP
done
