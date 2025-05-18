#!/bin/bash

# Включение IP-форвардинга
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# Настройка NAT
iptables -t nat -A POSTROUTING -o ens18 -j MASQUERADE
iptables-save > /etc/sysconfig/iptables
systemctl enable --now iptables

# Настройка времени и хоста
timedatectl set-timezone Asia/Krasnoyarsk
hostnamectl set-hostname ISP
exec bash

# Настройка hostname в файле
echo "HOSTNAME=ISP.irpo" > /etc/sysconfig/network

# Копирование конфигов интерфейсов
mkdir -p /etc/net/ifaces/ens19
cp -r /etc/net/ifaces/ens18/options /etc/net/ifaces/ens19/
sed -i 's/dhcp/static/' /etc/net/ifaces/ens19/options
sed -i 's/dhcp4/static/' /etc/net/ifaces/ens19/options

mkdir -p /etc/net/ifaces/ens20
cp -r /etc/net/ifaces/ens19/options /etc/net/ifaces/ens20/

echo "Базовая настройка ISP завершена:"
echo "- IP-форвардинг включен"
echo "- NAT настроен (MASQUERADE)"
echo "- Временная зона: Asia/Krasnoyarsk"
echo "- Имя хоста: ISP.irpo"
echo "- Интерфейсы ens19 и ens20 настроены"
