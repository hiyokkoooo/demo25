#!/bin/bash

# Включение IP-форвардинга
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# Настройка NAT (MASQUERADE)
iptables -t nat -A POSTROUTING -o ens18 -j MASQUERADE
iptables-save > /etc/sysconfig/iptables
systemctl enable --now iptables

# Установка временной зоны
timedatectl set-timezone Asia/Krasnoyarsk

# Установка hostname
hostnamectl set-hostname ISP
echo "HOSTNAME=ISP.irpo" >> /etc/sysconfig/network
exec bash

# Настройка интерфейса ens19
mkdir -p /etc/net/ifaces/ens19
cp -r /etc/net/ifaces/ens18/options /etc/net/ifaces/ens19/
sed -i 's/dhcp/static/g' /etc/net/ifaces/ens19/options
sed -i 's/dhcp4/static/g' /etc/net/ifaces/ens19/options

# Настройка интерфейса ens20 (копируем настройки из ens19)
mkdir -p /etc/net/ifaces/ens20
cp -r /etc/net/ifaces/ens19/options /etc/net/ifaces/ens20/

echo "Настройка завершена!"
echo "Проверьте:"
echo "1. IP-форвардинг: cat /proc/sys/net/ipv4/ip_forward"
echo "2. NAT-правила: iptables -t nat -L"
echo "3. Интерфейсы: ls /etc/net/ifaces/"
