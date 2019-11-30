HOST=arm-buildroot-linux-musleabihf
cc=$(HOST)-cc
strip=$(HOST)-strip

# These are made by the cross compiler
svcbins=svc/bin/dropbear svc/bin/smbd svc/bin/ntlmhash svc/bin/proftpd svc/bin/iptables

proftpd=proftpd-1.3.5e
iptables=iptables-1.8.3
samba=samba-3.6.25

common_configure=./configure --disable-ipv6 --localstatedir=/var/run --sharedstatedir=/var --host=arm-linux-gnueabi CC=arm-buildroot-linux-musleabihf-gcc --prefix=/mnt/secure --enable-static --disable-shared LDFLAGS="--static -Wl,-gc-sections" CFLAGS="-D__mempcpy=mempcpy -ffunction-sections -fdata-sections" --prefix=/mnt/secure --sbindir=/mnt/secure/bin --datarootdir=/mnt/secure

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
all: pbjb.zip
pbjb.zip: Uninstall.app Jailbreak.app Services.app
	zip pbjb.zip *.app
purge: clean
	rm -rf $(proftpd) $(samba) $(iptables) $(proftpd).tar.gz $(samba).tar.gz $(iptables).tar.bz2
clean:
	rm -f Jailbreak.app Services.app pbjb.zip $(svcbins)
	make -C $(proftpd) clean || true
	make -C $(samba) clean || true
	make -C $(iptables) clean || true
	make -C dropbear-hacks/src clean || true
Jailbreak.app: hax.c
	$(cc) -s -static $< -o $@
Services.app: FORCE svc
	(cat services-installer.sh && tar cvzf - -C svc .) > Services.app
	#tar cvf test.tar -C svc .

svc: $(svcbins)
	echo Cross-compiled service binaries

# Retrieve source codes
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

svc/bin/ntlmhash: ntlmhash.c
	$(cc) -static -s $< -o $@
FORCE:



