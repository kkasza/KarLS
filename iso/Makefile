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

GRUB_OPTS_X86_64:=--with-platform=efi --disable-efiemu

GRUB_OPTS:=--disable-mm-debug \
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

$(BLD)/$(GRUB_VER): src/$(GRUB_VER)
	mkdir -p $@
	cd $@; ../../src/$(GRUB_VER)/configure $(GRUB_OPTS)
	$(MAKE) -C $@ V=1

#	cd $@; $(XPATH) ../../src/$(GRUB_VER)/configure $(GRUB_OPTS)
#	$(XPATH) $(MAKE) -C $@ V=1

$(BLD)/$(GRUB_VER)-x86_64: src/$(GRUB_VER)
	mkdir -p $@
	cd $@; ../../src/$(GRUB_VER)/configure $(GRUB_OPTS) $(GRUB_OPTS_X86_64)
	$(MAKE) -C $@ V=1

efi.img: $(BLD)/$(GRUB_VER)-x86_64
	$(SUDO) mkfs.msdos -I -C $@ 2048
	mkdir -p $@.mnt
	$(SUDO) mount $@ $@.mnt

	$(SUDO) mkdir -p $@.mnt/EFI/BOOT
	$(SUDO) $</grub-mkimage -o $@.mnt/EFI/BOOT/BOOTX64.EFI -O x86_64-efi -p /boot/grub -d $</grub-core \
	boot.mod cat.mod configfile.mod cpuid.mod disk.mod elf.mod exfat.mod ext2.mod fat.mod file.mod hdparm.mod help.mod iso9660.mod linux.mod loadenv.mod \
	lsefi.mod ls.mod msdospart.mod normal.mod ntfs.mod part_gpt.mod part_msdos.mod reboot.mod scsi.mod search_fs_file.mod search.mod \
	serial.mod terminal.mod terminfo.mod usb_keyboard.mod usbserial_common.mod usbserial_pl2303.mod

	$(SUDO) umount $@.mnt

$(IMAGE): | efi.img $(BLD)/$(GRUB_VER)
	mkdir -p $@.tmp/boot/grub $@.tmp/packages
	cp efi.img grub.cfg $@.tmp/boot/grub
	cp ../kernel/kernel-$(T)-$(KFLAV)/$(NAME).krnl $@.tmp/boot
	cp ../kernel/kernel-$(T)-$(KFLAV)/initrd.gz $@.tmp/boot
	cp ../kernel/kernel-$(T)-$(KFLAV)/System.map $@.tmp/boot
	cp ../LICENSE ../UEFI_SECURE_BOOT.NOTE $@.tmp

	echo $(NICENAME) $(VERSION) $(VERSION_TAG) > $@.tmp/karls_iso

	$(BLD)/$(GRUB_VER)/grub-mkimage -o $@.tmp/boot/grub/core.img -O i386-pc -p /boot/grub -d $(BLD)/$(GRUB_VER)/grub-core \
	boot.mod biosdisk.mod cat.mod configfile.mod cpuid.mod disk.mod elf.mod exfat.mod ext2.mod fat.mod file.mod hdparm.mod help.mod iso9660.mod linux.mod loadenv.mod \
	ls.mod msdospart.mod normal.mod ntfs.mod part_gpt.mod part_msdos.mod reboot.mod scsi.mod search_fs_file.mod search.mod \
	serial.mod terminal.mod terminfo.mod usb_keyboard.mod usbserial_common.mod usbserial_pl2303.mod
	cat $(BLD)/$(GRUB_VER)/grub-core/cdboot.img $@.tmp/boot/grub/core.img > $@.tmp/boot/grub/grub.img
	rm $@.tmp/boot/grub/core.img

	xorriso -as mkisofs -volid KarLS -r -o $@ -J -joliet-long \
	-b boot/grub/grub.img -c boot/grub/boot.cat -boot-load-size 4 -boot-info-table -no-emul-boot \
	--grub2-boot-info --grub2-mbr $(BLD)/$(GRUB_VER)/grub-core/boot_hybrid.img \
	-eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
	$@.tmp

iso: $(IMAGE)

qemu: iso
ifeq ($(T),x86_64)
	qemu-system-x86_64 -enable-kvm -cpu host -m 1024 -nographic -vnc :0 \
	-drive file=$(IMAGE).img,if=virtio,format=raw
endif

_local_clean:
	rm -rf $(IMAGE).tmp efi.img efi.img.mnt
	rm -rf $(IMAGE)
