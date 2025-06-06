#!/bin/bash

# Создание VLAN 100
mkdir -p /etc/net/ifaces/ens19.100/
cat > /etc/net/ifaces/ens19.100/options <<EOF
TYPE=vlan
HOST=ens19
VID=100
BOOTPROTO=static
EOF

# Создание VLAN 200
mkdir -p /etc/net/ifaces/ens19.200/
cat > /etc/net/ifaces/ens19.200/options <<EOF
TYPE=vlan
HOST=ens19
VID=200
BOOTPROTO=static
EOF

# Создание VLAN999
mkdir -p /etc/net/ifaces/ens19.999/
cat > /etc/net/ifaces/ens19.999/options <<EOF
TYPE=vlan
HOST=ens19
VID=999
BOOTPROTO=static
EOF
echo "10.1.1.86/29" > /etc/net/ifaces/ens19.999/ipv4address
echo "10.1.1.62/26" > /etc/net/ifaces/ens19.100/ipv4address
echo "10.1.1.78/28" > /etc/net/ifaces/ens19.200/ipv4address

# Перезапуск сети
systemctl restart network

# Установка и настройка dnsmasq
apt-get update && apt-get install -y dnsmasq
cat > /etc/dnsmasq.conf <<EOF
no-resolv
domain=au-team.irpo
dhcp-range=10.1.1.65,10.1.1.77,999h
dhcp-option=3,10.1.1.78
dhcp-option=6,10.1.1.1
dhcp-option=15,au-team.irpo
interface=ens19.200
EOF

# Включение и запуск dnsmasq
systemctl enable --now dnsmasq
systemctl restart dnsmasq

echo "Настройка завершена"
