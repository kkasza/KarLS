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

$(BLD)/initrd:
	mkdir -p $@/proc $@/dev $@/tmp $@/sys $@/lib/modules $@/usr/udhcpc $@/var/run $@/var/log $@/var/lock $@/var/tmp

	cp -rP initrd-skel/* $@/

	cp ../pkg/$(BLD)/busybox-static/busybox $@/bin
	cp ../pkg/$(BLD)/busybox-static/examples/udhcp/simple.script $@/usr/udhcpc/default.script

	cp -r ../kernel/kernel-$(T)-$(KFLAV)/modules/* $(BLD)/initrd
	rm -f $(BLD)/initrd/lib/modules/*/build $(BLD)/initrd/lib/modules/*/source

	$(SUDO) mknod -m 600 $@/dev/console c 5 1
	echo $(NICENAME) $(VERSION) $(VERSION_TAG) > $@/etc/version

initrd: | $(BLD)/initrd-$(KVER).gz

$(BLD)/initrd-$(KVER).gz: | $(BLD)/initrd
	cd $(BLD)/initrd; find . | cpio -H newc -V -R 0:0 -o | gzip -9 -n > ../../$@

rebuild_initrd:
	rm -rf $(BLD)/initrd $(BLD)/initrd-$(KVER).gz
	make initrd

$(IMAGE): | efi.img $(BLD)/$(GRUB_VER) initrd
	mkdir -p $@.tmp/boot/grub $@.tmp/packages
	cp efi.img grub.cfg $@.tmp/boot/grub

	echo "menuentry \"KarLS ISO\" {" >> $@.tmp/boot/grub/grub.cfg
	echo "	search -l "KARLSISO" --set=root" >> $@.tmp/boot/grub/grub.cfg
	echo "	linux /boot/vmlinuz-$(KVER) KARLS_MEDIA=ISO" >> $@.tmp/boot/grub/grub.cfg
	echo "	initrd /boot/initrd-$(KVER).gz" >> $@.tmp/boot/grub/grub.cfg
	echo "}" >> $@.tmp/boot/grub/grub.cfg
	echo "" >> $@.tmp/boot/grub/grub.cfg
	echo "menuentry \"KarLS ISO No Framebuffer\" {" >> $@.tmp/boot/grub/grub.cfg
	echo "	search -l "KARLSISO" --set=root" >> $@.tmp/boot/grub/grub.cfg
	echo "	set gfxpayload=text" >> $@.tmp/boot/grub/grub.cfg
	echo "	linux /boot/vmlinuz-$(KVER) nofb nomodeset KARLS_MEDIA=ISO" >> $@.tmp/boot/grub/grub.cfg
	echo "	initrd /boot/initrd-$(KVER).gz" >> $@.tmp/boot/grub/grub.cfg
	echo "}" >> $@.tmp/boot/grub/grub.cfg
	echo "" >> $@.tmp/boot/grub/grub.cfg
	echo "menuentry \"KarLS ISO Serial Console\" {" >> $@.tmp/boot/grub/grub.cfg
	echo "	search -l "KARLSISO" --set=root" >> $@.tmp/boot/grub/grub.cfg
	echo "	linux /boot/vmlinuz-$(KVER) console=ttyS0,9600 KARLS_MEDIA=ISO" >> $@.tmp/boot/grub/grub.cfg
	echo "	initrd /boot/initrd-$(KVER).gz" >> $@.tmp/boot/grub/grub.cfg
	echo "}" >> $@.tmp/boot/grub/grub.cfg

	cp ../kernel/kernel-$(T)-$(KFLAV)/kernel_version ../kernel/kernel-$(T)-$(KFLAV)/System.map-$(KVER) ../kernel/kernel-$(T)-$(KFLAV)/vmlinuz-$(KVER) $@.tmp/boot
	cp $(BLD)/initrd-$(KVER).gz $@.tmp/boot
	cp ../LICENSE ../doc/UEFI_SECURE_BOOT.NOTE $@.tmp
	cp -r install $@.tmp
	cp ../pkg/pkg/kpm/kpm $@.tmp/install
	cp ../pkg/build-$(T)/*.kp $@.tmp/packages
	ls -1 $@.tmp/packages > $@.tmp/repo.db
	mv $@.tmp/repo.db $@.tmp/packages

	echo $(NICENAME) $(VERSION) $(VERSION_TAG) > $@.tmp/karls_iso

	$(BLD)/$(GRUB_VER)/grub-mkimage -o $@.tmp/boot/grub/grub.img -O i386-pc -p /boot/grub -d $(BLD)/$(GRUB_VER)/grub-core \
	boot.mod biosdisk.mod cat.mod configfile.mod cpuid.mod disk.mod elf.mod exfat.mod ext2.mod fat.mod file.mod hdparm.mod help.mod iso9660.mod linux.mod loadenv.mod \
	ls.mod msdospart.mod normal.mod ntfs.mod part_gpt.mod part_msdos.mod reboot.mod scsi.mod search_fs_file.mod search.mod \
	serial.mod terminal.mod terminfo.mod usb_keyboard.mod usbserial_common.mod usbserial_pl2303.mod
	cat $(BLD)/$(GRUB_VER)/grub-core/cdboot.img $@.tmp/boot/grub/grub.img > $@.tmp/boot/grub/grub-cd.img

	xorriso -as mkisofs -volid KARLSISO -r -o $@ -J -joliet-long \
	-b boot/grub/grub-cd.img -c boot/grub/boot.cat -boot-load-size 4 -boot-info-table -no-emul-boot \
	--grub2-boot-info --grub2-mbr $(BLD)/$(GRUB_VER)/grub-core/boot_hybrid.img \
	-eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
	$@.tmp

iso: $(IMAGE)

rebuild_iso: _local_clean iso

qemu: iso
	if [ ! -f "testdisk.img" ]; then dd if=/dev/zero of=testdisk.img bs=1M count=10240; fi
	$(SUDO) qemu-system-x86_64 -enable-kvm -cpu host -m 1024 -boot cd -cdrom $(IMAGE) -nographic -vnc :0 \
	-device virtio-scsi-pci,id=scsi \
	-device scsi-hd,drive=hd \
	-drive format=raw,file=testdisk.img,if=none,id=hd,index=0,snapshot=off \
	-device virtio-net,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::2222-:22

gcpimage: karls-gcpimage-$(VERSION).tar.gz

karls-gcpimage-$(VERSION).tar.gz:
	ln -sf testdisk.img disk.raw
	tar --format=oldgnu -h -Sczf $@ disk.raw

_local_clean:
	rm -rf $(IMAGE).tmp efi.img efi.img.mnt testdisk.img disk.raw karls-gcpimage-*.tar.gz
	rm -rf $(IMAGE)
