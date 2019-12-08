HOST=arm-buildroot-linux-musleabihf
cc=$(HOST)-cc
cc5=arm-obreey-linux-gnueabi-gcc
strip=$(HOST)-strip
ver=$(shell git describe --tags)

# These are made by the cross compiler
svcbins=svc/bin/dropbear svc/bin/smbd svc/bin/ntlmhash svc/bin/proftpd svc/bin/iptables svc/bin/rsync svc/bin/thttpd

proftpd=proftpd-1.3.5e
iptables=iptables-1.8.3
samba=samba-3.6.25
rsync=rsync-3.1.3
thttpd=thttpd-2.29

# TODO
lftp=lftp-4.8.4
powertop=powertop-v2.10
htop=htop-2.2.0

common_configure=./configure --disable-ipv6 --localstatedir=/var/run --sharedstatedir=/var --host=arm-linux-gnueabi CC=$(cc) --prefix=/mnt/secure --enable-static --disable-shared LDFLAGS="--static -Wl,-gc-sections" CFLAGS="-D__mempcpy=mempcpy -ffunction-sections -fdata-sections" --prefix=/mnt/secure --sbindir=/mnt/secure/bin --datarootdir=/mnt/secure
common_configure5=./configure --disable-ipv6 --localstatedir=/var/run --sharedstatedir=/var --host=arm-linux-gnueabi CC=$(cc5) --prefix=/mnt/secure --enable-static --disable-shared --prefix=/mnt/secure --sbindir=/mnt/secure/bin --datarootdir=/mnt/secure --disable-unicode

SSH_CONFIG_OPTIONS=--disable-pam --disable-syslog --disable-shadow --disable-lastlog --disable-utmp --disable-utmpx --disable-wtmp --disable-wtmpx --disable-loginfunc --disable-pututline --disable-pututxline --disable-zlib

SAMBA_CONFIGURE_VARS=\
	ac_cv_lib_attr_getxattr=no \
	ac_cv_search_getxattr=no \
	ac_cv_file__proc_sys_kernel_core_pattern=yes \
	libreplace_cv_HAVE_C99_VSNPRINTF=yes \
	libreplace_cv_HAVE_GETADDRINFO=yes \
	libreplace_cv_HAVE_IFACE_IFCONF=yes \
	libreplace_cv_HAVE_IPV6=no \
        libreplace_cv_HAVE_IPV6_V6ONLY=no \
	LINUX_LFS_SUPPORT=yes \
	samba_cv_CC_NEGATIVE_ENUM_VALUES=yes \
	samba_cv_HAVE_GETTIMEOFDAY_TZ=yes \
	samba_cv_HAVE_IFACE_IFCONF=yes \
	samba_cv_HAVE_KERNEL_OPLOCKS_LINUX=yes \
	samba_cv_HAVE_SECURE_MKSTEMP=yes \
	samba_cv_HAVE_WRFILE_KEYTAB=no \
	samba_cv_USE_SETREUID=yes \
	samba_cv_USE_SETRESUID=yes \
	samba_cv_have_setreuid=yes \
	samba_cv_have_setresuid=yes \
	ac_cv_header_libunwind_h=no \
	ac_cv_header_zlib_h=no \
	samba_cv_zlib_1_2_3=no \
	ac_cv_path_PYTHON="" \
	ac_cv_path_PYTHON_CONFIG=""

SAMBA_CONFIGURE_ARGS=\
	--disable-avahi \
	--disable-cups \
	--disable-external-libtalloc \
	--disable-external-libtdb \
	--disable-external-libtevent \
	--disable-pie \
	--disable-relro \
	--enable-static \
	--disable-swat \
	--disable-shared-libs \
	--with-codepagedir=/mnt/secure/etc/samba \
	--with-configdir=/mnt/secure/etc/samba \
	--with-included-iniparser \
	--with-included-popt \
	--with-lockdir=/var/lock \
	--with-logfilebase=/var/log \
	--with-nmbdsocketdir=/var/nmbd \
	--with-piddir=/var/run \
	--with-privatedir=/mnt/secure/etc/samba \
	--with-sendfile-support \
	--without-acl-support \
	--without-cluster-support \
	--without-ads \
	--without-krb5 \
	--without-ldap \
	--without-pam \
	--without-winbind \
	--without-libtdb \
	--without-libtalloc \
	--without-libnetapi \
	--without-libsmbclient \
	--without-libsmbsharemodes \
	--without-libtevent \
	--without-libaddns \
	--with-shared-modules=pdb_wbc_sam,idmap_nss,nss_info_template,auth_winbind,auth_wbc,auth_domain,rpc_lsarpc,rpc_samr,rpc_winreg,rpc_initshutdown,rpc_dssetup,rpc_wkssvc,rpc_svcctl,rpc_ntsvcs,rpc_netlogon,rpc_netdfs,rpc_srvsvc,rpc_spoolss,rpc_eventlog,auth_unix,auth_winbind,auth_wbc


# When running just "make", package the .app files and .zip release, don't bother to track dependencies for shell sript stuff.
all: pbjb-$(ver).zip
pbjb-$(ver).zip: Uninstall.app Jailbreak.app Services.app
	zip pbjb-$(ver).zip *.app
purge: clean
	rm -rf $(proftpd) $(samba) $(iptables) $(proftpd).tar.gz $(samba).tar.gz $(iptables).tar.bz2
clean:
	rm -f Jailbreak.app Services.app pbjb.zip $(svcbins)
	make -C $(proftpd) clean || true
	make -C $(samba) clean || true
	make -C $(iptables) clean || true
	make -C dropbear-hacks/src clean || true
Jailbreak.app: jailbreak.c
	$(cc) -s -static $< -o $@
ctest.app: ctest.c
	$(cc) -s -static $< -o $@
svc/bin/suspendd: suspendd.c
	$(cc5) -s -linkview -Wall $< -o $@


Services.app: FORCE svc
	cat services-installer.sh | sed "s/PKGVER=.*/PKGVER=$(ver)/" > Services.app
	tar cvzf - -C svc . >> Services.app
	#tar cvf test.tar -C svc .

svc: $(svcbins)
	echo Cross-compiled service binaries

# Retrieve source codes for binaries we compile statically with musl (smaller / more portable)

$(thttpd):
	wget -c https://acme.com/software/thttpd/$(thttpd).tar.gz
	tar -xvzf $(thttpd).tar.gz
$(proftpd):
	wget -c ftp://ftp.proftpd.org/distrib/source/$(proftpd).tar.gz
	tar -xvzf $(proftpd).tar.gz
$(samba):
	wget -c https://download.samba.org/pub/samba/stable/$(samba).tar.gz
	tar -xvzf $(samba).tar.gz
	cd $(samba) && for p in ../samba-patches/*; do patch -p1 < $$p || exit 1; done
$(iptables):
	wget -c https://netfilter.org/projects/iptables/files/$(iptables).tar.bz2
	tar -xvjf $(iptables).tar.bz2
$(rsync):
	wget -c https://download.samba.org/pub/rsync/$(rsync).tar.gz
	tar -xvzf $(rsync).tar.gz

# These depend on cc5 sdk, as they need ncurses or openssl (static musl would become too big)
$(htop):
	wget -c https://hisham.hm/htop/releases/2.2.0/$(htop).tar.gz
	tar -xvzf $(htop).tar.gz
$(powertop):
	wget -c https://01.org/sites/default/files/downloads/$(powertop).tar.gz
	tar -xvzf $(powrtop).tar.gz
$(lftp):
	wget -c http://lftp.yar.ru/ftp/$(lftp).tar.gz
	tar -xvzf $(lftp).tar.gz

# each of svcbin
svc/bin/iptables: $(iptables)
	(cd $(iptables) && $(common_configure) --disable-devel --disable-nftables --with-xt-lock-name=/var/run/xtables.lock)
	make -C $(iptables)
	$(strip) $(iptables)/iptables/xtables-legacy-multi -o $@

svc/bin/proftpd: $(proftpd)
	(cd $(proftpd) && $(common_configure) --disable-autoshadow --without-pic --disable-auth-pam  --disable-cap --disable-facl --disable-dso  --disable-trace)
	make -C $(proftpd)
	$(strip) $(proftpd)/proftpd -o $@

svc/bin/dropbear: dropbear-hacks
	cp -f dropbear-options.h dropbear-hacks/src/options.h
	(cd dropbear-hacks/src && $(common_configure) --verbose $(SSH_CONFIG_OPTIONS))
	make -C dropbear-hacks/src PROGRAMS="dropbear dbclient scp" MULTI=1 STATIC=1
	$(strip) dropbear-hacks/src/dropbearmulti -o $@

svc/bin/smbd: $(samba)
	(cd $(samba)/source3 && $(common_configure) $(SAMBA_CONFIGURE_VARS) $(SAMBA_CONFIGURE_ARGS) LDFLAGS="-static -Lbin -Wl,--gc-sections")
	make -C $(samba)/source3 MODULES= PICFLAG= DYNEXP=
	$(strip) $(samba)/source3/bin/samba_multicall -o $@

svc/bin/rsync: $(rsync)
	(cd $(rsync) && $(common_configure))
	make -C $(rsync)
	$(strip) $(rsync)/rsync -o $@

svc/bin/ntlmhash: ntlmhash.c
	$(cc) -static -s $< -o $@

svc/bin/thttpd: $(thttpd)
	(cd $(thttpd) && CC=$(cc) ./configure --prefix=/ --host=arm-linux-gnueabi)
	make -C $(thttpd) LDFLAGS="-static"
	$(strip) $(thttpd)/thttpd -o $@

svc/bin/htop: $(htop)
	(cd $(htop) && $(common_configure5) ac_cv_lib_ncurses_refresh=yes LIBS=-lncurses HTOP_NCURSES_CONFIG_SCRIPT=/bin/false)
	make -C $(htop)
	$(strip) $(htop)/htop -o $@
FORCE:



