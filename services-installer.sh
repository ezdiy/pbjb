#!/mnt/secure/su /bin/sh
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
/sbin/reboot
__DATA
