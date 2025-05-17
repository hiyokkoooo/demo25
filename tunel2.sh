#!/bin/bash

# Получаем текущий IP интерфейса ens18
CURRENT_IP=$(ip -4 addr show ens18 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Создаем директорию и файлы конфигурации
mkdir -p /etc/network/tun0

# Файл options (с динамическим IP)
cat > /etc/network/tun0/options <<EOF
TYPE=iptun
TUNTYPE=gre
TUNLOCAL=$CURRENT_IP
TUNREMOTE=172.16.4.1
TUNTTL=64
TUNOPTIONS='ttl 64'
HOST=ens18
EOF

# Файл ipv4address
echo "10.10.10.2/30" > /etc/network/tun0/ipv4address

# Загружаем модуль GRE и перезапускаем сеть
modprobe gre
systemctl restart network

echo "Туннель настроен. Локальный IP (ens18): $CURRENT_IP"
