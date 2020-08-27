#!/bin/sh
DIR=/sys/class/android_usb/android0
echo "/dev/user_int" > ${DIR}/f_mass_storage/lun/file
echo "/dev/user_ext" > ${DIR}/f_mass_storage/lun/file
