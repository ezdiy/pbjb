#!/bin/sh
for n in /mnt/secure/etc/mod/*/*.ko.gz; do
	insmod $n
done
