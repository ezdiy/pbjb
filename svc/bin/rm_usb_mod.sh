#!/bin/sh
DIR=/sys/class/android_usb/android0
echo > ${DIR}/f_mass_storage/lun/file
