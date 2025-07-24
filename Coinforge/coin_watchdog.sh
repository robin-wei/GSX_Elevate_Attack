#!/bin/bash

PING_TARGET="198.18.14.2"
RESTORE_SCRIPT="/coin-forge/restore_cfg.sh"
CHECK_INTERVAL=10  # seconds

log() {
    echo "$(date +'%F %T') - $1"
}

while true; do
    if ping -c 1 -W 2 "$PING_TARGET" > /dev/null 2>&1; then
        log "Ping to $PING_TARGET succeeded. No action needed."
    else
        log "Ping to $PING_TARGET failed. Calling restore script..."
        bash "$RESTORE_SCRIPT"
    fi
    sleep "$CHECK_INTERVAL"
done
