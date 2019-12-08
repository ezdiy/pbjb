#!/mnt/secure/su /bin/sh
if [ -e /mnt/ext1/rootpassword.txt ]; then
	password="$(cut -c 10- < /mnt/ext1/rootpassword.txt)"
	if [ "$password" == "(keep unchanged)" ]; then
		if ! [ -e /mnt/secure/etc/passwd ]; then
			password=$RANDOM
			echo "password=$password" > /mnt/ext1/rootpassword.txt
		fi
	fi
	if [ "$password" != "(keep unchanged)" ]; then
		echo -n "$password" > /mnt/secure/etc/passwd
	fi
fi

suff=":[U          ]:LCT-00000001:"
pw="$(cat /mnt/secure/etc/passwd)"
(echo "root:0:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX:"$(ntlmhash "$pw")"$suff"; echo "reader:100:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX:"$(ntlmhash "")"$suff") > /mnt/secure/etc/samba/smbpasswd
hpw="$(mkpasswd -m des "$pw")"
echo -e "ftp:*:100:100::/mnt/ext1/public:/bin/false\nroot:$hpw:0:0::/mnt/ext1:/bin/false" > /mnt/secure/etc/ftpd.passwd
dpw=$(echo -n "root:webdav:$pw" | md5sum | cut -b -32)
echo -e "root:webdav:$dpw" > /mnt/secure/etc/htdigest
chmod 600 /mnt/secure/etc/ftpd.passwd /mnt/secure/etc/htdigest

