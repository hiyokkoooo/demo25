#!/bin/bash

# 1. Создание пользователя net_admin
useradd -m net_admin

# 2. Установка пароля P@$$word (без подтверждения)
echo "net_admin:P@$$word" | chpasswd

# 3. Добавление в группу wheel
gpasswd -a net_admin wheel

# 4. Настройка sudo без пароля (через echo вместо nano)
echo "net_admin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# 5. Настройка SSH (порт 2024 и запрет root-логина)
sed -i 's/#Port 22/Port 2024/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# 6. Перезапуск SSH
systemctl restart sshd

echo "Готово! Пользователь net_admin создан, SSH настроен на порт 2024."
