#!/mnt/secure/su /bin/sh
iv2sh SetActiveTask $$ 0
dialog 1 "" "Do you wish to (re)install unix services on this rooted device?" "Yes" "No"
if [ $? != 1 ]; then
	exit 0
fi
ARCHIVE=`awk '/^__DATA/ {print NR + 1; exit 0; }' $0`
chattr -i /mnt/secure/runonce/*.sh
tail -n+$ARCHIVE $0 | tar xz -C /mnt/secure
chattr +i /mnt/secure/runonce/*.sh /mnt/secure/su
if [ ! -e /mnt/secure/etc/passwd ]; then
	PW=$RANDOM
	echo -n $PW > /mnt/ext1/password.txt
fi
rm -f "$0"
sync
dialog 1 "" "Services installed, restart is needed to get em running." "Restart now" "Will restart manually"
if [ $? == 1 ]; then
	/sbin/reboot
fi
__DATA
