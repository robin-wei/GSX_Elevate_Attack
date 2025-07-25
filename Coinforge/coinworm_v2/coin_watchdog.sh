#!/bin/bash
UPDATE_SCRIPT="/coinworm/update_cfg.sh"
RESTORE_SCRIPT="/coinworm/restore_cfg.sh"
CHECK_IP="198.18.14.2"
SLEEP_INTERVAL=10

while true; do
    # Run update first
    bash "$UPDATE_SCRIPT"

    # Ping controller
    if ! ping -c 3 -W 2 "$CHECK_IP" > /dev/null 2>&1; then
        echo "[Watchdog] Controller $CHECK_IP unreachable. Restoring config."
        bash "$RESTORE_SCRIPT"
        exit 0  # Quit after restore
    fi

    echo "[Watchdog] Controller reachable. Exiting."
    exit 0  # Quit if reachable

    sleep "$SLEEP_INTERVAL"
done
