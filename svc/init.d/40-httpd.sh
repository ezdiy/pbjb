#!/bin/sh
##HTTP & WebDAV server
mkdir /mnt/ext1/public_html
if [ "$1" != "" ]; then
        ln -s $0 /tmp/service.$1
fi
lighttpd -f /mnt/secure/etc/lighttpd.conf
