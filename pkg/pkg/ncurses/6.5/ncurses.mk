NCURSES_VER_CUR:=6.5
NCURSES_VER:=ncurses-$(NCURSES_VER_CUR)
$(NCURSES_VER)-URL:=https://invisible-island.net/archives/ncurses/
$(NCURSES_VER)-FILE:=$(NCURSES_VER).tar.gz
$(NCURSES_VER)-SHA256:=136d91bc269a9a5785e5f9e980bc76ab57428f604ce3e5a5a90cebc767971cc6

SRC_LIST+=NCURSES
PKG_LIST+=ncurses

NCURSES_OPTS:=--host=$(TARGET-ARCH) \
--with-sysroot=$(CMPL_INST) \
--with-shared \
--with-termlib \
--enable-pc-files \
--without-manpages \
--disable-widec \
$(XCCACHE) \
$(HCCACHE)

#ifeq ($(T),arm)
#NCURSES_ARCH:="LDFLAGS=-L$(CMPL_INST)/$(TARGET-ARCH)/lib -Wl,-rpath-link=$(CMPL_INST)/$(TARGET-ARCH)/lib"
#endif

ncurses: $(BLD)/$(NCURSES_VER)-$(T).kp

$(BLD)/$(NCURSES_VER): src/$(NCURSES_VER)
	mkdir -p $@/_kp_tmp/FILES/usr/lib $(BLD)/xpc
	cd $@; $(XPATH) $(XPCF) ../../src/$(NCURSES_VER)/configure $(NCURSES_OPTS) $(NCURSES_ARCH)
	$(XPATH) $(MAKE) -C $@ V=1
	cp -rP src/$(NCURSES_VER)/include/ $@/include/* $(CMPL_INST)/include
	ln -s curses.h $(CMPL_INST)/include/ncurses.h
	$(STRIP) $@/lib/*.so*
	cp -P $@/lib/*.so* $(CMPL_INST)/lib
	cp $@/misc/*.pc $(BLD)/xpc
	cp -P $@/lib/*.so* $@/_kp_tmp/FILES/usr/lib
	echo "$(NCURSES_VER) : a freely distributable clone of System V Release 4.0 (SVr4) curses" > $@/_kp_tmp/DESC
