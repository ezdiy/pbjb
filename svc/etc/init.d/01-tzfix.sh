#!/bin/sh
umount /etc/localtime
cp -Lf /etc/localtime /var/tmp/localtime
mount -o bind /var/tmp/localtime /etc/localtime
mount -o bind /mnt/secure/etc/terminfo /usr/share/terminfo

