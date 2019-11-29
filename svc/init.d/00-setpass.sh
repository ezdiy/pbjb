#!/mnt/secure/su /bin/sh
if [ ! -e /mnt/secure/etc/passwd ] || [ -n "$(find -L /mnt/ext1/password.txt -prune -newer /mnt/secure/etc/passwd)" ]; then
        if [ ! -e /mnt/ext1/password.txt ]; then
                echo $RANDOM > /mnt/ext1/password.txt
        fi
        echo -n "$(cat /mnt/ext1/password.txt)" > /mnt/secure/etc/passwd
fi
suff=":[U          ]:LCT-00000001:"
pw="$(cat /mnt/secure/etc/passwd)"
(echo "root:0:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX:"$(ntlmhash "$pw")"$suff"; echo "reader:100:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX:"$(ntlmhash "")"$suff") > /mnt/secure/etc/samba/

echo -e "ftp:*:100:100::/mnt/ext1/public:/bin/false\nroot:"$(mkpasswd "$pw")":0:0::/mnt/ext1:/bin/false" > /mnt/secure/etc/ftpd.passwd
chmod 700 /mnt/secure/etc/ftpd.passwd

