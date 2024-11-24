BUSYBOX_VER_CUR:=1.36.1
BUSYBOX_VER:=busybox-$(BUSYBOX_VER_CUR)
$(BUSYBOX_VER)-URL:=https://busybox.net/downloads
$(BUSYBOX_VER)-FILE:=$(BUSYBOX_VER).tar.bz2
$(BUSYBOX_VER)-SHA256:=b8cc24c9574d809e7279c3be349795c5d5ceb6fdf19ca709f80cde50e47de314

SRC_LIST+=BUSYBOX
PKG_LIST+=busybox busybox-static

busybox: $(BLD)/$(BUSYBOX_VER)-$(T).kp

busybox-static: $(BLD)/$(BUSYBOX_VER)-static

$(BLD)/$(BUSYBOX_VER): src/$(BUSYBOX_VER)
	mkdir -p $(BLD)
	cp -rP src/$(BUSYBOX_VER) $@
	cp pkg/busybox/$(BUSYBOX_VER_CUR)/$(BUSYBOX_VER).config $@/.config
	sed -i 's/^CONFIG_CROSS_COMPILER_PREFIX=\"\"/CONFIG_CROSS_COMPILER_PREFIX=\"$(subst /,\/,${CMPL_INST})\/bin\/$(subst /,\/,$(TARGET-ARCH))-\"/' $@/.config
	sed -i 's/^CONFIG_SYSROOT=\"\"/CONFIG_SYSROOT=\"$(subst /,\/,$(CMPL_INST))\"/' $@/.config
	sed -i 's/^CONFIG_UNAME_OSNAME=\"GNU\/Linux\"/CONFIG_UNAME_OSNAME=\"$(subst /,\/,$(NAME))\"/' $@/.config
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1 CONFIG_PREFIX=`pwd`/$@/_kp_tmp/FILES install
	mkdir -p $@/_kp_tmp/FILES/usr/udhcpc
	cp $@/examples/udhcp/simple.script $@/_kp_tmp/FILES/usr/udhcpc/default.script
	cp -r pkg/busybox/$(BUSYBOX_VER_CUR)/skel/* $@/_kp_tmp/FILES
	echo "$(BUSYBOX_VER) : BusyBox is a software suite that provides several Unix utilities in a single executable file." > $@/_kp_tmp/DESC
	echo "musl" > $@/_kp_tmp/PREREQ
	cp pkg/busybox/$(BUSYBOX_VER_CUR)/INSTALL $@/_kp_tmp
	touch $@/_kp_tmp/ESSENTIAL

$(BLD)/$(BUSYBOX_VER)-static: src/$(BUSYBOX_VER)
	mkdir -p $(BLD)
	cp -rP src/$(BUSYBOX_VER) $@
	cp pkg/busybox/$(BUSYBOX_VER_CUR)/$(BUSYBOX_VER).config $@/.config
	sed -i 's/^CONFIG_CROSS_COMPILER_PREFIX=\"\"/CONFIG_CROSS_COMPILER_PREFIX=\"$(subst /,\/,${CMPL_INST})\/bin\/$(subst /,\/,$(TARGET-ARCH))-\"/' $@/.config
	sed -i 's/^CONFIG_SYSROOT=\"\"/CONFIG_SYSROOT=\"$(subst /,\/,$(CMPL_INST))\"/' $@/.config
	sed -i 's/^CONFIG_UNAME_OSNAME=\"GNU\/Linux\"/CONFIG_UNAME_OSNAME=\"$(subst /,\/,$(NAME))\"/' $@/.config
	sed -i 's/^CONFIG_PIE=y/# CONFIG_PIE is not set/' $@/.config
	sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/' $@/.config
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1
	ln -s $(BUSYBOX_VER)-static $(BLD)/busybox-static

busybox-config: $(BLD)/$(BUSYBOX_VER)-config

$(BLD)/$(BUSYBOX_VER)-config: src/$(BUSYBOX_VER)
	mkdir -p $(BLD)
	cp -rP src/$(BUSYBOX_VER) $@
	cp pkg/busybox/$(BUSYBOX_VER_CUR)/$(BUSYBOX_VER).config $@/.config
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1 menuconfig
	cp $@/.config pkg/busybox/$(BUSYBOX_VER_CUR)/$(BUSYBOX_VER).config.new
	diff -q pkg/busybox/$(BUSYBOX_VER_CUR)/$(BUSYBOX_VER).config pkg/busybox/$(BUSYBOX_VER_CUR)/$(BUSYBOX_VER).config.new && \
	rm -f pkg/busybox/$(BUSYBOX_VER_CUR)/$(BUSYBOX_VER).config.new || diff -u pkg/busybox/$(BUSYBOX_VER_CUR)/$(BUSYBOX_VER).config pkg/busybox/$(BUSYBOX_VER_CUR)/$(BUSYBOX_VER).config.new > pkg/busybox/$(BUSYBOX_VER_CUR)/$(BUSYBOX_VER).config.diff || true
	touch $<
