#!/bin/bash

# Создание RAID 5 (md0) из устройств /dev/sdb, /dev/sdc, /dev/sdd
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 /dev/sd[b-d]

# Сохранение конфигурации RAID
mdadm --detail --scan > /etc/mdadm.conf

# Создание раздела на RAID (автоматический ввод 'n' и 'w' для fdisk)
echo -e "n\n\n\n\n\nw" | fdisk /dev/md0

# Форматирование раздела в ext4
mkfs.ext4 /dev/md0p1

# Создание точки монтирования
mkdir -p /raid5

# Добавление в fstab для автоматического монтирования
echo "/dev/md0p1 /raid5 ext4 defaults 0 0" >> /etc/fstab

# Монтирование
mount -a

# Установка и запуск NFS-сервера
apt-get update
apt-get install -y nfs-kernel-server
systemctl enable --now nfs-server

# Создание NFS-директории и настройка прав
mkdir -p /raid5/nfs
chown -R 99:99 /raid5/nfs
chmod 777 /raid5/nfs

# Настройка экспорта NFS
echo "/raid5/nfs 10.1.1.64/28(rw,sync,no_subtree_check)" >> /etc/exports

# Перезапуск NFS
systemctl restart nfs-server

# Создание тестового файла
touch /raid5/nfs/test

# Вывод информации
echo "RAID 5 (/dev/md0) создан и настроен."
echo "NFS-сервер запущен. Тестовый файл: /raid5/nfs/test"
echo "Проверьте доступность NFS: showmount -e"
