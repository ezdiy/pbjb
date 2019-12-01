#!/mnt/secure/su /bin/sh
if [ -e /mnt/ext1/rootpassword.txt ]; then
	password="$(cut -c 10- < /mnt/ext1/rootpassword.txt)"
	if [ "$password" == "(keep unchanged)" ]; then
		if [ -e /mnt/secure/etc/passwd ]; then
			exit 0
		fi
		password=$RANDOM
		echo "password=$password" > /mnt/ext1/rootpassword.txt
	fi
	echo -n "$password" > /mnt/secure/etc/passwd
fi

suff=":[U          ]:LCT-00000001:"
pw="$(cat /mnt/secure/etc/passwd)"
(echo "root:0:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX:"$(ntlmhash "$pw")"$suff"; echo "reader:100:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX:"$(ntlmhash "")"$suff") > /mnt/secure/etc/samba/smbpasswd

echo -e "ftp:*:100:100::/mnt/ext1/public:/bin/false\nroot:"$(mkpasswd "$pw")":0:0::/mnt/ext1:/bin/false" > /mnt/secure/etc/ftpd.passwd
chmod 700 /mnt/secure/etc/ftpd.passwd

