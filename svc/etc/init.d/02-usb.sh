#!/bin/sh
##USBnet
for n in ins_usbnet rm_usbnet ins_usb_mod rm_usb_mod usb_test; do
	umount /lib/modules/$n.sh
done
cp -af /mnt/secure/bin/*.sh /var/tmp/
mount -o bind /var/tmp/ins_usb_mod.sh /lib/modules/ins_usb_mod.sh
mount -o bind /var/tmp/rm_usb_mod.sh /lib/modules/rm_usb_mod.sh
mount -o bind /var/tmp/usb_test.sh /lib/modules/usb_test.sh
mount -o bind /var/tmp/empty.sh /lib/modules/ins_usbnet.sh
mount -o bind /var/tmp/empty.sh /lib/modules/rm_usbnet.sh
cd /sys/class/android_usb/android0
for t in 0 1 2; do
	echo 0 > enable
	echo rndis,mass_storage > functions
	echo 1 > enable
	sleep $t
	if ifconfig rndis0 up 169.254.0.1; then
		cat << EOF > /var/run/udhcpd.conf
start 169.254.0.2
end 169.254.255.254
interface rndis0
opt subnet 255.255.0.0
lease_file /tmp/rndis.leases
EOF
		/sbin/udhcpd /var/run/udhcpd.conf
		exit
	fi
	sleep $t
done
