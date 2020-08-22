#!/bin/sh
for n in /mnt/secure/etc/mod/`uname -r`/*/*.ko.gz; do
	insmod $n
done
