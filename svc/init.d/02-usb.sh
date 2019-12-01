#!/mnt/secure/su /bin/sh
##USBnet
for n in ins_usbnet rm_usbnet ins_usb_mod rm_usb_mod; do
	umount /lib/modules/$n.sh
done
mount -o bind /mnt/secure/bin/ins_usb_mod.sh /lib/modules/ins_usb_mod.sh
mount -o bind /mnt/secure/bin/rm_usb_mod.sh /lib/modules/rm_usb_mod.sh
mount -o bind /mnt/secure/bin/empty.sh /lib/modules/ins_usbnet.sh
mount -o bind /mnt/secure/bin/empty.sh /lib/modules/rm_usbnet.sh
cd /sys/class/android_usb/android0
echo 0 > enable
echo rndis,mass_storage > functions
#pname="`cat /ebrmain/config/device.cfg | awk -F = '/^usb_product_name=/ {print $2}'`"
#echo "$pname (Jailbroken)" > iProduct
#cat /var/run/serial > iSerial
#echo 1 > f_rndis/wceis
echo 1 > enable
count=0
while ! ifconfig rndis0 up 169.254.0.1; do
	sleep 1
	count=$((count+1))
	if [ $count -gt 3 ]; then
		exit
	fi
done
cat << EOF > /var/run/udhcpd.conf
start 169.254.0.2
end 169.254.255.254
interfaces rndis0
opt subnet 255.255.0.0
EOF
/sbin/udhcpd /var/run/udhcpd.conf
