#!/mnt/secure/su /bin/sh
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
