LIBNL_VER_CUR:=3.11.0
LIBNL_VER:=libnl-$(LIBNL_VER_CUR)
$(LIBNL_VER)-URL:=https://github.com/thom311/libnl/releases/download/libnl3_11_0
$(LIBNL_VER)-FILE:=$(LIBNL_VER).tar.gz
$(LIBNL_VER)-SHA256:=2a56e1edefa3e68a7c00879496736fdbf62fc94ed3232c0baba127ecfa76874d

SRC_LIST+=LIBNL
PKG_LIST+=libnl

LIBNL_OPTS:=--host=$(TARGET-ARCH) \
--prefix=$(CMPL_INST) \
--with-sysroot=$(CMPL_INST) \
$(XCCACHE) \
$(HCCACHE)

libnl: $(BLD)/$(LIBNL_VER)-$(T).kp

$(BLD)/$(LIBNL_VER): src/$(LIBNL_VER)
	$(call pkg_set_stat,"configure $@")
	mkdir -p $@/_kp_tmp/FILES/usr/lib $(BLD)/xpc
	cd $@; $(XPATH) $(XPCF) ../../src/$(LIBNL_VER)/configure $(LIBNL_OPTS)
	$(call pkg_set_stat,"compile $@")
	$(XPATH) $(MAKE) -C $@ V=1
	$(call pkg_set_stat,"package $@")
	cp -rP src/$(LIBNL_VER)/include/netlink $(CMPL_INST)/include/
	$(STRIP) $@/lib/.libs/*.so*
	cp -P $@/lib/.libs/*.so* $(CMPL_INST)/lib
	cp $@/*.pc $(BLD)/xpc
	cp -P $@/lib/.libs/*.so* $@/_kp_tmp/FILES/usr/lib
	echo "$(LIBNL_VER) : Netlink Protocol Library Suite" > $@/_kp_tmp/DESC
