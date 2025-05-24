#!/bin/bash

# Функция для выполнения команд на удаленном сервере через SSH
remote_exec() {
  sshpass -p "$3" ssh -tt -o StrictHostKeyChecking=no -p 2024 "$2@$1" "$4"
}

# Настройка HQ-SRV (10.1.1.1)
echo "Настраиваем HQ-SRV (10.1.1.1)..."
remote_exec "10.1.1.1" "sshuser" "P@ssw0rd" "
echo '10.1.1.62 hq-rtr.au-team.irpo' | sudo tee -a /etc/hosts
wget https://raw.githubusercontent.com/hiyokkoooo/demo25/refs/heads/main/dnsmasq.conf -O /tmp/dnsmasq.conf
sudo apt-get install -y dnsmasq
sudo systemctl enable --now dnsmasq
sudo rm -f /etc/dnsmasq.conf
sudo mv /tmp/dnsmasq.conf /etc/
sudo systemctl restart dnsmasq
echo -e 'nameserver 127.0.0.1\nsearch au-team.irpo' | sudo tee /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
"

# Настройка BR-SRV (10.2.2.1)
echo "Настраиваем BR-SRV (10.2.2.1)..."
remote_exec "10.2.2.1" "sshuser" "P@ssw0rd" "
echo -e 'nameserver 10.1.1.1\nnameserver 127.0.0.1\nsearch au-team.irpo' | sudo tee /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
"

# Настройка маршрутизаторов
routers=("172.16.4.1" "172.16.5.1")
for router in "${routers[@]}"; do
  echo "Настраиваем $router..."
  remote_exec "$router" "net_admin" "P@ssw0rd" "
echo -e 'nameserver 10.1.1.1\nsearch au-team.irpo' | sudo tee /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
"
done

echo "Все настройки выполнены успешно!"
