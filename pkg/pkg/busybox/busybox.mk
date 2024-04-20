BUSYBOX_VER:=busybox-1.36.1
$(BUSYBOX_VER)-URL:=https://busybox.net/downloads
$(BUSYBOX_VER)-FILE:=$(BUSYBOX_VER).tar.bz2
$(BUSYBOX_VER)-SHA256:=b8cc24c9574d809e7279c3be349795c5d5ceb6fdf19ca709f80cde50e47de314

SRC_LIST+=BUSYBOX
PKG_LIST+=busybox

busybox: $(BLD)/$(BUSYBOX_VER).kp

$(BLD)/$(BUSYBOX_VER): src/$(BUSYBOX_VER)
	mkdir -p $(BLD)
	cp -rP src/$(BUSYBOX_VER) $@
	cp pkg/busybox/$(BUSYBOX_VER).config $@/.config
	sed -i 's/^CONFIG_CROSS_COMPILER_PREFIX=\"\"/CONFIG_CROSS_COMPILER_PREFIX=\"$(subst /,\/,${CMPL_INST})\/bin\/$(subst /,\/,$(TARGET-ARCH))-\"/' $@/.config
	sed -i 's/^CONFIG_SYSROOT=\"\"/CONFIG_SYSROOT=\"$(subst /,\/,$(CMPL_INST))\"/' $@/.config
	sed -i 's/^CONFIG_UNAME_OSNAME=\"GNU\/Linux\"/CONFIG_UNAME_OSNAME=\"$(subst /,\/,$(NAME))\"/' $@/.config
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1 CONFIG_PREFIX=`pwd`/$@/_kp_tmp/FILES install
	mkdir -p $@/_kp_tmp/FILES/usr/udhcpc
	cp $@/examples/udhcp/simple.script $@/_kp_tmp/FILES/usr/udhcpc/default.script
	echo "$(BUSYBOX_VER) : BusyBox is a software suite that provides several Unix utilities in a single executable file." > $@/_kp_tmp/DESC
	echo "musl-1.2.5" > $@/_kp_tmp/PREREQ
	touch $@/_kp_tmp/ESSENTIAL

#	NOTE: busybox may need setuid root...
#	echo "#!/bin/sh" > $@/_kp_tmp/INSTALL
#	echo "#KarLS INSTALL script for $(BUSYBOX_VER)" >> $@/_kp_tmp/INSTALL
#	echo "\$$1/bin/busybox --install -s \$$1/bin" >> $@/_kp_tmp/INSTALL

busybox-config: $(BLD)/$(BUSYBOX_VER)-bconfig

$(BLD)/$(BUSYBOX_VER)-bconfig: src/$(BUSYBOX_VER)
	mkdir -p $(BLD)
	cp -rP src/$(BUSYBOX_VER) $@
	cp pkg/busybox/$(BUSYBOX_VER).config $@/.config
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1 menuconfig
	cp $@/.config pkg/busybox/$(BUSYBOX_VER).config.new
	diff -q pkg/busybox/$(BUSYBOX_VER).config pkg/busybox/$(BUSYBOX_VER).config.new && \
	rm -f pkg/busybox/$(BUSYBOX_VER).config.new || diff -u pkg/busybox/$(BUSYBOX_VER).config pkg/busybox/$(BUSYBOX_VER).config.new > pkg/busybox/$(BUSYBOX_VER).config.diff || true
	touch $<
