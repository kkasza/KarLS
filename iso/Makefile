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
	$(call set_stat,"[3/5] compile $@")
	mkdir -p $@
	cd $@; ../../src/$(GRUB_VER)/configure $(GRUB_OPTS) $(GRUB_OPTS_PC)
	$(MAKE) -C $@ V=1 $(CCACHE)

$(BLD)/$(GRUB_VER)-efi: src/$(GRUB_VER)
	$(call set_stat,"[1/5] compile $@")
	mkdir -p $@
	cd $@; ../../src/$(GRUB_VER)/configure $(GRUB_OPTS) $(GRUB_OPTS_EFI)
	$(MAKE) -C $@ V=1 $(CCACHE)

efi.img: $(BLD)/$(GRUB_VER)-efi
	$(call set_stat,"[2/5] package $@")
	mkdir -p $@.fat/EFI/BOOT
	$(SUDO) $</grub-mkimage -o $@.fat/EFI/BOOT/BOOTX64.EFI -O x86_64-efi -p /boot/grub -d $</grub-core \
	boot.mod cat.mod configfile.mod cpuid.mod disk.mod elf.mod exfat.mod ext2.mod fat.mod file.mod hdparm.mod help.mod iso9660.mod linux.mod loadenv.mod \
	lsefi.mod ls.mod msdospart.mod normal.mod ntfs.mod part_gpt.mod part_msdos.mod reboot.mod scsi.mod search_fs_file.mod search.mod \
	serial.mod terminal.mod terminfo.mod usb_keyboard.mod usbserial_common.mod usbserial_pl2303.mod

	dd if=/dev/zero of=$@ bs=1M count=2
	mformat -i $@ -v karls_efi ::
	mcopy -sQv -i $@ $@.fat/EFI ::

KVER:=$(shell cat ../pkg/build-$(T)/kernel/kernel_version 2>/dev/null)

$(BLD)/initrd:
	$(call set_stat,"[4/5] package $@")
	mkdir -p $@/proc $@/dev $@/tmp $@/sys $@/lib/modules $@/usr/udhcpc $@/var/run $@/var/log $@/var/lock $@/var/tmp

	cp -rP initrd-skel/* $@/

	cp ../pkg/$(BLD)/busybox-static/busybox $@/bin
	cp ../pkg/$(BLD)/busybox-static/examples/udhcp/simple.script $@/usr/udhcpc/default.script

	cp -r ../pkg/build-$(T)/kernel/_kp_tmp/FILES/lib $@

	$(SUDO) mknod -m 600 $@/dev/console c 5 1
	echo $(NICENAME) $(VERSION) $(VERSION_TAG) > $@/etc/version

initrd: | $(BLD)/initrd-$(KVER).gz

$(BLD)/initrd-$(KVER).gz: | $(BLD)/initrd
	cd $(BLD)/initrd; find . | cpio -H newc -V -R 0:0 -o | gzip -9 -n > ../../$@

rebuild_initrd:
	rm -rf $(BLD)/initrd $(BLD)/initrd-$(KVER).gz
	make initrd

$(IMAGE): | efi.img $(BLD)/$(GRUB_VER) initrd
	$(call set_stat,"[5/5] package $@")
	mkdir -p $@.tmp/boot/grub $@.tmp/packages $@.tmp/firmware
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

	cp ../pkg/build-$(T)/kernel/kernel_version ../pkg/build-$(T)/kernel/_kp_tmp/FILES/boot/vmlinuz-$(KVER) ../pkg/build-$(T)/kernel/_kp_tmp/FILES/boot/System.map-$(KVER) $@.tmp/boot
	cp $(BLD)/initrd-$(KVER).gz $@.tmp/boot
	cp ../LICENSE ../doc/UEFI_SECURE_BOOT.NOTE $@.tmp
	cp -r install $@.tmp
	cp ../pkg/pkg/kpm/Current/kpm $@.tmp/install
	cp ../pkg/build-$(T)/*.kp $@.tmp/packages
	cp ../pkg/build-$(T)/wifi_regdb-*/regulatory.db* $@.tmp/firmware
	cp -r ../pkg/build-$(T)/linux_firmware-*/* $@.tmp/firmware
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
	$(call set_stat,"done")

rebuild_iso: _local_clean iso

qemu: iso
	if [ ! -f "testdisk.img" ]; then qemu-img create -f qcow2 testdisk.img 10G; fi
	$(SUDO) qemu-system-x86_64 -enable-kvm -cpu host -m 1024 \
	-nographic -vnc :0 \
	-boot cd -cdrom $(IMAGE) \
	-device virtio-scsi-pci,id=scsi \
	-device scsi-hd,drive=hd \
	-drive format=qcow2,file=testdisk.img,if=none,id=hd,index=0,snapshot=off \
	-device virtio-net,netdev=net0 \
	-netdev user,id=net0,hostfwd=tcp::2222-:22

ssh:
	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@127.0.0.1 -p 2222

gcpimage: karls-gcpimage-$(VERSION).tar.gz

karls-gcpimage-$(VERSION).tar.gz:
	qemu-img convert -f qcow2 -O raw testdisk.img disk.raw
	tar --format=oldgnu -h -Sczf $@ disk.raw
	rm -f disk.raw

_local_clean:
	rm -rf $(IMAGE).tmp efi.img efi.img.fat testdisk.img disk.raw karls-gcpimage-*.tar.gz
	rm -rf $(IMAGE)
