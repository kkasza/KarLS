#KarLS
#Kernel - Linux LTS

include ../common.mk ./sources.mk

CMPL:=$(PWD)/../cmpl
CMPL_INST:=$(CMPL)/cmpl-$(T)

KERNEL_PLH:=__karls__

KVER:=$(NAME)-$(KFLAV)

#Build Number for kernel (after #)
BNF:=buildno-$(T)-$(KFLAV)
BN:=$$(( $(shell cat $(BNF))+1 ))
DBN:=$(info *** Kernel: Current build number is: #$(shell cat $(BNF)) *** )

KBUILD:=$(LINUX_VER)-$(T)-$(KFLAV)

ifdef DBG_NOCC
HCCACHE:=HOSTCC="gcc" HOSTCXX="g++"
XCCACHE:=CC="$(CMPL_INST)/bin/gcc" CXX="$(CMPL_INST)/bin/g++"
else
HCCACHE:=HOSTCC="ccache gcc" HOSTCXX="ccache g++"
XCCACHE:=CC="ccache $(CMPL_INST)/bin/gcc" CXX="ccache $(CMPL_INST)/bin/g++"
endif

.PHONY: $(BLD)/$(LINUX_VER)-kconfig

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

kernel-$(T)-$(KFLAV): | kernelimage modules
	mkdir -p $@
	cp $(BLD)/$(KBUILD)/vmlinuz-$(LINUX_SVER)-$(KVER) $@/
	cp $(BLD)/$(KBUILD)/System.map $@/System.map-$(LINUX_SVER)-$(KVER)
	cp -rv $(BLD)/$(KBUILD)/modules $@/
	echo $(LINUX_SVER)-$(KVER) > $@/kernel_version
ifeq ($(P),rpi)
	cp -rv $(BLD)/$(KBUILD)/arch/arm/boot/dts/*.dtb $@/
	mkdir -p $@/overlays
	cp -rv $(BLD)/$(KBUILD)/arch/arm/boot/dts/overlays/*.dtb* $@/overlays/
endif

#just to test kernel
#qemu: kernel-$(T)-$(KFLAV)
#ifeq ($(T),x86_64)
#	$(SUDO) qemu-system-x86_64 -enable-kvm -cpu host -m 1024 -nographic \
#	-kernel kernel-$(T)-$(KFLAV)/vmlinuz-$(LINUX_SVER)-$(KVER) \
#	-initrd kernel-$(T)-$(KFLAV)/initrd-$(LINUX_SVER)-$(KVER).gz \
#	-append "console=ttyS0"
#
#endif
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
