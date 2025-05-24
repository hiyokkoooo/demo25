#!/bin/bash

# Функция для выполнения команд на удаленном сервере через SSH
remote_exec() {
  sshpass -p "$3" ssh -o StrictHostKeyChecking=no -p 2024 "$2@$1" "$4"
}

# Настройка HQ-SRV (10.1.1.1)
echo "Настраиваем HQ-SRV (10.1.1.1)..."
sshpass -p 'P@ssw0rd' ssh -p 2024 sshuser@10.1.1.1 << 'EOF'
echo "10.1.1.62 hq-rtr.au-team.irpo" | sudo tee -a /etc/hosts
wget https://raw.githubusercontent.com/hiyokkoooo/demo25/refs/heads/main/dnsmasq.conf
sudo apt-get install -y dnsmasq
sudo systemctl enable --now dnsmasq
sudo rm -rf /etc/dnsmasq.conf
sudo cp dnsmasq.conf /etc/
sudo systemctl restart dnsmasq

sudo bash -c 'echo -e "nameserver 127.0.0.1\nsearch au-team.irpo" > /etc/resolv.conf'
sudo chattr +i /etc/resolv.conf
EOF

# Настройка BR-SRV (10.2.2.1)
echo "Настраиваем BR-SRV (10.2.2.1)..."
sshpass -p 'P@ssw0rd' ssh -p 2024 sshuser@10.2.2.1 << 'EOF'
sudo bash -c 'echo -e "nameserver 10.1.1.1\nnameserver 127.0.0.1\nsearch au-team.irpo" > /etc/resolv.conf'
sudo chattr +i /etc/resolv.conf
EOF

# Настройка HQ-RTR (172.16.4.1) и BR-RTR (172.16.5.1)
for router in 172.16.4.1 172.16.5.1; do
  echo "Настраиваем $router..."
  sshpass -p 'P@ssw0rd' ssh -p 2024 net_admin@$router << 'EOF'
sudo bash -c 'echo -e "nameserver 10.1.1.1\nsearch au-team.irpo" > /etc/resolv.conf'
sudo chattr +i /etc/resolv.conf
EOF
done

echo "Все настройки выполнены успешно!"
