#!/bin/bash

# Установка FRR 
apt-get update && apt-get install -y frr

# Включение OSPF в /etc/frr/daemons (исправлено: оspfd=no -> ospfd=no)
sed -i 's/ospfd=no/ospfd=yes/' /etc/frr/daemons

# Перезагрузка демона и запуск FRR (исправлено: frn -> frr)
systemctl daemon-reload
systemctl enable --now frr

# Настройка OSPF через vtysh (автоматический ввод команд) МЕНЯЙТЕ НА СВОИ АДРЕСА
vtysh << 'EOF'
conf
router ospf
network 10.2.2.0/27 area 0
network 10.10.10.0/30 area 0
exit
int tun0
ip ospf authentication message-digest
ip ospf message-digest-key 1 md5 P@ssw0rd
do wr
exit
EOF

echo "Настройка OSPF завершена!"
