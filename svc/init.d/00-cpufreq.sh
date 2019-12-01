#!/mnt/secure/su /bin/sh
##CPU frequency scaling
cd /sys/devices/system/cpu/cpu0/cpufreq
cat cpuinfo_min_freq > scaling_min_freq
cat cpuinfo_max_freq > scaling_max_freq
