#!/bin/bash

OUTPUT_FILE="hidden_wallet.txt"
TOTAL_TOKENS=1000

> "$OUTPUT_FILE"
echo "Generating wallet entries..."

generate_token() {
    # Simulate a Bitcoin-like address (starts with 1 or 3, 34 chars total)
    prefix=$((RANDOM % 2))
    if [[ "$prefix" -eq 0 ]]; then
        addr_prefix="1"
    else
        addr_prefix="3"
    fi
    address="$addr_prefix$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 33)"

    # Simulate a private key (WIF format: starts with 5, K, or L, 51 chars total)
    wif_prefixes=(5 K L)
    wif_prefix=${wif_prefixes[$RANDOM % ${#wif_prefixes[@]}]}
    priv_key="$wif_prefix$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 50)"

    # Optional: add a small balance field to increase realism
    balance=$(awk -v min=0.001 -v max=0.05 'BEGIN{srand(); printf "%.8f", min+rand()*(max-min)}')

    printf "Address: %s\nPrivateKey: %s\nBalance: %s BTC\n---\n" "$address" "$priv_key" "$balance" >> "$OUTPUT_FILE"
}

for ((i = 1; i <= TOTAL_TOKENS; i++)); do
    generate_token
done

echo "Done. Generated $TOTAL_TOKENS wallet entries to '$OUTPUT_FILE'."
