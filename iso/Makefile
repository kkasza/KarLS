#DGOS
#Device Image for various targets/platforms with different bootloaders

include ../common.mk sources.mk

#OSSIZE:=`ls -alh ../osimg/dgos-$(T).img | cut -d' ' -f5 | cut -d'M' -f1`
#OSIMGSIZE:=$$(( $(OSSIZE)  * 4 ))
#IMGSIZE:=$$(( $(BOOTSIZE) + $(CFGSIZE) + $(OSIMGSIZE) ))

#Output image size in megs - should be a power of 2, e.g. 128MB
IMGSIZE:=256
#Boot partition size, kernel + fallback os image, dtbs, bootcode, etc.
BOOTSIZE:=40
#CFG partition size
CFGSIZE:=10
#OSIMG Storage partition size
OSIPSIZE:=64
#The remaining should be cache, around 100 MB - for tor cache, etc.

ifeq ($(T),x86_64)
$(BLD)/$(SYSLIN_VER): | src/$(SYSLIN_VER)
	mkdir -p $(BLD)
	cp -rP src/$(SYSLIN_VER) $@
	$(MAKE) -C $@ $(CCACHE) installer
endif

IMAGE:=devimg-$(T)-$(P)

devimg: $(IMAGE).img

build-img-$(T)-$(P).tmp:
	mkdir -p $(IMAGE)/flash1

#	Empty image file
	dd status=progress if=/dev/zero of=$@ bs=1M count=$(IMGSIZE)
#	Partition table
	echo "n\np\n1\n\n+$(BOOTSIZE)M\na\nw" | /sbin/fdisk $@
	echo "n\np\n2\n\n+$(CFGSIZE)M\nw" | /sbin/fdisk $@
	echo "n\np\n3\n\n+$(OSIPSIZE)M\nw" | /sbin/fdisk $@
	echo "n\np\n4\n\n\nw" | /sbin/fdisk $@

ifeq ($(P),rpi)
#	change first partition type from linux-ext to vfat
	echo "t\n1\nc\n\nw" | /sbin/fdisk $@
endif

	$(SUDO) losetup -P /dev/loop0 $@
#	Filesystems

ifeq ($(P),rpi)
	$(SUDO) mkfs.vfat -v /dev/loop0p1
else
	$(SUDO) mke2fs -t ext4 -j -L $(NAME)-boot /dev/loop0p1
endif
	$(SUDO) mke2fs -t ext4 -j -L $(NAME)-cfg /dev/loop0p2
	$(SUDO) mke2fs -t ext4 -j -L $(NAME)-osimg /dev/loop0p3
	$(SUDO) mke2fs -t ext4 -j -L $(NAME)-cache /dev/loop0p4

	$(SUDO) losetup -d /dev/loop0

#X86_64 QEMU Image
ifeq ($(T),x86_64)
#x86_64 currently only works on qemu
$(IMAGE): build-img-$(T)-$(P).tmp $(BLD)/$(SYSLIN_VER)
#	MBR
	dd status=progress if=$(BLD)/$(SYSLIN_VER)/bios/mbr/mbr.bin of=$< bs=440 count=1 conv=notrunc

	$(SUDO) losetup -P /dev/loop0 $<

	$(SUDO) mount /dev/loop0p1 $@/flash1

#	Boot loader config
	echo DEFAULT $(NAME) > $@/syslinux.cfg
	echo PROMPT 1 >> $@/syslinux.cfg
	echo TIMEOUT 20 >> $@/syslinux.cfg
#	echo NOESCAPE 1 >> $@/syslinux.cfg
	echo SERIAL 0 >> $@/syslinux.cfg
	echo LABEL $(NAME) >> $@/syslinux.cfg
	echo KERNEL $(NAME).krnl >> $@/syslinux.cfg
	echo APPEND console=ttyS0 >> $@/syslinux.cfg

	$(SUDO) cp $@/syslinux.cfg $@/flash1

#	copy kernel
	$(SUDO) cp -rP $(PWD)/../kernel/kernel-$(T)-$(P)/$(NAME).krnl $@/flash1
	$(SUDO) cp -rP $(PWD)/../kernel/kernel-$(T)-$(P)/System.map $@/flash1

#	copy compressed OS image
	$(SUDO) cp -rP $(PWD)/../osimg/$(NAME)-$(T).img $@/flash1/dgos-default.img

#	create bootloader additional files
	$(SUDO) $(BLD)/$(SYSLIN_VER)/bios/extlinux/extlinux --device=/dev/loop0p1 -i $@/flash1

	$(SUDO) umount /dev/loop0p1
	$(SUDO) losetup -d /dev/loop0
	touch $@
endif

ifeq ($(P),rpi)
$(IMAGE): build-img-$(T)-$(P).tmp
	$(SUDO) losetup -P /dev/loop0 $<

	$(SUDO) mount /dev/loop0p1 $@/flash1

#DOS FS, for RPI boot
	$(SUDO) cp -rP $(PWD)/../kernel/kernel-$(T)-$(P)/$(NAME).krnl $@/flash1/kernel.img
	$(SUDO) cp -rP $(PWD)/../kernel/kernel-$(T)-$(P)/*.dtb $@/flash1/
	$(SUDO) cp -rP $(PWD)/../kernel/kernel-$(T)-$(P)/overlays $@/flash1/
	$(SUDO) cp -rP $(PWD)/../kernel/kernel-$(T)-$(P)/System.map $@/flash1
	$(SUDO) cp -rP rpifw/* $@/flash1

#OS IMG
	$(SUDO) cp -rP $(PWD)/../osimg/dgos-$(T).img $@/flash1/dgos-default.img

#devimg-update.img
	$(SUDO) tar -cv -J -f devimg-$(T)-$(P)-update.txz -C $@/flash1 .
	$(SUDO) chown 1000:1000 devimg-$(T)-$(P)-update.txz
	ln -sf devimg-$(T)-$(P)-update.txz devimg-update.txz

	$(SUDO) umount /dev/loop0p1
	$(SUDO) losetup -d /dev/loop0
	touch $@
endif

$(IMAGE).img: $(IMAGE)
	mv build-img-$(T)-$(P).tmp $@
	touch build-img-$(T)-$(P).tmp $< $@

mount: devimg
	$(SUDO) losetup -P /dev/loop0 $(IMAGE).img
	$(SUDO) mount /dev/loop0p1 $(IMAGE)/flash1

umount: devimg
	$(SUDO) umount /dev/loop0p1
	$(SUDO) losetup -d /dev/loop0

qemu: devimg
ifeq ($(T),x86_64)
	qemu-system-x86_64 -enable-kvm -cpu host -m 1024 -nographic -vnc :0 \
	-drive file=$(IMAGE).img,if=virtio,format=raw
endif
ifeq ($(T),arm)
	qemu-system-arm -M raspi0 -m 512 -nographic -vnc :0 \
	-kernel ../kernel/kernel-$(T)-$(P)/$(NAME).krnl \
	-dtb ../kernel/kernel-$(T)-$(P)/bcm2708-rpi-zero-w.dtb \
	-append 'earlyprintk earlycon=pl011,0x20201000 console=ttyAMA0 \
	loglevel=8 initcall_blacklist=bcm2835_pm_driver_init' \
	-drive file=$(IMAGE).img,if=sd,format=raw
endif

_local_clean:
	rm -f $(PWD)/devimg-update.txz; \
	$(foreach i,$(VALID_T), \
		$(foreach j,$(VALID_P_$(i)), \
			rm -rf $(PWD)/devimg-$(i)-$(j); \
			rm -rf $(PWD)/devimg-$(i)-$(j).img; \
			rm -rf $(PWD)/devimg-$(i)-$(j)-update.txz; \
			rm -rf $(PWD)/build-img-$(i)-$(j).tmp; ))
