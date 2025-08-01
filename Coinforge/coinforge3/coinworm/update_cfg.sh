#!/bin/bash

CFG_PATH="/coin-forge/cfg.json"
TARGET_IP="198.18.14.2"
TARGET_URL="http://198.18.14.2:8088/coinworm.html"
HOST_NAME="CoinForge-3"

# 1. Check if CONTROLLER_IP is already TARGET_IP
CURRENT_IP=$(grep -m1 '"CONTROLLER_IP"' "$CFG_PATH" | sed -r 's/.*"CONTROLLER_IP"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')
if [[ "$CURRENT_IP" == "$TARGET_IP" ]]; then
    echo "CONTROLLER_IP already set to $TARGET_IP. Exiting."
    exit 0
fi

# 2. Check INITIATE_ATTACK flag
if ! grep -q '"INITIATE_ATTACK"[[:space:]]*:[[:space:]]*true' "$CFG_PATH"; then
    echo "INITIATE_ATTACK is not true. Nothing to do."
    exit 0
fi

# 3. Replace the entire file content
cat > "$CFG_PATH" <<EOF
{
  "CONTROLLER_IP": "$TARGET_IP",
  "TARGET_URL": "$TARGET_URL",
  "COIN_FORGE_HOST": "$HOST_NAME",
  "INITIATE_ATTACK": true
}
EOF

echo "cfg.json updated successfully."
