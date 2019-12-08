#!/mnt/secure/su /bin/sh
ip=$(/sbin/ifconfig eth0 |grep 'inet addr' | sed -e 's/.*addr:\([^ ]*\).*/\1/g' | head -1)
if [ "$ip" == "" ]; then
        ip="not connected"
fi
svcs=""
function check() {
if [ "$(pidof $1)" != "" ]; then
        svcs="$svcs $2"
fi
}
check dropbear SSHD
check lighttpd HTTPD
check smbd SMBD
check proftpd FTPD
dialog 1 "" "Version: $(cat /mnt/secure/.pkgver)"
IP: $ip
UP: $svcs
Load:  $(cut -d ' ' -f 1-3 < /proc/loadavg)
$(cat /proc/meminfo  |egrep "^Mem|^Cached" | sed -e 's/: */: /g')" "OK"

