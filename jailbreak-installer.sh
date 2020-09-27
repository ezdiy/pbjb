#!/bin/sh
PKGVER=v4
iv2sh SetActiveTask `pidof bookshelf.app` 0
if [ -e /mnt/secure/su ]; then
	dialog 2 "" "Do you wish to remove root?" "Yes" "No"
	if [ $? != 1 ]; then
		exit 0
	fi
	/mnt/secure/su /bin/chattr -i /mnt/secure/su
	/mnt/secure/su /bin/rm -f /mnt/secure/su
	if [ -e /mnt/secure/su ]; then
		dialog 3 "" "Failed to remove root" "OK"
	else
        dialog 1 "" "Root removed." "Restart now" "Restart later"
        if [ $? == 1 ]; then
            sync
            iv2sh reboot
        fi
	fi
	exit 0
fi

dialog 2 "" "Do you wish to install root?

* This may void warranty.
* The device will reboot on success.
* Failure can be silent.
" "Yes" "No"
if [ $? != 1 ]; then
	exit 0
fi

rm -f /var/tmp/su
rm -f /var/tmp/jailbreak
ARCHIVE=`awk '/^__DATA/ {print NR + 1; exit 0; }' $0`
tail -n+$ARCHIVE $0 | tar xz -C /var/tmp
/tmp/jailbreak "/bin/chmod 755 /mnt/secure;cp -f /tmp/su /mnt/secure/su;/bin/chown 0:0 /mnt/secure/su;/bin/chmod 4755 /mnt/secure/su;/bin/chattr +i /mnt/secure/su;/bin/sync;/sbin/reboot"
if ! [ -e /mnt/secure/su ]; then
    dialog 3 "" "Failed to install root" "OK"
fi

exit 0
__DATA
