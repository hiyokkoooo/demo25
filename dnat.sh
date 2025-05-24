#!/bin/bash

# Пароли и параметры (можно изменить)
HQ_RTR_IP="172.16.4.1"
HQ_RTR_USER="net_admin"
HQ_RTR_PASS="P@ssw0rd"

HQ_SRV_IP="10.1.1.1"
HQ_SRV_USER="sshuser"
HQ_SRV_PASS="P@ssw0rd"

BR_SRV_IP="10.2.2.1"
BR_SRV_USER="sshuser"
BR_SRV_PASS="P@ssw0rd"

# Функция для выполнения команд через SSH
ssh_exec() {
    sshpass -p "$2" ssh -tt -o StrictHostKeyChecking=no -p 2024 "$1@$3" "$4"
}

echo "=== Начинаем настройку с BR-RTR (текущая машина) ==="

# 1. Настройка iptables на BR-RTR
iptables -t nat -A PREROUTING -p tcp -d 10.2.2.30 --dport 80 -j DNAT --to-destination 10.2.2.1:8080
iptables -t nat -A PREROUTING -p tcp -d 10.2.2.30 --dport 2024 -j DNAT --to-destination 10.2.2.1:2024
iptables-save > /etc/sysconfig/iptables
systemctl restart iptables
echo "Правила iptables на BR-RTR добавлены"

# 2. Настройка HQ-RTR через SSH
echo "=== Настраиваем HQ-RTR (172.16.4.1) через SSH ==="
ssh_exec "$HQ_RTR_USER" "$HQ_RTR_PASS" "$HQ_RTR_IP" "
iptables -t nat -A PREROUTING -p tcp -d 10.1.1.62 --dport 2024 -j DNAT --to-destination 10.1.1.1:2024
iptables-save > /etc/sysconfig/iptables
systemctl restart iptables
apt-get install -y nginx wget
mkdir -p /etc/nginx/conf-available.d/
cd /etc/nginx/conf-available.d/
wget https://raw.githubusercontent.com/hiyokkoooo/demo25/refs/heads/main/revproxy.conf
rm -rf /etc/nginx/sites-enabled.d/default.conf
ln -s /etc/nginx/conf-available.d/revproxy.conf /etc/nginx/sites-enabled.d/
systemctl enable --now nginx
echo 'Настройка HQ-RTR завершена'
"

# 3. Настройка HQ-SRV через SSH
echo "=== Настраиваем HQ-SRV (10.1.1.1) через SSH ==="
ssh_exec "$HQ_SRV_USER" "$HQ_SRV_PASS" "$HQ_SRV_IP" "
sed -i \"s|\\\$CFG->wwwroot.*|\\\$CFG->wwwroot = 'http://moodle.au-team.irpo/moodle';|\" /var/www/webapps/moodle/config.php
systemctl restart mariadb
systemctl restart httpd2
echo 'Настройка HQ-SRV завершена'
"

echo "=== Все настройки выполнены! ==="
echo "Проверьте:"
echo "1. Доступ к Moodle: http://moodle.au-team.irpo"
echo "2. Порт 2024 на HQ-RTR и BR-RTR"
