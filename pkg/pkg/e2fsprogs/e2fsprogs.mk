E2FSPROGS_VER:=e2fsprogs-1.47.0
$(E2FSPROGS_VER)-URL:=https://mirrors.edge.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.47.0
$(E2FSPROGS_VER)-FILE:=$(E2FSPROGS_VER).tar.xz
$(E2FSPROGS_VER)-SHA256:=144af53f2bbd921cef6f8bea88bb9faddca865da3fbc657cc9b4d2001097d5db

SRC_LIST+=E2FSPROGS
PKG_LIST+=e2fsprogs

E2FSPROGS_OPTS:= \
--bindir=/usr/bin \
--libdir=/usr/lib \
--runstatedir=/run \
--sbindir=/usr/sbin \
--host=$(TARGET-ARCH) \
$(XCCACHE) \
$(HCCACHE)

e2fsprogs: $(BLD)/$(E2FSPROGS_VER).kp

$(BLD)/$(E2FSPROGS_VER): src/$(E2FSPROGS_VER)
	mkdir -p $@
	cd $@; $(XPATH) $(XPCF) ../../src/$(E2FSPROGS_VER)/configure $(E2FSPROGS_OPTS)
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1 DESTDIR=`pwd`/$@/_kp_tmp/FILES install
	rm -rf $@/_kp_tmp/FILES/etc/cron.d $@/_kp_tmp/FILES/lib $@/_kp_tmp/FILES/usr/lib/e2fsprogs $@/_kp_tmp/FILES/usr/share
	$(STRIP) $@/_kp_tmp/FILES/usr/bin/* $@/_kp_tmp/FILES/usr/sbin/* $@/_kp_tmp/FILES/usr/lib/e2initrd_helper || true
	cp -r pkg/e2fsprogs/skel/* $@/_kp_tmp/FILES
	echo "$(E2FSPROGS_VER) : e2fsprogs provides the filesystem utilities for use with the ext2 filesystem. It also supports the ext3 and ext4 filesystems." > $@/_kp_tmp/DESC
	echo "busybox" > $@/_kp_tmp/PREREQ
