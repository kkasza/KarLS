#KarLS
#Kernel - Linux LTS

include ../common.mk ./sources.mk

CMPL:=$(PWD)/../cmpl
CMPL_INST:=$(CMPL)/cmpl-$(T)

KERNEL_PLH:=__karls__
KVER:=1.0

ifeq ($(P),rpi)
KFLAV:=$(P)
else
KFLAV:=generic
endif

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

.PHONY: $(BLD)/$(LINUX_VER)-kconfig

busybox: $(BLD)/$(BUSY_VER)

$(BLD)/$(BUSY_VER): | src/$(BUSY_VER)
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

builddir: $(BLD)/$(KBUILD)

irfs: $(BLD)/$(IRFS)

$(BLD)/$(IRFS): | busybox
	mkdir -p $@/proc $@/dev $@/tmp $@/var $@/sys $@/lib/modules
	cp -rP skel/* $@/
	cp -rP skel-$(T)-$(KFLAV)/* $@/
	cp $(BLD)/$(BUSY_VER)/busybox $@/bin
	$(SUDO) mknod -m 600 $@/dev/console c 5 1
	date +%m%d%H%M%Y > $@/buildtime
	echo $(NICENAME) $(VERSION) $(VERSION_TAG) > $@/etc/version

initrd: $(BLD)/initrd.gz

$(BLD)/initrd.gz: $(BLD)/$(IRFS) modules_first
	cd $<; find . | cpio -H newc -V -o | gzip -9 -n > ../../$@

$(BLD)/$(KBUILD): | src/$(LINUX_VER) $(BLD)/$(IRFS)
	$(MAKE) -C src/$(LINUX_VER) V=1 O=$(PWD)/$@ $(HCCACHE) $(XCCACHE) ARCH=$(T) allnoconfig
	cp $(KBUILD).config $@/.config
#For RPI kernel source
#	sed -i 's/^CONFIG_CROSS_COMPILE=\"$(KERNEL_PLH)\"/CONFIG_CROSS_COMPILE=\"$(subst /,\/,${CMPL_INST})\/bin\/$(subst /,\/,$(TARGET-ARCH))-\"/' $@/.config
	sed -i 's/^CONFIG_LOCALVERSION=\"$(KERNEL_PLH)\"/CONFIG_LOCALVERSION=\"-$(NAME)_$(KVER)-$(KFLAV)\"/' $@/.config
#	sed -i 's/^CONFIG_INITRAMFS_SOURCE=\"$(KERNEL_PLH)\"/CONFIG_INITRAMFS_SOURCE=\"$(subst /,\/,$(PWD)/$(BLD)/$(IRFS))\"/' $@/.config
	sed -i 's/^CONFIG_INITRAMFS_SOURCE=\"$(KERNEL_PLH)\"/CONFIG_INITRAMFS_SOURCE=\"\"/' $@/.config
	$(MAKE) -C src/$(LINUX_VER) V=1 O=$(PWD)/$@ $(HCCACHE) $(XCCACHE) ARCH=$(T) prepare

modules: | $(BLD)/$(KBUILD)/modules.order

$(BLD)/$(KBUILD)/modules.order: | $(BLD)/$(KBUILD)
	$(MAKE) -C $(BLD)/$(KBUILD) V=1 $(HCCACHE) $(XCCACHE) LD="$(CMPL_INST)/bin/ld" ARCH=$(T) CROSS_COMPILE="$(CMPL_INST)/bin/$(TARGET-ARCH)-" modules
ifeq ($(P),rpi)
	$(MAKE) -C $(BLD)/$(KBUILD) V=1 $(HCCACHE) $(XCCACHE) LD="$(CMPL_INST)/bin/ld" ARCH=$(T) CROSS_COMPILE="$(CMPL_INST)/bin/$(TARGET-ARCH)-" dtbs
endif

#make modules_first will build the modules, and create the install directory without building the kernel
modules_first: modules
	touch $(BLD)/$(KBUILD)/modules.builtin $(BLD)/$(KBUILD)/modules.builtin.modinfo $(BLD)/$(KBUILD)/System.map
	$(MAKE) -C $(BLD)/$(KBUILD) INSTALL_MOD_PATH=modules INSTALL_MOD_STRIP=1 V=1 $(HCCACHE) $(XCCACHE) ARCH=$(T) modules_install
#Copy required kernel modules to embedded InitRD here
	cp -rv $(BLD)/$(KBUILD)/modules/* $(BLD)/$(IRFS)
	rm -f $(BLD)/$(IRFS)/lib/modules/*/build $(BLD)/$(IRFS)/lib/modules/*/source

kernelimage: $(BLD)/$(KBUILD)/$(NAME).krnl

$(BLD)/$(KBUILD)/$(NAME).krnl: initrd
#.version will be increased by kernel builder automatically
	cp $(BNF) $(BLD)/$(KBUILD)/.version

ifeq ($(T),x86_64)
	$(MAKE) -C $(BLD)/$(KBUILD) V=1 $(HCCACHE) $(XCCACHE) ARCH=$(T) bzImage
else
	$(MAKE) -C $(BLD)/$(KBUILD) V=1 $(HCCACHE) $(XCCACHE) ARCH=$(T) CROSS_COMPILE="$(CMPL_INST)/bin/$(TARGET-ARCH)-" zImage
endif

	cp -L --remove-destination $(BLD)/$(KBUILD)/arch/$(TARGET-CPU)/boot/*zImage $@
	chmod 644 $@
	echo $(BN) > $(BNF)

	$(MAKE) -C $(BLD)/$(KBUILD) INSTALL_MOD_PATH=modules INSTALL_MOD_STRIP=1 V=1 $(HCCACHE) $(XCCACHE) ARCH=$(T) CROSS_COMPILE="$(CMPL_INST)/bin/$(TARGET-ARCH)-" modules_install
	rm -f $(BLD)/$(KBUILD)/modules/lib/modules/*/build $(BLD)/$(KBUILD)/modules/lib/modules/*/source

kernel: kernel-$(T)-$(KFLAV)
	$(DBN)

kernel-$(T)-$(KFLAV): $(BLD)/$(KBUILD)/$(NAME).krnl
	mkdir -p $@
	cp $(BLD)/$(KBUILD)/$(NAME).krnl $@/
	cp $(BLD)/$(KBUILD)/System.map $@/
	cp $(BLD)/initrd.gz $@/
	cp -rv $(BLD)/$(KBUILD)/modules/* $@/
ifeq ($(P),rpi)
	cp -rv $(BLD)/$(KBUILD)/arch/arm/boot/dts/*.dtb $@/
	mkdir -p $@/overlays
	cp -rv $(BLD)/$(KBUILD)/arch/arm/boot/dts/overlays/*.dtb* $@/overlays/
endif

#just to test kernel
qemu: kernel-$(T)-$(KFLAV)
ifeq ($(T),x86_64)
	qemu-system-x86_64 -enable-kvm -cpu host -m 1024 -nographic -vnc :0 \
	-kernel kernel-$(T)-$(KFLAV)/$(NAME).krnl -append "console=ttyS0"
endif
ifeq ($(T),arm)
	qemu-system-arm -M raspi0 -m 512 -nographic -vnc :0 \
	-kernel kernel-$(T)-$(P)/$(NAME).krnl \
	-dtb kernel-$(T)-$(P)/bcm2708-rpi-zero-w.dtb \
	-append 'earlyprintk earlycon=pl011,0x20201000 console=ttyAMA0 loglevel=8 \
	initcall_blacklist=bcm2835_pm_driver_init'
endif

_local_clean:
	$(foreach i,$(VALID_T), \
		rm -rf $(PWD)/kernel-$(i)-$(KFLAV); \
		$(foreach j,$(VALID_P_$(i)), \
			rm -rf $(PWD)/kernel-$(i)-$(j);  ))
