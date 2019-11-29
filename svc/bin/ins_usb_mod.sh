#!/bin/sh
DIR=/sys/class/android_usb/android0
echo "/dev/mmcblk0p1" > ${DIR}/f_mass_storage/lun/file
