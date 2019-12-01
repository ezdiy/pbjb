#!/mnt/secure/su /bin/sh
iv2sh SetActiveTask `pidof bookshelf.app` 0
dialog 2 "" "Do you wish to remove root and services (if installed)?" "Yes" "No"
if [ $? != 1 ]; then
	exit 0
fi
chattr -i /mnt/secure/su /mnt/secure/runonce/*.sh
rm -rf /mnt/secure/su /mnt/secure/runonce/*.sh /mnt/secure/bin /mnt/secure/etc
rm -f /mnt/system/config/settings.json
mv -f /mnt/system/config/settings.old /mnt/system/config/settings.json
dialog 1 "" "Services uninstalled, restart is needed." "Restart now" "Will restart manually"
if [ $? == 1 ]; then
	/sbin/reboot
fi
reboot
