#!/bin/bash

# 1. Настройка IP-форвардинга
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

# 2. Настройка NAT
iptables -t nat -A POSTROUTING -o ens18 -j MASQUERADE
iptables-save >> /etc/sysconfig/iptables
systemctl enable --now iptables

# 3. Настройка времени и хоста
timedatectl set-timezone Asia/Krasnoyarsk
hostnamectl set-hostname ISP
exec bash

# 4. Настройка hostname
echo "HOSTNAME=ISP.irpo" > /etc/sysconfig/network

# 5. Копирование конфигов интерфейсов
mkdir /etc/net/ifaces/ens19
cp -r /etc/net/ifaces/ens18/options /etc/net/ifaces/ens19/
sed -i 's/dhcp/static/' /etc/net/ifaces/ens19/options
sed -i 's/dhcp4/static/' /etc/net/ifaces/ens19/options

mkdir /etc/net/ifaces/ens20
cp -r /etc/net/ifaces/ens19/options /etc/net/ifaces/ens20/
