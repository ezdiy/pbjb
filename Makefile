HOST=arm-buildroot-linux-musleabihf
proftpd=proftpd-1.3.5e
CONFIG_OPTIONS=--disable-pam --disable-syslog --disable-shadow --disable-lastlog --disable-utmp --disable-utmpx --disable-wtmp --disable-wtmpx --disable-loginfunc --disable-pututline --disable-pututxline --disable-zlib

#--disable-syslog --disable-zlib --disable-pam --disable-shadow
all: pbjb.zip
pbjb.zip: Uninstall.app Jailbreak.app Services.app
	zip pbjb.zip *.app
clean:
	rm -f Jailbreak.app Services.app pbjb.zip svc/bin/dropbear svc/bin/smbd svc/bin/ntlmhash svc/bin/proftpd
	make -C $(proftpd) clean || true
	make -C dropbear-hacks/src clean || true
Jailbreak.app: hax.c
	arm-buildroot-linux-musleabihf-gcc -s -static $< -o $@
Services.app: FORCE
	(cat svc.sh && tar cvzf - -C svc .) > Services.app
	#tar cvf test.tar -C svc .
svc: svc/bin/dropbear svc/bin/smbd svc/bin/ntlmhash svc/bin/proftpd
	echo done

pure-ftpd-1.0.49:
	wget -c https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.49.tar.gz
	tar -xvzf pure-ftpd-1.0.49.tar.gz
svc/bin/pure-ftpd: pure-ftpd-1.0.49
	(cd pure-ftpd-1.0.49 && ./configure --without-inetd --without-privsep --without-shadow --without-ascii --without-globbing --with-puredb --disable-silent-rules --prefix=/mnt/secure --sbindir=/mnt/secure/bin --sharedstatedir=/var --localstatedir=/var --datadir=/mnt/secure --host=arm-linux-gnueabi CC="arm-buildroot-linux-musleabihf-gcc" LDFLAGS="-static -Wl,-gc-sections" CFLAGS="-ffunction-sections -fdata-sections -DACCEPT_ROOT_VIRTUAL_USERS=1")
	make -C pure-ftpd-1.0.49
	cp -f pure-ftpd-1.0.49/src/pure-ftpd svc/bin/pure-ftpd
	cp -f pure-ftpd-1.0.49/src/pure-pw svc/bin/pure-pw
	arm-buildroot-linux-musleabihf-strip svc/bin/pure-*

$(proftpd).tar.gz:
	wget -c ftp://ftp.proftpd.org/distrib/source/$(proftpd).tar.gz
	tar -xvzf $(proftpd).tar.gz

svc/bin/proftpd:
	(cd $(proftpd) && ./configure --disable-autoshadow --without-pic --disable-auth-pam  --disable-cap --disable-facl --disable-dso  --disable-trace  --disable-ipv6 CC=arm-buildroot-linux-musleabihf-gcc LDFLAGS="--static -Wl,-gc-sections" CFLAGS="-D__mempcpy=mempcpy -ffunction-sections -fdata-sections" --prefix=/mnt/secure --sbindir=/mnt/secure/bin --sharedstatedir=/var --datarootdir=/mnt/secure)
	make -C $(proftpd)
	cp -f $(proftpd)/proftpd svc/bin
	arm-buildroot-linux-musleabihf-strip svc/bin/proftpd

svc/bin/dropbear:
	cp options.h dropbear-hacks/src
	cd dropbear-hacks/src && ./configure LDFLAGS="-static -Wl,-gc-sections" CFLAGS="-ffunction-sections -fdata-sections" --verbose $(CONFIG_OPTIONS) --host=$(HOST)
	#make -C dropbear-hacks MULTI=1 CC=arm-buildroot-linux-musleabihf-gcc TRIP=arm-buildroot-linux-musleabihf-strip PROGRAMS="scp dbclient dropbear" BUILDSTATIC=1 || true
	make -C dropbear-hacks/src MULTI=1 CC=arm-buildroot-linux-musleabihf-gcc HOST=arm-buildroot-linux-musleabihf STRIP=arm-buildroot-linux-musleabihf-strip PROGRAMS="scp dbclient dropbear" BUILDSTATIC=1 || true
	cp dropbear-hacks/src/dropbearmulti svc/bin/dropbear
	arm-buildroot-linux-musleabihf-strip svc/bin/dropbear
svc/bin/smbd:
	cp -f ./samba-3.6.25/source3/bin/smbd svc/bin
	arm-buildroot-linux-musleabihf-strip svc/bin/smbd
svc/bin/ntlmhash: ntlmhash.c
	arm-buildroot-linux-musleabihf-gcc -static -s ntlmhash.c -o svc/bin/ntlmhash
FORCE:
