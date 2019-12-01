#!/mnt/secure/su /bin/sh
export PATH=/mnt/secure/bin:$PATH
iptables-save > /mnt/secure/etc/firewall
sleep 1
sync
/sbin/reboot
