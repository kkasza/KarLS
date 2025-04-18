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
--without-normal \
--with-termlib \
--with-ticlib \
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
	$(call pkg_set_stat,"configure $@")
	mkdir -p $@/_kp_tmp/FILES/usr/bin $@/_kp_tmp/FILES/usr/lib $@/_kp_tmp/FILES/usr/share/terminfo $(BLD)/xpc
	cd $@; $(XPATH) $(XPCF) ../../src/$(NCURSES_VER)/configure $(NCURSES_OPTS) $(NCURSES_ARCH)
	$(call pkg_set_stat,"compile $@")
	$(XPATH) $(MAKE) -C $@ V=1
	$(call pkg_set_stat,"package $@")
	cp -rP src/$(NCURSES_VER)/include/ $@/include/* $(CMPL_INST)/include
	ln -sf curses.h $(CMPL_INST)/include/ncurses.h
	$(STRIP) $@/lib/*.so*
	$(STRIP) $@/progs/clear $@/progs/infocmp $@/progs/tabs $@/progs/tic $@/progs/toe $@/progs/tput $@/progs/tset
	cp -P $@/lib/*.so* $(CMPL_INST)/lib
	cp $@/misc/*.pc $(BLD)/xpc
	cp -P $@/lib/*.so* $@/_kp_tmp/FILES/usr/lib
	cp -P $@/progs/clear $@/progs/infocmp $@/progs/tabs $@/_kp_tmp/FILES/usr/bin
	cp -P $@/progs/tic $@/progs/toe $@/progs/tput $@/progs/tset $@/_kp_tmp/FILES/usr/bin
	cp -P $^/misc/terminfo.src $@/_kp_tmp/FILES/usr/share/terminfo
	cp pkg/ncurses/$(NCURSES_VER_CUR)/INSTALL $@/_kp_tmp
	echo "busybox" > $@/_kp_tmp/PREREQ
	echo "$(NCURSES_VER) : a freely distributable clone of System V Release 4.0 (SVr4) curses" > $@/_kp_tmp/DESC
