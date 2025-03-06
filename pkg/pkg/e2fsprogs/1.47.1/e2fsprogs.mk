E2FSPROGS_VER_CUR:=1.47.1
E2FSPROGS_VER:=e2fsprogs-$(E2FSPROGS_VER_CUR)
$(E2FSPROGS_VER)-URL:=https://mirrors.edge.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.47.1
$(E2FSPROGS_VER)-FILE:=$(E2FSPROGS_VER).tar.xz
$(E2FSPROGS_VER)-SHA256:=5a33dc047fd47284bca4bb10c13cfe7896377ae3d01cb81a05d406025d99e0d1

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

e2fsprogs: $(BLD)/$(E2FSPROGS_VER)-$(T).kp

$(BLD)/$(E2FSPROGS_VER): src/$(E2FSPROGS_VER)
	$(call pkg_set_stat,"configure $@")
	mkdir -p $@
	cd $@; $(XPATH) $(XPCF) ../../src/$(E2FSPROGS_VER)/configure $(E2FSPROGS_OPTS)
	$(call pkg_set_stat,"compile $@")
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1
	$(call pkg_set_stat,"package $@")
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1 DESTDIR=`pwd`/$@/_kp_tmp/FILES install
	rm -rf $@/_kp_tmp/FILES/etc/cron.d $@/_kp_tmp/FILES/lib $@/_kp_tmp/FILES/usr/lib/e2fsprogs $@/_kp_tmp/FILES/usr/share
	$(STRIP) $@/_kp_tmp/FILES/usr/bin/* $@/_kp_tmp/FILES/usr/sbin/* $@/_kp_tmp/FILES/usr/lib/e2initrd_helper || true
	cp -r pkg/e2fsprogs/$(E2FSPROGS_VER_CUR)/skel/* $@/_kp_tmp/FILES
	echo "$(E2FSPROGS_VER) : e2fsprogs provides the filesystem utilities for use with the ext2 filesystem. It also supports the ext3 and ext4 filesystems." > $@/_kp_tmp/DESC
	echo "busybox" > $@/_kp_tmp/PREREQ
