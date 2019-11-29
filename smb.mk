VER=3.6.25
DIR=samba-$(VER)
$(DIR):
	wget -c https://download.samba.org/pub/samba/stable/samba-$(VER).tar.gz
	tar -xvzf samba-$(VER).tar.gz
	cd $(DIR) && for p in ../samba-patches/*; do patch -p1 < $$p || exit 1; done
CONFIGURE_VARS=\
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
CONFIGURE_ARGS=\
	--exec-prefix=/mnt/secure \
	--prefix=/ \
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
	--with-libiconv="$(ICONV_PREFIX)" \
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


#default_static_modules="$default_static_modules pdb_smbpasswd"
#default_static_modules="$default_static_modules pdb_tdbsam"
#default_static_modules="$default_static_modules pdb_wbc_sam"
#default_static_modules="$default_static_modules rpc_lsarpc"
#default_static_modules="$default_static_modules rpc_samr"
#default_static_modules="$default_static_modules rpc_winreg"
#default_static_modules="$default_static_modules rpc_initshutdown"
#default_static_modules="$default_static_modules rpc_dssetup"
#default_static_modules="$default_static_modules rpc_wkssvc"
#default_static_modules="$default_static_modules rpc_svcctl"
#default_static_modules="$default_static_modules rpc_ntsvcs"
#default_static_modules="$default_static_modules rpc_netlogon"
#default_static_modules="$default_static_modules rpc_netdfs"
#default_static_modules="$default_static_modules rpc_srvsvc"
#default_static_modules="$default_static_modules rpc_spoolss"
#default_static_modules="$default_static_modules rpc_eventlog"
#default_static_modules="$default_static_modules auth_sam"
#default_static_modules="$default_static_modules auth_unix"
#default_static_modules="$default_static_modules auth_winbind"
#default_static_modules="$default_static_modules auth_wbc"
#default_static_modules="$default_static_modules auth_server"
#default_static_modules="$default_static_modules auth_domain"
#default_static_modules="$default_static_modules auth_builtin"
#default_static_modules="$default_static_modules vfs_default"
#default_static_modules="$default_static_modules nss_info_template"

smbd: $(DIR)
	#cd $(DIR)/source3 && ./configure $(CONFIGURE_VARS) $(CONFIGURE_ARGS) CC=arm-buildroot-linux-musleabihf-gcc --host=arm-linux-gnueabi && make CC=arm-buildroot-linux-musleabihf-gcc LDFLAGS="-static -Lbin -Wl,--gc-sections" CFLAGS="-ffunction-sections -fdata-sections" bin/smbd
	#good2
	#cd $(DIR)/source3 && ./configure $(CONFIGURE_VARS) $(CONFIGURE_ARGS) --host=arm-linux-gnueabi --target=arm-linux-gnueabi CC=arm-buildroot-linux-musleabihf-gcc-gcc CC=arm-buildroot-linux-musleabihf-gcc
	#cd $(DIR)/source3 && make MODULES= PICFLAG= DYNEXP=

	#cd $(DIR)/source3 && ./configure $(CONFIGURE_VARS) $(CONFIGURE_ARGS) --host=arm-linux-gnueabi --target=arm-linux-gnueabi LDFLAGS="-static" CC=arm-buildroot-linux-musleabihf-gcc-gcc CC=arm-buildroot-linux-musleabihf-gcc && make MODULES= PICFLAG= DYNEXP=
	cd $(DIR)/source3 && ./configure $(CONFIGURE_VARS) $(CONFIGURE_ARGS) --host=arm-linux-gnueabi --target=arm-linux-gnueabi CFLAGS="-ffunction-sections -fdata-sections -DMAX_DEBUG_LEVEL=2" LDFLAGS="-static -Wl,--gc-sections" CC=arm-buildroot-linux-musleabihf-gcc-gcc CC=arm-buildroot-linux-musleabihf-gcc && make MODULES= PICFLAG= DYNEXP=



