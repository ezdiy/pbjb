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
		dialog 1 "" "Root removed" "OK"
	fi
	exit 0
fi

dialog 2 "" "Do you wish to install root?
Beware, this may void warranty.
" "Yes" "No"
if [ $? != 1 ]; then
	exit 0
fi

ARCHIVE=`awk '/^__DATA/ {print NR + 1; exit 0; }' $0`
rm -f /var/tmp/su
tail -n+$ARCHIVE $0 | tar xz -C /var/tmp

if /var/tmp/su /bin/id | grep root; then
	/var/tmp/su /bin/chmod 755 /mnt/secure
	/var/tmp/su /bin/cp /var/tmp/su /mnt/secure/su
	/var/tmp/su /bin/chown 0:0 /mnt/secure/su
	/var/tmp/su /bin/chmod 4755 /mnt/secure/su
	/var/tmp/su /bin/chattr +i /mnt/secure/su
	/mnt/secure/su /bin/rm -f /var/tmp/su
	dialog 1 "" "Root installed" "OK"
else
	dialog 3 "" "Failed to install root" "OK"
fi
exit 0
__DATA
