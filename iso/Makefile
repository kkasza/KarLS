#KarLS
#ISO creation

include ../common.mk sources.mk

ifneq ($(T),x86_64)
$(error ISO can only be built for x86_64 target)
endif

ifneq ($(P),iso)
$(error Not building an ISO as platform)
endif

ifeq ($(P),rpi)
KFLAV:=$(P)
else
KFLAV:=generic
endif

IMAGE:=$(NAME)-$(VERSION)-$(T).iso

#CMPL_INST:=$(PWD)/../cmpl/cmpl-$(T)

#Setup HOST and CROSS compilers with or without ccache
#ifdef DBG_NOCC
#HCCACHE:=HOSTCC="gcc" HOSTCXX="g++"
#XCCACHE:=CC="$(CMPL_INST)/bin/gcc" CXX="$(CMPL_INST)/bin/g++"
#else
#HCCACHE:=HOSTCC="ccache gcc" HOSTCXX="ccache g++"
#XCCACHE:=CC="ccache $(CMPL_INST)/bin/gcc" CXX="ccache $(CMPL_INST)/bin/g++"
#endif

#STRIP:=$(CMPL_INST)/bin/$(TARGET-ARCH)-strip -d --strip-unneeded

#XPATH:=PATH=$(PATH):$(CMPL_INST)/bin

GRUB_OPTS:=--with-platform=efi \
--disable-efiemu \
--disable-mm-debug \
--disable-cache-stats \
--disable-boot-time \
--disable-grub-emu-sdl \
--disable-grub-emu-pci \
--disable-grub-mkfont \
--disable-grub-themes \
--disable-grub-mount \
--disable-device-mapper \
--disable-liblzma \
--disable-libzfs
#--host=$(TARGET-ARCH) \
#$(XCCACHE) \
#$(HCCACHE)

$(BLD)/$(GRUB_VER): | src/$(GRUB_VER)
	mkdir -p $@
	cd $@; ../../src/$(GRUB_VER)/configure $(GRUB_OPTS)
	$(MAKE) -C $@ V=1

#	cd $@; $(XPATH) ../../src/$(GRUB_VER)/configure $(GRUB_OPTS)
#	$(XPATH) $(MAKE) -C $@ V=1

efi.img: $(BLD)/$(GRUB_VER)
	$(SUDO) mkfs.msdos -I -C $@ 2048
	mkdir -p $@.mnt
	$(SUDO) mount $@ $@.mnt

	$(SUDO) mkdir -p $@.mnt/EFI/BOOT
	$(SUDO) $</grub-mkimage -o $@.mnt/EFI/BOOT/BOOTX64.EFI -O x86_64-efi -p /boot/grub -d $</grub-core \
	boot.mod cat.mod configfile.mod cpuid.mod disk.mod elf.mod exfat.mod ext2.mod fat.mod file.mod hdparm.mod help.mod iso9660.mod linux.mod loadenv.mod \
	lsefi.mod ls.mod msdospart.mod normal.mod ntfs.mod part_gpt.mod part_msdos.mod reboot.mod scsi.mod search_fs_file.mod search.mod \
	serial.mod syslinuxcfg.mod terminal.mod terminfo.mod usb_keyboard.mod usbserial_common.mod usbserial_pl2303.mod

	$(SUDO) umount $@.mnt

$(IMAGE): src/$(SYSLIN_VER) efi.img
	mkdir -p $@.tmp/boot/isolinux $@.tmp/boot/grub $@.tmp/packages
	cp -rv $</bios/core/isolinux.bin $</bios/com32/elflink/ldlinux/ldlinux.c32 isolinux.cfg $@.tmp/boot/isolinux
	cp -rv efi.img grub.cfg $@.tmp/boot/grub
	cp -rv ../kernel/kernel-$(T)-$(KFLAV)/$(NAME).krnl $@.tmp/boot
	cp -rv ../kernel/kernel-$(T)-$(KFLAV)/System.map $@.tmp/boot

	echo $(NICENAME) $(VERSION) $(VERSION_TAG) > $@.tmp/version

	xorriso -as mkisofs -volid KarLS -r -o $@ -J -joliet-long -isohybrid-mbr $</bios/mbr/isohdpfx.bin -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
	-boot-load-size 4 -boot-info-table -no-emul-boot -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -isohybrid-apm-hfsplus $@.tmp

	touch $@

iso: $(IMAGE)

qemu: iso
ifeq ($(T),x86_64)
	qemu-system-x86_64 -enable-kvm -cpu host -m 1024 -nographic -vnc :0 \
	-drive file=$(IMAGE).img,if=virtio,format=raw
endif

_local_clean:
	rm -rf $(IMAGE).tmp efi.img efi.img.mnt
	rm -rf $(IMAGE)
