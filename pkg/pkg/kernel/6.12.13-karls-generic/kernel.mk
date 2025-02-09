KERNEL_SVER:=6.12.13
KVER:=$(NAME)-$(KFLAV)
KERNEL_VER_CUR:=$(KERNEL_SVER)-$(KVER)
KERNEL_VER:=kernel-$(KERNEL_VER_CUR)
$(KERNEL_VER)-REALDIR:=linux-$(KERNEL_SVER)
$(KERNEL_VER)-URL:=https://cdn.kernel.org/pub/linux/kernel/v6.x
$(KERNEL_VER)-REALFILE:=linux-$(KERNEL_SVER).tar.xz
$(KERNEL_VER)-FILE:=$(KERNEL_VER).tar.xz
$(KERNEL_VER)-SHA256:=f3ebdeea9e555b4cface44e29670056f4024541e6bd222fbcf776c818974fbba

SRC_LIST+=KERNEL
PKG_LIST+=kernel

KERNEL_PLH:=__karls__

#Build Number for kernel (after #)
BNF:=pkg/kernel/$(KERNEL_VER_CUR)/buildno-$(T)-$(KFLAV)
BN:=$$(( $(shell cat $(BNF))+1 ))

KBUILD:=$($(KERNEL_VER)-REALDIR)-$(T)-$(KFLAV)

kernel: $(BLD)/$(KERNEL_VER)-$(T).kp

krnl:
	@echo $(KERNEL_VER)
	@echo $($(KERNEL_VER)-URL)
	@echo $($(KERNEL_VER)-FILE)

#src/$(KERNEL_VER):
#	mkdir -p src
#	ln -s $(CMPL)/src/$($(KERNEL_VER)-REALDIR) $@

.PHONY: $(BLD)/$(KERNEL_VER)-kconfig

kernel-config: $(BLD)/$(KERNEL_VER)-kconfig

$(BLD)/$(KERNEL_VER)-kconfig: src/$(KERNEL_VER)
	$(MAKE) -C $< V=1 O=$(PWD)/$@ $(HCCACHE) $(XCCACHE) ARCH=$(T) allnoconfig
	cp pkg/kernel/$(KERNEL_VER_CUR)/$(KBUILD).config $@/.config
	$(MAKE) -C $@ V=1 O=$(PWD)/$@ $(HCCACHE) $(XCCACHE) ARCH=$(T) menuconfig
	cp $@/.config pkg/kernel/$(KERNEL_VER_CUR)/$(KBUILD).config.new
	diff -q pkg/kernel/$(KERNEL_VER_CUR)/$(KBUILD).config pkg/kernel/$(KERNEL_VER_CUR)/$(KBUILD).config.new && rm -f pkg/kernel/$(KERNEL_VER_CUR)/$(KBUILD).config.new || diff -u pkg/kernel/$(KERNEL_VER_CUR)/$(KBUILD).config pkg/kernel/$(KERNEL_VER_CUR)/$(KBUILD).config.new > pkg/kernel/$(KERNEL_VER_CUR)/$(KBUILD).config.diff || true

$(BLD)/$(KERNEL_VER): src/$(KERNEL_VER)
#prepare
	$(MAKE) -C $< V=1 O=$(PWD)/$@ $(HCCACHE) $(XCCACHE) ARCH=$(T) allnoconfig
	cp pkg/kernel/$(KERNEL_VER_CUR)/$(KBUILD).config $@/.config
	sed -i 's/^CONFIG_LOCALVERSION=\"$(KERNEL_PLH)\"/CONFIG_LOCALVERSION=\"-$(KVER)\"/' $@/.config
	$(MAKE) -C $< V=1 O=$(PWD)/$@ $(HCCACHE) $(XCCACHE) LD="$(CMPL_INST)/bin/ld" ARCH=$(T) prepare
	cp $(BNF) $@/.version
#make image file
	$(MAKE) -C $@ V=1 $(HCCACHE) $(XCCACHE) LD="$(CMPL_INST)/bin/ld" ARCH=$(T) CROSS_COMPILE="$(CMPL_INST)/bin/$(TARGET-ARCH)-" bzImage
	echo $(BN) > $(BNF)
#make modules
	$(MAKE) -C $@ V=1 $(HCCACHE) $(XCCACHE) LD="$(CMPL_INST)/bin/ld" ARCH=$(T) CROSS_COMPILE="$(CMPL_INST)/bin/$(TARGET-ARCH)-" modules
	$(MAKE) -C $@ INSTALL_MOD_PATH=modules INSTALL_MOD_STRIP=1 V=1 $(HCCACHE) $(XCCACHE) LD="$(CMPL_INST)/bin/ld" ARCH=$(T) modules_install
#copy files for package
	mkdir -p $@/_kp_tmp/FILES/boot

	cp -L $@/arch/$(TARGET-CPU)/boot/bzImage $@/_kp_tmp/FILES/boot/vmlinuz-$(KERNEL_SVER)-$(KVER)
	chmod 644 $@/_kp_tmp/FILES/boot/vmlinuz-$(KERNEL_SVER)-$(KVER)
	cp $@/System.map $@/_kp_tmp/FILES/boot/System.map-$(KERNEL_SVER)-$(KVER)
	cp -r $@/modules/* $@/_kp_tmp/FILES
	rm -f $@/_kp_tmp/FILES/lib/modules/$(KERNEL_SVER)-$(KVER)/build $@/_kp_tmp/FILES/lib/modules/$(KERNEL_SVER)-$(KVER)/source
	echo "$(KERNEL_VER) : The LINUX Kernel" > $@/_kp_tmp/DESC
	touch $@/_kp_tmp/ESSENTIAL

	ln -s $(KERNEL_VER) $(BLD)/kernel
	echo $(KERNEL_SVER)-$(KVER) > $@/kernel_version
