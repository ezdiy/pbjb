#!/mnt/secure/su /bin/sh
if [ `tail -c+2 /ebrmain/bin/netagent | head -c3` == "ELF" ] && [ -s /mnt/secure/bin/netagent ]; then
	cp -f -L -u /ebrmain/bin/netagent /mnt/secure/bin/netagent_orig
	mount -o bind /mnt/secure/bin/netagent /ebrmain/bin/netagent
fi
for n in ins_usbnet rm_usbnet ins_usb_mod rm_usb_mod; do
	umount /lib/modules/$n.sh
done
mount -o bind /mnt/secure/bin/ins_usb_mod.sh /lib/modules/ins_usb_mod.sh
mount -o bind /mnt/secure/bin/rm_usb_mod.sh /lib/modules/rm_usb_mod.sh
mount -o bind /mnt/secure/bin/empty.sh /lib/modules/ins_usbnet.sh
mount -o bind /mnt/secure/bin/empty.sh /lib/modules/rm_usbnet.sh
