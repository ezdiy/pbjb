#!/mnt/secure/su /bin/sh
##HTTP server
mkdir /mnt/ext1/public_html
lighttpd -f /mnt/secure/etc/lighttpd.conf
