BUSYBOX_VER:=busybox-1.36.1
$(BUSYBOX_VER)-URL:=https://busybox.net/downloads
$(BUSYBOX_VER)-FILE:=$(BUSYBOX_VER).tar.bz2
$(BUSYBOX_VER)-SHA256:=b8cc24c9574d809e7279c3be349795c5d5ceb6fdf19ca709f80cde50e47de314

SRC_LIST+=BUSYBOX
PKG_LIST+=busybox

busybox: $(BLD)/$(BUSYBOX_VER).txz

$(BLD)/$(BUSYBOX_VER): src/$(BUSYBOX_VER)
	mkdir -p $(BLD)
	cp -rP src/$(BUSYBOX_VER) $@
	cp pkg/$(BUSYBOX_VER).config $@/.config
	sed -i 's/^CONFIG_CROSS_COMPILER_PREFIX=\"\"/CONFIG_CROSS_COMPILER_PREFIX=\"$(subst /,\/,${CMPL_INST})\/bin\/$(subst /,\/,$(TARGET-ARCH))-\"/' $@/.config
	sed -i 's/^CONFIG_SYSROOT=\"\"/CONFIG_SYSROOT=\"$(subst /,\/,$(CMPL_INST))\"/' $@/.config
	sed -i 's/^CONFIG_UNAME_OSNAME=\"GNU\/Linux\"/CONFIG_UNAME_OSNAME=\"$(subst /,\/,$(NAME))\"/' $@/.config
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1

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

$(BLD)/$(BUSYBOX_VER).txz: $(BLD)/$(BUSYBOX_VER)
	mkdir -p $</_txz_tmp/bin $</_txz_tmp/usr/udhcpc
	cp $</busybox $</_txz_tmp/bin
	cp $</examples/udhcp/simple.script $</_txz_tmp/usr/udhcpc/default.script
	ln -s /bin/busybox $</_txz_tmp/bin/init
	ln -s /bin/busybox $</_txz_tmp/bin/sh
	echo "#!/bin/sh" > $</_txz_tmp/INSTALL
	echo "#KarLS INSTALL script for $(BUSYVOX_VER)" > $</_txz_tmp/INSTALL
	echo "/bin/busybox --install -s /bin" >> $</_txz_tmp/INSTALL
	tar -C $</_txz_tmp -cJv -f $@ --owner=0 --group=0 .
