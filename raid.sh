#!/bin/bash

# Создание RAID 5
mdadm --create --verbose /dev/md0 -l 5 -n 3 /dev/sd[b-d]

# Сохранение конфигурации
mdadm --detail -scan > /etc/mdadm.conf

# Работа с fdisk (автоматический ввод 'n' и 'w')
echo -e "n\n\n\n\n\nw" | fdisk /dev/md0

# Форматирование раздела
mkfs.ext4 /dev/md0p1

# Создание директории и монтирование
mkdir /raid5

# Добавление в fstab через echo (без nano)
echo "/dev/md0p1 /raid5 ext4 defaults 0 0" >> /etc/fstab
mount -a

# Установка NFS
apt-get install -y nfs-server
systemctl enable --now nfs

# Настройка NFS
mkdir /raid5/nfs
chown -R 99:99 /raid5/nfs
chmod 777 /raid5/nfs

# Добавление экспорта NFS через echo (без nano)
echo "/raid5/nfs 10.1.1.64/28(rw,sync,no_subtree_check)" >> /etc/exports

# Перезапуск NFS и создание тестового файла
systemctl restart nfs
touch /raid5/nfs/test

echo "Готово! RAID 5 и NFS настроены."
