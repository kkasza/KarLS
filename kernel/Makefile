#KarLS
#Kernel - Linux LTS

include ../common.mk ./sources.mk

CMPL:=$(PWD)/../cmpl
CMPL_INST:=$(CMPL)/cmpl-$(T)

KERNEL_PLH:=__karls__

KVER:=$(NAME)_1.0-$(KFLAV)

#Build Number for kernel (after #)
BNF:=buildno-$(T)-$(KFLAV)
BN:=$$(( $(shell cat $(BNF))+1 ))
DBN:=$(info *** Kernel: Current build number is: #$(shell cat $(BNF)) *** )

KBUILD:=$(LINUX_VER)-$(T)-$(KFLAV)
IRFS:=irfs

ifdef DBG_NOCC
HCCACHE:=HOSTCC="gcc" HOSTCXX="g++"
XCCACHE:=CC="$(CMPL_INST)/bin/gcc" CXX="$(CMPL_INST)/bin/g++"
else
HCCACHE:=HOSTCC="ccache gcc" HOSTCXX="ccache g++"
XCCACHE:=CC="ccache $(CMPL_INST)/bin/gcc" CXX="ccache $(CMPL_INST)/bin/g++"
endif

.PHONY: $(BLD)/$(LINUX_VER)-kconfig $(BLD)/$(BUSY_VER)-bconfig

busybox: $(BLD)/$(BUSY_VER)

$(BLD)/$(BUSY_VER): src/$(BUSY_VER)
	mkdir -p $(BLD)
	cp -rP src/$(BUSY_VER) $@
	cp $(BUSY_VER).config $@/.config
	sed -i 's/^CONFIG_CROSS_COMPILER_PREFIX=\"\"/CONFIG_CROSS_COMPILER_PREFIX=\"$(subst /,\/,${CMPL_INST})\/bin\/$(subst /,\/,$(TARGET-ARCH))-\"/' $@/.config
	sed -i 's/^CONFIG_SYSROOT=\"\"/CONFIG_SYSROOT=\"$(subst /,\/,$(CMPL_INST))\"/' $@/.config
	sed -i 's/^CONFIG_UNAME_OSNAME=\"GNU\/Linux\"/CONFIG_UNAME_OSNAME=\"$(subst /,\/,$(NAME))\"/' $@/.config
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1

bconfig: $(BLD)/$(BUSY_VER)-bconfig

$(BLD)/$(BUSY_VER)-bconfig: src/$(BUSY_VER)
	mkdir -p $(BLD)
	cp -rP src/$(BUSY_VER) $@
	cp $(BUSY_VER).config $@/.config
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1 menuconfig
	cp $@/.config $(BUSY_VER).config.new
	diff -q $(BUSY_VER).config $(BUSY_VER).config.new && rm -f $(BUSY_VER).config.new || diff -u $(BUSY_VER).config $(BUSY_VER).config.new > $(BUSY_VER).config.diff || true
	touch $<

$(CMPL)/dl/$($(LINUX_VER)-FILE):
	make -C $(CMPL) dl/$($(LINUX_VER)-FILE)

dl/$($(LINUX_VER)-FILE): $(CMPL)/dl/$($(LINUX_VER)-FILE)
	mkdir -p dl
	ln -s $(CMPL)/dl/$($(LINUX_VER)-FILE) $@

$(CMPL)/src/$(LINUX_VER): dl/$($(LINUX_VER)-FILE)
	make -C $(CMPL) src/$(LINUX_VER)

src/$(LINUX_VER): $(CMPL)/src/$(LINUX_VER)
	mkdir -p src
	ln -s $(CMPL)/src/$(LINUX_VER) $@

kconfig: $(BLD)/$(LINUX_VER)-kconfig

$(BLD)/$(LINUX_VER)-kconfig: src/$(LINUX_VER)
	$(MAKE) -C src/$(LINUX_VER) V=1 O=$(PWD)/$@ $(HCCACHE) $(XCCACHE) ARCH=$(T) allnoconfig
	cp $(KBUILD).config $@/.config
	$(MAKE) -C $@ V=1 O=$(PWD)/$@ $(HCCACHE) $(XCCACHE) ARCH=$(T) menuconfig
	cp $@/.config $(KBUILD).config.new
	diff -q $(KBUILD).config $(KBUILD).config.new && rm -f $(KBUILD).config.new || diff -u $(KBUILD).config $(KBUILD).config.new > $(KBUILD).config.diff || true
	touch $<

irfs: $(BLD)/$(IRFS)

$(BLD)/$(IRFS): | busybox
	mkdir -p $@/proc $@/dev $@/tmp $@/sys $@/lib/modules $@/usr/udhcpc

	cp -rP skel/* $@/
	cp -rP skel-$(T)-$(KFLAV)/* $@/

	cp $(BLD)/$(BUSY_VER)/busybox $@/bin
	cp $(BLD)/$(BUSY_VER)/examples/udhcp/simple.script $@/usr/udhcpc/default.script

	$(SUDO) mknod -m 600 $@/dev/console c 5 1
	echo $(NICENAME) $(VERSION) $(VERSION_TAG) > $@/etc/version
	cp $(PWD)/../pkg/pkg/kpm $@/bin
	chmod 755 $@/bin/kpm

initrd: | $(BLD)/initrd-$(LINUX_SVER)-$(KVER).gz

$(BLD)/initrd-$(LINUX_SVER)-$(KVER).gz: | $(BLD)/$(IRFS) modules
	cp -r $(BLD)/$(KBUILD)/modules/* $(BLD)/irfs
	rm -f $(BLD)/irfs/lib/modules/*/build $(BLD)/irfs/lib/modules/*/source
	cd $(BLD)/irfs; find . | cpio -H newc -V -R 0:0 -o | gzip -9 -n > ../../$@

rebuild_initrd:
	rm -rf $(BLD)/$(IRFS) $(BLD)/initrd-$(LINUX_SVER)-$(KVER).gz
	make initrd
	cp $(BLD)/initrd-$(LINUX_SVER)-$(KVER).gz kernel-$(T)-$(KFLAV)/

$(BLD)/$(KBUILD): src/$(LINUX_VER)
	$(MAKE) -C src/$(LINUX_VER) V=1 O=$(PWD)/$@ $(HCCACHE) $(XCCACHE) ARCH=$(T) allnoconfig
	cp $(KBUILD).config $@/.config
#For RPI kernel source
#	sed -i 's/^CONFIG_CROSS_COMPILE=\"$(KERNEL_PLH)\"/CONFIG_CROSS_COMPILE=\"$(subst /,\/,${CMPL_INST})\/bin\/$(subst /,\/,$(TARGET-ARCH))-\"/' $@/.config
	sed -i 's/^CONFIG_LOCALVERSION=\"$(KERNEL_PLH)\"/CONFIG_LOCALVERSION=\"-$(KVER)\"/' $@/.config
#	sed -i 's/^CONFIG_INITRAMFS_SOURCE=\"$(KERNEL_PLH)\"/CONFIG_INITRAMFS_SOURCE=\"$(subst /,\/,$(PWD)/$(BLD)/$(IRFS))\"/' $@/.config
	$(MAKE) -C src/$(LINUX_VER) V=1 O=$(PWD)/$@ $(HCCACHE) $(XCCACHE) LD="$(CMPL_INST)/bin/ld" ARCH=$(T) prepare

modules: | $(BLD)/$(KBUILD)/modules

$(BLD)/$(KBUILD)/modules: | kernelimage
	$(MAKE) -C $(BLD)/$(KBUILD) V=1 $(HCCACHE) $(XCCACHE) LD="$(CMPL_INST)/bin/ld" ARCH=$(T) CROSS_COMPILE="$(CMPL_INST)/bin/$(TARGET-ARCH)-" modules
ifeq ($(P),rpi)
	$(MAKE) -C $(BLD)/$(KBUILD) V=1 $(HCCACHE) $(XCCACHE) LD="$(CMPL_INST)/bin/ld" ARCH=$(T) CROSS_COMPILE="$(CMPL_INST)/bin/$(TARGET-ARCH)-" dtbs
endif
	$(MAKE) -C $(BLD)/$(KBUILD) INSTALL_MOD_PATH=modules INSTALL_MOD_STRIP=1 V=1 $(HCCACHE) $(XCCACHE) LD="$(CMPL_INST)/bin/ld" ARCH=$(T) modules_install

kernelimage: | $(BLD)/$(KBUILD)/vmlinuz-$(LINUX_SVER)-$(KVER)

$(BLD)/$(KBUILD)/vmlinuz-$(LINUX_SVER)-$(KVER): $(BLD)/$(KBUILD)
#.version will be increased by kernel builder automatically
	cp $(BNF) $(BLD)/$(KBUILD)/.version

ifeq ($(T),x86_64)
	$(MAKE) -C $(BLD)/$(KBUILD) V=1 $(HCCACHE) $(XCCACHE) LD="$(CMPL_INST)/bin/ld" ARCH=$(T) CROSS_COMPILE="$(CMPL_INST)/bin/$(TARGET-ARCH)-" bzImage
else
	$(MAKE) -C $(BLD)/$(KBUILD) V=1 $(HCCACHE) $(XCCACHE) LD="$(CMPL_INST)/bin/ld" ARCH=$(T) CROSS_COMPILE="$(CMPL_INST)/bin/$(TARGET-ARCH)-" zImage
endif

	cp -L --remove-destination $(BLD)/$(KBUILD)/arch/$(TARGET-CPU)/boot/*zImage $@
	chmod 644 $@
	echo $(BN) > $(BNF)

#	$(MAKE) -C $(BLD)/$(KBUILD) INSTALL_MOD_PATH=modules INSTALL_MOD_STRIP=1 V=1 $(HCCACHE) $(XCCACHE) ARCH=$(T) CROSS_COMPILE="$(CMPL_INST)/bin/$(TARGET-ARCH)-" modules_install
#	rm -f $(BLD)/$(KBUILD)/modules/lib/modules/*/build $(BLD)/$(KBUILD)/modules/lib/modules/*/source

kernel: kernel-$(T)-$(KFLAV)
	$(DBN)

kernel-$(T)-$(KFLAV): | kernelimage modules initrd
	mkdir -p $@
	cp $(BLD)/$(KBUILD)/vmlinuz-$(LINUX_SVER)-$(KVER) $@/
	cp $(BLD)/$(KBUILD)/System.map $@/System.map-$(LINUX_SVER)-$(KVER)
	cp $(BLD)/initrd-$(LINUX_SVER)-$(KVER).gz $@/
	echo $(LINUX_SVER)-$(KVER) > $@/kernel_version
ifeq ($(P),rpi)
	cp -rv $(BLD)/$(KBUILD)/arch/arm/boot/dts/*.dtb $@/
	mkdir -p $@/overlays
	cp -rv $(BLD)/$(KBUILD)/arch/arm/boot/dts/overlays/*.dtb* $@/overlays/
endif

#just to test kernel
qemu: kernel-$(T)-$(KFLAV)
ifeq ($(T),x86_64)
	$(SUDO) qemu-system-x86_64 -enable-kvm -cpu host -m 1024 -nographic \
	-kernel kernel-$(T)-$(KFLAV)/vmlinuz-$(LINUX_SVER)-$(KVER) \
	-initrd kernel-$(T)-$(KFLAV)/initrd-$(LINUX_SVER)-$(KVER).gz \
	-append "console=ttyS0"

endif
#ifeq ($(T),arm)
#	$(SUDO) qemu-system-arm -M raspi0 -m 512 -nographic -vnc :0 \
#	-kernel kernel-$(T)-$(P)/$(NAME).krnl \
#	-dtb kernel-$(T)-$(P)/bcm2708-rpi-zero-w.dtb \
#	-append 'earlyprintk earlycon=pl011,0x20201000 console=ttyAMA0 loglevel=8 \
#	initcall_blacklist=bcm2835_pm_driver_init'
#ndif

_local_clean:
	$(foreach i,$(VALID_T), \
		rm -rf $(PWD)/kernel-$(i)-$(KFLAV); \
		$(foreach j,$(VALID_P_$(i)), \
			rm -rf $(PWD)/kernel-$(i)-$(j);  ))
