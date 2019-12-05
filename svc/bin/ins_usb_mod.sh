#!/bin/sh
DIR=/sys/class/android_usb/android0
echo "/dev/mmcblk0p1" > ${DIR}/f_mass_storage/lun/file
if grep -q mmcblk1p1 /proc/partitions; then
	echo /dev/mmcblk1p1 > ${DIR}/f_mass_storage/lun1/file
fi
if grep -q mmcblk2p1 /proc/partitions; then
	echo /dev/mmcblk2p1 > ${DIR}/f_mass_storage/lun2/file
fi

