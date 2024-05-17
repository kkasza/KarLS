UTIL_LINUX_VER:=util_linux-2.40
$(UTIL_LINUX_VER)-URL:=https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.40
$(UTIL_LINUX_VER)-FILE:=$(UTIL_LINUX_VER).tar.xz
$(UTIL_LINUX_VER)-REALDIR:=util-linux-2.40
$(UTIL_LINUX_VER)-REALFILE:=$($(UTIL_LINUX_VER)-REALDIR).tar.xz
$(UTIL_LINUX_VER)-SHA256:=d57a626081f9ead02fa44c63a6af162ec19c58f53e993f206ab7c3a6641c2cd7

SRC_LIST+=UTIL_LINUX
PKG_LIST+=util_linux

UTIL_LINUX_OPTS:= \
--bindir=/usr/bin \
--libdir=/usr/lib \
--runstatedir=/run \
--sbindir=/usr/sbin \
--disable-chfn-chsh \
--disable-login \
--disable-nologin \
--disable-su \
--disable-sulogin \
--disable-kill \
--disable-last \
--disable-mesg \
--disable-dmesg \
--disable-setpriv \
--disable-runuser \
--disable-pylibmount \
--disable-liblastlog2 \
--disable-static \
--without-python \
--without-tinfo \
--disable-mount \
--disable-libmount \
--disable-wall \
--disable-bfs \
--disable-minix \
--host=$(TARGET-ARCH) \
$(XCCACHE) \
$(HCCACHE)

util_linux: $(BLD)/$(UTIL_LINUX_VER)-$(T).kp

$(BLD)/$(UTIL_LINUX_VER): src/$(UTIL_LINUX_VER)
	mkdir -p $@
	cd $@; $(XPATH) $(XPCF) ../../src/$(UTIL_LINUX_VER)/configure $(UTIL_LINUX_OPTS)
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1 DESTDIR=`pwd`/$@/_kp_tmp/FILES install
	rm -rf $@/_kp_tmp/FILES/usr/share
	$(STRIP) $@/_kp_tmp/FILES/usr/bin/* $@/_kp_tmp/FILES/usr/sbin/* $@/_kp_tmp/FILES/usr/lib/* || true
	echo "$(UTIL_LINUX_VER) : util-linux is a random collection of Linux utilities" > $@/_kp_tmp/DESC
	echo "busybox" > $@/_kp_tmp/PREREQ
