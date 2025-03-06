TMUX_VER_CUR:=3.5a
TMUX_VER:=tmux-$(TMUX_VER_CUR)
$(TMUX_VER)-URL:=https://github.com/tmux/tmux/releases/download/$(TMUX_VER_CUR)/
$(TMUX_VER)-FILE:=$(TMUX_VER).tar.gz
$(TMUX_VER)-SHA256:=16216bd0877170dfcc64157085ba9013610b12b082548c7c9542cc0103198951

SRC_LIST+=TMUX
PKG_LIST+=tmux

TMUX_OPTS:=--host=$(TARGET-ARCH) \
--disable-systemd \
--disable-static \
$(XCCACHE) \
$(HCCACHE)
#AR=$(CMPL_INST)/bin/$(TARGET-ARCH)-ar \
#RANLIB=$(CMPL_INST)/bin/$(TARGET-ARCH)-ranlib

tmux: $(BLD)/$(TMUX_VER)-$(T).kp

$(BLD)/$(TMUX_VER): | src/$(TMUX_VER) libevent ncurses
	$(call pkg_set_stat,"configure $@")
	mkdir -p $@/_kp_tmp/FILES/usr/bin
	cd $@; $(XPATH) $(XPCF) ../../src/$(TMUX_VER)/configure $(TMUX_OPTS)
	$(call pkg_set_stat,"compile $@")
	$(XPATH) $(MAKE) -C $@ V=1
	$(call pkg_set_stat,"package $@")
	$(STRIP) $@/tmux
	cp $@/tmux $@/_kp_tmp/FILES/usr/bin
	echo "busybox" > $@/_kp_tmp/PREREQ
	echo "libevent" >> $@/_kp_tmp/PREREQ
	echo "ncurses" >> $@/_kp_tmp/PREREQ
	echo "$(TMUX_VER) : tmux is a terminal multiplexer." > $@/_kp_tmp/DESC
