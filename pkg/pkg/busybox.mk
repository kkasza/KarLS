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
	cp pkg/$(BUSYBOX_VER).config $@/.config
	sed -i 's/^CONFIG_CROSS_COMPILER_PREFIX=\"\"/CONFIG_CROSS_COMPILER_PREFIX=\"$(subst /,\/,${CMPL_INST})\/bin\/$(subst /,\/,$(TARGET-ARCH))-\"/' $@/.config
	sed -i 's/^CONFIG_SYSROOT=\"\"/CONFIG_SYSROOT=\"$(subst /,\/,$(CMPL_INST))\"/' $@/.config
	sed -i 's/^CONFIG_UNAME_OSNAME=\"GNU\/Linux\"/CONFIG_UNAME_OSNAME=\"$(subst /,\/,$(NAME))\"/' $@/.config
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1
	mkdir -p $@/_kp_tmp/bin $@/_kp_tmp/usr/udhcpc
	cp $@/busybox $@/_kp_tmp/bin
	cp $@/examples/udhcp/simple.script $@/_kp_tmp/usr/udhcpc/default.script
	ln -s /bin/busybox $@/_kp_tmp/bin/init
	ln -s /bin/busybox $@/_kp_tmp/bin/sh
	echo "#!/bin/sh" > $@/_kp_tmp/INSTALL
	echo "#KarLS INSTALL script for $(BUSYBOX_VER)" >> $@/_kp_tmp/INSTALL
	echo "/bin/busybox --install -s \$$1/bin" >> $@/_kp_tmp/INSTALL

busybox-config: $(BLD)/$(BUSYBOX_VER)-bconfig

$(BLD)/$(BUSYBOX_VER)-bconfig: src/$(BUSYBOX_VER)
	mkdir -p $(BLD)
	cp -rP src/$(BUSYBOX_VER) $@
	cp pkg/$(BUSYBOX_VER).config $@/.config
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1 menuconfig
	cp $@/.config pkg/$(BUSYBOX_VER).config.new
	diff -q pkg/$(BUSYBOX_VER).config pkg/$(BUSYBOX_VER).config.new && \
	rm -f pkg/$(BUSYBOX_VER).config.new || diff -u pkg/$(BUSYBOX_VER).config pkg/$(BUSYBOX_VER).config.new > pkg/$(BUSYBOX_VER).config.diff || true
	touch $<

$(BLD)/$(BUSYBOX_VER).kp: $(BLD)/$(BUSYBOX_VER)
	tar -C $</_kp_tmp -cJv -f $@ --owner=0 --group=0 .
