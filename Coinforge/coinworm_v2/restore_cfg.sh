#!/bin/bash
CFG_PATH="/coin-forge/cfg.json.bak"

# Define target values
TARGET_IP="198.18.5.179"
TARGET_URL="http://cnn.com"
HOST_NAME="CoinForge-2"

# Extract current CONTROLLER_IP
CURRENT_IP=$(grep -m1 '"CONTROLLER_IP"' "$CFG_PATH" 2>/dev/null | sed -r 's/.*"CONTROLLER_IP"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')

# If the current IP is already the expected IP, do nothing
if [[ "$CURRENT_IP" == "$TARGET_IP" ]]; then
    echo "Config already has CONTROLLER_IP = $TARGET_IP. No restore needed."
    exit 0
fi

# Otherwise, restore the file content with variables
cat > "$CFG_PATH" <<EOF
{
  "CONTROLLER_IP": "$TARGET_IP",
  "TARGET_URL": "$TARGET_URL",
  "COIN_FORGE_HOST": "$HOST_NAME",
  "INITIATE_ATTACK": true
}
EOF

echo "Config restored to default values."
