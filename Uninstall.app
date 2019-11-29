#!/mnt/secure/su /bin/sh
chattr -i /mnt/secure/su /mnt/secure/runonce/*.sh
rm -rf /mnt/secure/su /mnt/secure/runonce/*.sh /mnt/secure/bin /mnt/secure/etc
rm -f $0
reboot
