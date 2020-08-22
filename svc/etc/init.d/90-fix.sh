#!/bin/sh
##Suspend integration

umount /ebrmain/bin/netagent
umount /var/tmp/netagent.orig
touch /var/tmp/netagent.orig
mount -o bind /ebrmain/bin/netagent /var/tmp/netagent.orig
mount -o bind /mnt/secure/bin/netagent /ebrmain/bin/netagent

function monitor() {
while true; do
	sleep 30
	if ! [ -e /var/tmp/disconnect_pending ]; then
		continue
	fi

        # Disconnect was requested, but we're vary to do that.
        if ps | awk {'print $5'} | grep '^-sh$' > /dev/null; then
		continue
        fi
        if [ `pidof smbd | wc -w` -gt 2 ]; then
		continue
        fi
        if [ `pidof proftpd | wc -w` -gt 1 ]; then
		continue
        fi
        if [ "$(cat /sys/class/power_supply/usb/online)" -eq "1" ]; then
		continue
        fi
        if [ "$(cat /sys/class/power_supply/ac/online)" -eq "1" ]; then
		continue
	fi

	# Finally disconnect
	if ! [ -e /var/tmp/disconnect_pending ]; then
		continue
	fi
	rm -f /var/tmp/disconnect_pending
	/var/tmp/netagent.orig disconnect
done
}

monitor &

