GLIB_VER_CUR:=2.83.3
GLIB_VER:=glib-$(GLIB_VER_CUR)
$(GLIB_VER)-URL:=https://download.gnome.org/sources/glib/2.83
$(GLIB_VER)-FILE:=$(GLIB_VER).tar.xz
$(GLIB_VER)-SHA256:=d0c65318bb2e3fa594277cf98a71cffaf5f666c078db39dcec121757b2ba328d

SRC_LIST+=GLIB
PKG_LIST+=glib

GLIB_OPTS:=--prefix=$(CMPL_INST) \
--buildtype=release \
-D introspection=disabled \
-D glib_debug=disabled \
-D man-pages=disabled \
-D sysprof=disabled

glib: $(BLD)/$(GLIB_VER)-$(T).kp

$(BLD)/$(GLIB_VER): src/$(GLIB_VER)
	mkdir -p $@/_kp_tmp/FILES/usr/bin $(BLD)/xpc
	cp pkg/glib/$(GLIB_VER_CUR)/glib-cross.txt $@
	cd $@; $(XPATH) $(XPCF) meson setup --cross-file glib-cross.txt  ../../src/$(GLIB_VER) $(GLIB_OPTS)
#	cd $@; $(XPATH) $(XPCF) ../../src/$(GLIB_VER)/configure $(GLIB_OPTS)
#	$(XPATH) $(MAKE) -C $@ V=1
#	cp -rP src/$(LIBNL_VER)/include/netlink $(CMPL_INST)/include/
#	$(STRIP) $@/lib/.libs/*.so*
#	cp -P $@/lib/.libs/*.so* $(CMPL_INST)/lib
#	cp $@/*.pc $(BLD)/xpc
#	cp -P $@/lib/.libs/*.so* $@/_kp_tmp/FILES/usr/lib
#	echo "$(LIBNL_VER) : Netlink Protocol Library Suite" > $@/_kp_tmp/DESC
