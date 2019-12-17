#!/bin/sh
# This is necessary, otherwise processes with /etc/localtime open will get killed on USB storage.
# Don't bother with write-free shadowing, localtime is too trivial for that.
f=`readlink /etc/localtime`
if [ "$f" != "" ]; then
        mount -o remount,rw /
        rm -f /etc/localtime
        cp -f "$f" /etc/localtime
        chmod 644 /etc/localtime
        mount -o remount,ro /
fi
mount -o bind /mnt/secure/etc/terminfo /usr/share/terminfo

