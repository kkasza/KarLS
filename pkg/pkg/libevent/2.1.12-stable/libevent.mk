LIBEVENT_VER_CUR:=2.1.12-stable
LIBEVENT_VER:=libevent-$(LIBEVENT_VER_CUR)
$(LIBEVENT_VER)-URL:=https://github.com/libevent/libevent/releases/download/release-2.1.12-stable
$(LIBEVENT_VER)-FILE:=$(LIBEVENT_VER).tar.gz
$(LIBEVENT_VER)-SHA256:=92e6de1be9ec176428fd2367677e61ceffc2ee1cb119035037a27d346b0403bb

SRC_LIST+=LIBEVENT
PKG_LIST+=libevent

LIBEVENT_OPTS:=--host=$(TARGET-ARCH) \
--prefix=$(CMPL_INST) \
--enable-static=no \
--with-sysroot=$(CMPL_INST) \
$(XCCACHE) \
$(HCCACHE)

#ifeq ($(T),arm)
#LIBEVENT_ARCH:="LDFLAGS=-L$(CMPL_INST)/$(TARGET-ARCH)/lib -Wl,-rpath-link=$(CMPL_INST)/$(TARGET-ARCH)/lib"
#endif

libevent: $(BLD)/$(LIBEVENT_VER)-$(T).kp

$(BLD)/$(LIBEVENT_VER): | src/$(LIBEVENT_VER) openssl
	$(call pkg_set_stat,"configure $@")
	mkdir -p $@/_kp_tmp/FILES/usr/lib $(BLD)/xpc
	cd $@; $(XPATH) $(XPCF) ../../src/$(LIBEVENT_VER)/configure $(LIBEVENT_OPTS) $(LIBEVENT_ARCH)
	$(call pkg_set_stat,"compile $@")
	$(XPATH) $(MAKE) -C $@ V=1
	$(call pkg_set_stat,"package $@")
	cp -rP src/$(LIBEVENT_VER)/include/event2 $@/include/* $(CMPL_INST)/include
	$(STRIP) $@/.libs/*.so*
	cp -P $@/.libs/*.so* $(CMPL_INST)/lib
	cp $@/*.pc $(BLD)/xpc
	cp -P $@/.libs/*.so* $@/_kp_tmp/FILES/usr/lib
	echo "openssl" > $@/_kp_tmp/PREREQ
	echo "$(LIBEVENT_VER) : The libevent API library" > $@/_kp_tmp/DESC
