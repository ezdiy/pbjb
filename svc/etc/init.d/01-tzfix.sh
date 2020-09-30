#!/bin/sh
umount /etc/localtime
cp -Lf /etc/localtime /var/tmp/localtime
cp -af /mnt/secure/etc/terminfo /var/tmp/terminfo
mount -o bind /var/tmp/localtime /etc/localtime
mount -o bind /var/tmp/terminfo /usr/share/terminfo

