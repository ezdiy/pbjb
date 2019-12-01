#!/mnt/secure/su /bin/sh
/ebrmain/dialog 2 "" "Do you wish to remove root and services (if installed)? "Yes" "No"
if [ $? != 1 ]; then
	exit 0
fi
chattr -i /mnt/secure/su /mnt/secure/runonce/*.sh
rm -rf /mnt/secure/su /mnt/secure/runonce/*.sh /mnt/secure/bin /mnt/secure/etc
reboot
