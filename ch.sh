#!/bin/bash

# Функция для выполнения команд через SSH
remote_exec() {
  sshpass -p "$3" ssh -tt -o StrictHostKeyChecking=no -p 2024 "$2@$1" "$4"
}

# 1. Настройка Chrony на HQ-RTR (172.16.4.1)
echo "Настраиваем Chrony на HQ-RTR..."
remote_exec "172.16.4.1" "net_admin" "P@ssw0rd" "
sudo sed -i '/^pool/ d' /etc/chrony.conf
echo -e 'local stratum 5\nallow 0/0' | sudo tee -a /etc/chrony.conf
sudo systemctl restart chronyd
"

# 2. Настройка Chrony на остальных серверах
servers=("10.1.1.1" "10.2.2.1" "172.16.5.1")
for server in "${servers[@]}"; do
  echo "Настраиваем Chrony на $server..."
  user="sshuser"
  if [[ "$server" == "172.16.5.1" ]]; then
    user="net_admin"
  fi
  
  remote_exec "$server" "$user" "P@ssw0rd" "
  sudo sed -i 's/^pool.*/pool hq-rtr iburst/' /etc/chrony.conf
  sudo systemctl restart chronyd
  "
done

# 3. Настройка Ansible на BR-SRV (10.2.2.1)
echo "Настраиваем Ansible на BR-SRV..."
remote_exec "10.2.2.1" "sshuser" "P@ssw0rd" "
sudo apt-get update && sudo apt-get install -y ansible sshpass wget
cd /etc/ansible
sudo wget https://raw.githubusercontent.com/hiyokkoooo/demo25/refs/heads/main/inventory.yml
sudo sed -i 's/адрес_клиента/10.1.1.1/' inventory.yml  # Замените на нужный IP
echo -e '[defaults]\ninterpreter_python = /usr/bin/python3\ninventory = /etc/ansible/inventory.yml\nhost_key_checking = false' | sudo tee ansible.cfg
ansible -m ping all
"

# 4. Установка Docker и MediaWiki на BR-SRV
echo "Разворачиваем MediaWiki на BR-SRV..."
remote_exec "10.2.2.1" "sshuser" "P@ssw0rd" "
sudo apt-get install -y docker-engine docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker user
wget https://raw.githubusercontent.com/hiyokkoooo/demo25/refs/heads/main/wiki.yml
sudo mv wiki.yml /home/user
cd /home/user
sudo docker compose -f wiki.yml up -d
"

echo "Все настройки выполнены! Проверьте:"
echo "1. Chrony: chronyc sources"
echo "2. Ansible: ansible all -m ping"
echo "3. MediaWiki: http://10.2.2.1:8080"
