#!/bin/secure/su /bin/sh
##HTTP server
mkdir /mnt/ext1/public_html
thttpd -T utf8 -u reader -nos -d /mnt/ext1/public_html -c '**.cgi'
