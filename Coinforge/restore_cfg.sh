#!/bin/bash

LOCKFILE="/tmp/cfg_restore.lock"
CFG_PATH="/coin-forge/cfg.json"
EXPECTED_IP="198.18.5.179"
EXPECTED_URL="https://cisco.com"
EXPECTED_HOST="CoinForge-2"

log() {
    echo "$(date +'%F %T') - $1"
}

# Check if lockfile exists — if yes, exit
if [[ -e "$LOCKFILE" ]]; then
    log "Lock file exists, another instance is running. Exiting."
    exit 1
fi

# Extract current IP from config (fallback to grep + sed)
CURRENT_IP=$(grep -m1 '"CONTROLLER_IP"' "$CFG_PATH" 2>/dev/null | sed -r 's/.*"CONTROLLER_IP"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')

if [[ "$CURRENT_IP" == "$EXPECTED_IP" ]]; then
    log "Config already has expected IP ($EXPECTED_IP). No restore needed."
    exit 0
fi

# Create lock file
touch "$LOCKFILE"

# Overwrite config file with expected values
cat > "$CFG_PATH" <<EOF
{
  "CONTROLLER_IP": "$EXPECTED_IP",
  "TARGET_URL": "$EXPECTED_URL",
  "COIN_FORGE_HOST": "$EXPECTED_HOST"
}
EOF

log "Configuration restored to original state."

# Remove lock file
rm -f "$LOCKFILE"
