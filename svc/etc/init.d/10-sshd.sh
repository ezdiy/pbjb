#!/bin/sh
##SSH server
exec /mnt/secure/bin/dropbear -m -b /mnt/secure/etc/motd -B -Y "$(cat /mnt/secure/etc/passwd)" -H /mnt/secure
