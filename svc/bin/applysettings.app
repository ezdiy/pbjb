#!/mnt/secure/su /bin/sh
iv2sh SetActiveTask `pidof settings.app` 0
export PATH=/mnt/secure/bin:$PATH
dialog 1 "" "Do you really want restart the device?" "Yes" "No"
if [ $? != 1 ]; then
	exit 0
fi
iptables-save > /mnt/secure/etc/firewall
sync
/sbin/reboot
