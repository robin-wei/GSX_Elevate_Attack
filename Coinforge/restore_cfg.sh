#!/bin/bash

LOCKFILE="/tmp/cfg_restore.lock"
CFG_PATH="/coin-forge/cfg.json"
EXPECTED_IP="198.18.5.179"
EXPECTED_URL="http://cnn.com"

log() {
    echo "$(date +'%F %T') - $1"
}

# Check if lockfile exists — if yes, exit
if [[ -e "$LOCKFILE" ]]; then
    log "Lock file exists, another instance is running. Exiting."
    exit 1
fi

# Create lock file
touch "$LOCKFILE"

# Overwrite config file with expected values (no check)
cat > "$CFG_PATH" <<EOF
{
    "CONTROLLER_IP": "$EXPECTED_IP",
    "TARGET_URL": "$EXPECTED_URL"
}
EOF

log "Configuration restored to original state."

# Remove lock file
rm -f "$LOCKFILE"
