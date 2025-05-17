#!/bin/bash

# Создание пользователя sshuser с UID 1010
useradd -u 1010 -m sshuser

# Установка пароля P@ssw0rd без подтверждения
echo "sshuser:P@ssw0rd" | chpasswd

# Добавление в группу wheel
gpasswd -a sshuser wheel

# Настройка sudo без пароля
echo "sshuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Настройка SSH
sed -i 's/#Port 22/Port 2024/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
echo "AllowUsers sshuser" >> /etc/ssh/sshd_config
echo "MaxAuthTries 2" >> /etc/ssh/sshd_config
echo "Banner /etc/openssh/banner" >> /etc/ssh/sshd_config

# Создание баннера
mkdir -p /etc/openssh
echo "Authorized access only" > /etc/openssh/banner

# Права на баннер
chmod 644 /etc/openssh/banner

# Перезапуск SSH
systemctl restart sshd

echo "Настройка завершена:"
echo "- Пользователь: sshuser (пароль: P@ssw0rd)"
echo "- SSH порт: 2024"
echo "- Root-логин запрещен"
echo "- Баннер создан"
