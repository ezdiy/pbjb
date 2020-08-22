#!/bin/sh
if [ "$1" == "query" ]; then
	USB_STATE=$(cat /sys/class/android_usb/f_mass_storage/device/state | tr -d " \n")
	[ "$USB_STATE" = "CONFIGURED" ] && exit 99
fi
exit 0
