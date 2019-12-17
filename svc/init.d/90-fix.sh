#!/bin/sh
##Don't suspend wifi when a service is in use
if [ `tail -c+2 /ebrmain/bin/netagent | head -c3` == "ELF" ] && [ -s /mnt/secure/bin/netagent ]; then
	cp -f -L -u /ebrmain/bin/netagent /mnt/secure/bin/netagent_orig
	mount -o bind /mnt/secure/bin/netagent /ebrmain/bin/netagent
fi
