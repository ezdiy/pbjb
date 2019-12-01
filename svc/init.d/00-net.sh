#!/mnt/secure/su /bin/sh
#rapidly nuke dead tcp sessions
cd /proc/sys/net/ipv4
echo 60 > tcp_keepalive_time
echo 5 > tcp_keepalive_intvl
echo 3 > tcp_keepalive_probes
ifconfig lo up 127.0.0.1
