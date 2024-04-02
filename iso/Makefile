#KarLS
#ISO creation

include ../common.mk sources.mk

ifneq ($(T),x86_64)
$(error ISO can only be built for x86_64 target)
endif

ifneq ($(P),iso)
$(error Not building an ISO as platform)
endif

IMAGE:=$(NAME)-$(VERSION)-$(T).iso

GRUB_OPTS_PC:=--with-platform=pc

GRUB_OPTS_EFI:=--with-platform=efi

GRUB_OPTS:= \
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
--disable-libzfs \
$(CCACHE)

$(BLD)/$(GRUB_VER): src/$(GRUB_VER)
	mkdir -p $@
	cd $@; ../../src/$(GRUB_VER)/configure $(GRUB_OPTS) $(GRUB_OPTS_PC)
	$(MAKE) -C $@ V=1 $(CCACHE)

$(BLD)/$(GRUB_VER)-efi: src/$(GRUB_VER)
	mkdir -p $@
	cd $@; ../../src/$(GRUB_VER)/configure $(GRUB_OPTS) $(GRUB_OPTS_EFI)
	$(MAKE) -C $@ V=1 $(CCACHE)

efi.img: $(BLD)/$(GRUB_VER)-efi
	$(SUDO) mkfs.msdos -I -C $@ 2048
	mkdir -p $@.mnt
	$(SUDO) mount $@ $@.mnt

	$(SUDO) mkdir -p $@.mnt/EFI/BOOT
	$(SUDO) $</grub-mkimage -o $@.mnt/EFI/BOOT/BOOTX64.EFI -O x86_64-efi -p /boot/grub -d $</grub-core \
	boot.mod cat.mod configfile.mod cpuid.mod disk.mod elf.mod exfat.mod ext2.mod fat.mod file.mod hdparm.mod help.mod iso9660.mod linux.mod loadenv.mod \
	lsefi.mod ls.mod msdospart.mod normal.mod ntfs.mod part_gpt.mod part_msdos.mod reboot.mod scsi.mod search_fs_file.mod search.mod \
	serial.mod terminal.mod terminfo.mod usb_keyboard.mod usbserial_common.mod usbserial_pl2303.mod

	$(SUDO) umount $@.mnt

KVER:=$(shell cat ../kernel/kernel-$(T)-$(KFLAV)/kernel_version)

$(IMAGE): | efi.img $(BLD)/$(GRUB_VER)
	mkdir -p $@.tmp/boot/grub $@.tmp/packages
	cp efi.img grub.cfg $@.tmp/boot/grub

	echo "menuentry \"KarLS ISO\" {" >> $@.tmp/boot/grub/grub.cfg
	echo "	search -f /karls_iso --set=root" >> $@.tmp/boot/grub/grub.cfg
	echo "	linux /boot/vmlinuz-$(KVER) vga=0x305 KARLS_MEDIA=ISO" >> $@.tmp/boot/grub/grub.cfg
	echo "	initrd /boot/initrd-$(KVER).gz" >> $@.tmp/boot/grub/grub.cfg
	echo "}" >> $@.tmp/boot/grub/grub.cfg
	echo "" >> $@.tmp/boot/grub/grub.cfg
	echo "menuentry \"KarLS ISO Serial Console\" {" >> $@.tmp/boot/grub/grub.cfg
	echo "	search -f /karls_iso --set=root" >> $@.tmp/boot/grub/grub.cfg
	echo "	linux /boot/vmlinuz-$(KVER) console=ttyS0,9600 KARLS_MEDIA=ISO" >> $@.tmp/boot/grub/grub.cfg
	echo "	initrd /boot/initrd-$(KVER).gz" >> $@.tmp/boot/grub/grub.cfg
	echo "}" >> $@.tmp/boot/grub/grub.cfg

	cp ../kernel/kernel-$(T)-$(KFLAV)/vmlinuz-$(KVER) $@.tmp/boot
	cp ../kernel/kernel-$(T)-$(KFLAV)/System.map-$(KVER) $@.tmp/boot
	cp ../kernel/kernel-$(T)-$(KFLAV)/initrd-$(KVER).gz $@.tmp/boot
	cp ../LICENSE ../UEFI_SECURE_BOOT.NOTE $@.tmp
	cp -r install $@.tmp
	cp ../pkg/build-$(T)/*.kp $@.tmp/packages

	echo $(NICENAME) $(VERSION) $(VERSION_TAG) > $@.tmp/karls_iso

	$(BLD)/$(GRUB_VER)/grub-mkimage -o $@.tmp/boot/grub/grub.img -O i386-pc -p /boot/grub -d $(BLD)/$(GRUB_VER)/grub-core \
	boot.mod biosdisk.mod cat.mod configfile.mod cpuid.mod disk.mod elf.mod exfat.mod ext2.mod fat.mod file.mod hdparm.mod help.mod iso9660.mod linux.mod loadenv.mod \
	ls.mod msdospart.mod normal.mod ntfs.mod part_gpt.mod part_msdos.mod reboot.mod scsi.mod search_fs_file.mod search.mod \
	serial.mod terminal.mod terminfo.mod usb_keyboard.mod usbserial_common.mod usbserial_pl2303.mod
	cat $(BLD)/$(GRUB_VER)/grub-core/cdboot.img $@.tmp/boot/grub/grub.img > $@.tmp/boot/grub/grub-cd.img

	xorriso -as mkisofs -volid KarLS -r -o $@ -J -joliet-long \
	-b boot/grub/grub-cd.img -c boot/grub/boot.cat -boot-load-size 4 -boot-info-table -no-emul-boot \
	--grub2-boot-info --grub2-mbr $(BLD)/$(GRUB_VER)/grub-core/boot_hybrid.img \
	-eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
	$@.tmp

iso: $(IMAGE)

qemu: iso
	$(SUDO) qemu-system-x86_64 -enable-kvm -cpu host -m 1024 -boot d -cdrom $(IMAGE) -nographic -vnc :0

_local_clean:
	rm -rf $(IMAGE).tmp efi.img efi.img.mnt
	rm -rf $(IMAGE)
