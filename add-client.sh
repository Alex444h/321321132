#!/bin/bash

CLIENT_NAME=$1

if [ -z "$CLIENT_NAME" ]; then
    echo "Usage: ./add-client.sh <client-name>"
    exit 1
fi

CLIENT_PRIVATE_KEY=$(wg genkey)
CLIENT_PUBLIC_KEY=$(echo $CLIENT_PRIVATE_KEY | wg pubkey)

echo "[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = $(sudo cat /etc/wireguard/publickey)
Endpoint = <server_ip>:51820
AllowedIPs = 0.0.0.0/0
" > $CLIENT_NAME.conf

echo "
[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = 10.0.0.2/32
" | sudo tee -a /etc/wireguard/wg0.conf

sudo systemctl restart wg-quick@wg0
