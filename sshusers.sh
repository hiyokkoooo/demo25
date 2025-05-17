#!/bin/bash

# Добавляем пользователя sshuser с UID 1010 и домашней директорией
useradd -u 1010 -m sshuser

# Устанавливаем пароль P@sswOrd (без подтверждения)
echo "sshuser:P@sswOrd" | chpasswd

# Добавляем sshuser в группу wheel (если группа существует)
gpasswd -a sshuser wheel

# Настраиваем sudo для sshuser (разрешаем все команды без пароля)
if [ -f /etc/sudoers ]; then
    echo "sshuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    echo "Настройка sudo для sshuser выполнена."
else
    echo "Ошибка: файл /etc/sudoers не найден!"
    exit 1
fi

# Проверяем результат
echo "Пользователь sshuser создан. Пароль: P@sswOrd. Права sudo настроены."
