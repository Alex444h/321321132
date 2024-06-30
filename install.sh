#!/bin/bash

# Обновление системы
sudo apt update
sudo apt upgrade -y

# Установка WireGuard
sudo apt install wireguard -y

# Создание конфигурации для сервера
sudo mkdir -p /etc/wireguard
wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey

PRIVATE_KEY=$(sudo cat /etc/wireguard/privatekey)
PUBLIC_KEY=$(sudo cat /etc/wireguard/publickey)

echo "[Interface]
PrivateKey = $PRIVATE_KEY
Address = 10.0.0.1/24
ListenPort = 51820

[Peer]
PublicKey = <client_public_key>
AllowedIPs = 10.0.0.2/32
" | sudo tee /etc/wireguard/wg0.conf

# Включение пересылки IP
sudo sysctl -w net.ipv4.ip_forward=1

# Настройка правил iptables
sudo iptables -A FORWARD -i wg0 -j ACCEPT
sudo iptables -A FORWARD -o wg0 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Сохранение конфигурации iptables
sudo apt install iptables-persistent -y
sudo netfilter-persistent save
