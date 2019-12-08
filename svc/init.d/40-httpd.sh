#!/mnt/secure/su /bin/sh
##HTTP server
mkdir /mnt/ext1/public_html
ln -s $0 /tmp/service.$1
lighttpd -f /mnt/secure/etc/lighttpd.conf
