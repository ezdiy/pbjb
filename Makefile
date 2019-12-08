HOST=arm-buildroot-linux-musleabihf
cc=$(HOST)-cc
cc5=arm-obreey-linux-gnueabi-gcc
cxx5=arm-obreey-linux-gnueabi-g++
strip=$(HOST)-strip
ver=$(shell git describe --tags)

# These are made by the cross compiler
svcbins=svc/bin/dropbear svc/bin/smbd svc/bin/ntlmhash svc/bin/proftpd svc/bin/iptables svc/bin/rsync svc/bin/lighttpd svc/bin/sftp-server svc/bin/htop svc/bin/powertop svc/bin/nano svc/bin/openvpn svc/bin/lftp

proftpd=proftpd-1.3.5e
iptables=iptables-1.8.3
samba=samba-3.6.25
rsync=rsync-3.1.3
lighttpd=lighttpd-1.4.54
openssh=openssh-8.1p1
powertop=powertop-v2.10
htop=htop-2.2.0
nano=nano-4.6
openvpn=openvpn-2.4.8

# TODO
lftp=lftp-4.8.4

common_configure=./configure --disable-ipv6 --localstatedir=/var/run --sharedstatedir=/var --host=arm-linux-gnueabi CC=$(cc) --prefix=/mnt/secure --enable-static --disable-shared LDFLAGS="--static -Wl,-gc-sections" CFLAGS="-DPUBKEY_RELAXED_PERMS=1 -DSFTPSERVER_PATH=\\\"/mnt/secure/bin/sftp-server\\\" -DDROPBEAR_PATH_SSH_PROGRAM=\\\"/mnt/secure/bin/ssh\\\" -D__mempcpy=mempcpy -ffunction-sections -fdata-sections" --prefix=/mnt/secure --sbindir=/mnt/secure/bin --datarootdir=/mnt/secure

common_configure5=./configure --without-gnutls --with-openssl --disable-lz4 --disable-lzo --disable-ipv6 --localstatedir=/var/run --sharedstatedir=/var --host=arm-obreey-linux-gnueabi CC=$(cc5) CXX=$(cxx5) --prefix=/mnt/secure --disable-shared --prefix=/mnt/secure --sbindir=/mnt/secure/bin --datarootdir=/mnt/secure --disable-unicode --without-included-zlib --without-included-popt

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
	make -C $(samba)/source3 clean || true
	rm -f $(samba)/auth/*.o $(samba)/source3/multi.o || true
	make -C $(iptables) clean || true
	make -C dropbear-hacks/src clean || true
	make -C $(htop) clean
	make -C $(openssh) clean
	make -C $(powertop) clean
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
$(openssh):
	wget -c https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/$(openssh).tar.gz
	tar -xvzf $(openssh).tar.gz

$(lighttpd):
	wget -c https://download.lighttpd.net/lighttpd/releases-1.4.x/$(lighttpd).tar.gz
	tar -xvzf $(lighttpd).tar.gz
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
$(nano):
	wget -c https://www.nano-editor.org/dist/v4/$(nano).tar.gz
	tar -xvzf $(nano).tar.gz
$(openvpn):
	wget -c https://swupdate.openvpn.org/community/releases/$(openvpn).tar.gz
	tar -xvzf $(openvpn).tar.gz

$(powertop):
	wget -c https://01.org/sites/default/files/downloads/$(powertop).tar.gz
	tar -xvzf $(powertop).tar.gz
$(lftp):
	wget -c http://lftp.yar.ru/ftp/$(lftp).tar.gz
	tar -xvzf $(lftp).tar.gz

# each of svcbin
svc/bin/dropbear: dropbear-hacks
	(cd dropbear-hacks/src && $(common_configure) --verbose $(SSH_CONFIG_OPTIONS))
	make -C dropbear-hacks/src PROGRAMS="dropbear dbclient scp" MULTI=1 STATIC=1
	$(strip) dropbear-hacks/src/dropbearmulti -o $@

svc/bin/smbd: $(samba)
	(cd $(samba)/source3 && $(common_configure) $(SAMBA_CONFIGURE_VARS) $(SAMBA_CONFIGURE_ARGS) LDFLAGS="-static -Lbin -Wl,--gc-sections")
	make -C $(samba)/source3 MODULES= PICFLAG= DYNEXP=
	$(strip) $(samba)/source3/bin/samba_multicall -o $@

svc/bin/ntlmhash: ntlmhash.c
	$(cc) -static -s $< -o $@


# The following are linked with sdk (may not work on slightly older firmware)
svc/bin/iptables: $(iptables)
	(cd $(iptables) && $(common_configure5) --disable-devel --disable-nftables --with-xt-lock-name=/var/run/xtables.lock)
	make -C $(iptables)
	$(strip) $(iptables)/iptables/xtables-legacy-multi -o $@

svc/bin/proftpd: $(proftpd)
	(cd $(proftpd) && $(common_configure5) --disable-autoshadow --without-pic --disable-auth-pam  --disable-cap --disable-facl --disable-dso  --disable-trace)
	make -C $(proftpd)
	$(strip) $(proftpd)/proftpd -o $@

svc/bin/rsync: $(rsync)
	(cd $(rsync) && $(common_configure5))
	make -C $(rsync)
	$(strip) $(rsync)/rsync -o $@

lighty_flags=--with-pic= --without-pic --with-pcre=yes --with-openssl=yes PCRE_LIB=-lpcre SSL_LIB="-lssl -lcrypto"
# --without-zlib --without-bzip2
# no_build="mod_accesslog mod_compress mod_deflate mod_evhost mod_extforward mod_fastcgi mod_flv_streaming mod_proxy mod_rrdtool mod_secdownload mod_scgi mod_sockproxy mod_userdir mod_usertrack mod_vhostddb mod_wstunnel"

svc/bin/lighttpd: $(lighttpd)
	cp -f plugin-static.h $(lighttpd)/src
	(cd $(lighttpd) && LIGHTTPD_STATIC=yes CPPFLAGS=-DLIGHTTPD_STATIC $(common_configure5) $(lighty_flags))
	make -C $(lighttpd) lighttpd_LDFLAGS="-Wl,-gc-sections"
#LDFLAGS="-static" lighttpd_LDFLAGS="--static -Wl,-gc-sections"
	$(strip) $(lighttpd)/src/lighttpd -o $@

svc/bin/htop: $(htop)
	(cd $(htop) && $(common_configure5) ac_cv_lib_ncurses_refresh=yes LIBS=-lncurses HTOP_NCURSES_CONFIG_SCRIPT=/bin/false)
	make -C $(htop)
	$(strip) $(htop)/htop -o $@

svc/bin/nano: $(nano)
	(cd $(nano) && $(common_configure5) ac_cv_lib_ncurses_refresh=yes LIBS=-lncurses HTOP_NCURSES_CONFIG_SCRIPT=/bin/false)
	make -C $(nano)
	$(strip) $(nano)/src/nano -o $@

svc/bin/openvpn: $(openvpn)
	(cd $(openvpn) && $(common_configure5) --disable-plugin-auth-pam --disable-plugin-down-root)
	make -C $(openvpn)
	$(strip) $(openvpn)/src/openvpn/openvpn -o $@


svc/bin/powertop: $(powertop)
	(cd $(powertop) && $(common_configure5) NCURSES_CFLAGS=" " LIBNL_CFLAGS=" " LIBNL_LIBS="-lnl -lnl-genl" ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes)
	make -C $(powertop)
	$(strip) $(powertop)/src/powertop -o $@

svc/bin/lftp: $(lftp)
	(cd $(lftp) && LIBS=-lz $(common_configure5) ac_cv_func_fallocate=no --without-zlib zlib_cv_libz=yes zlib_cv_zlib_h=yes ac_cv_header_zlib_h=yes ac_cv_lib_z_inflateEnd=yes)
	make -C $(lftp)
	$(strip) $(lftp)/src/lftp -o $@

svc/bin/sftp-server: $(openssh)
	(cd $(openssh) && $(common_configure5))
	make -C $(openssh) sftp-server
	$(strip) $(openssh)/sftp-server -o svc/bin/sftp-server

FORCE:



