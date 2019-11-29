#!/system/secure/su /bin/sh
# This is necessary, otherwise processes with /etc/localtime open will get killed on USB storage.
mount -o remount,rw /
rm -f /etc/localtime
cp -f /mnt/ext1/system/timezone /etc/localtime
chmod 644 /etc/localtime
