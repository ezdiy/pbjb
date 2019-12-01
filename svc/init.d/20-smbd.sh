#!/mnt/secure/su /bin/sh
##SMB server
smbd -D -s /mnt/secure/etc/samba/smb.conf
nmbd -D -s /mnt/secure/etc/samba/smb.conf
