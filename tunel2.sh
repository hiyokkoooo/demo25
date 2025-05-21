#!/bin/bash

# Создаем директорию и файлы конфигурации
mkdir -p /etc/net/ifaces/tun0

# Файл options
cat > /etc/net/ifaces/tun0/options <<EOF
TYPE=iptun
TUNTYPE=gre
TUNLOCAL=172.16.5.1
TUNREMOTE=172.16.4.1
TUNTTL=64
TUNOPTIONS='ttl 64'
HOST=ens18
EOF

# Файл ipv4address
echo "10.10.10.2/30" > /etc/net/ifaces/tun0/ipv4address

# Загружаем модуль GRE и перезапускаем сеть
modprobe gre
systemctl restart network

echo "Туннель настроен"
