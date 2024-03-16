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

IMAGE:=$(NAME)-$(T).iso

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
	$(SUDO) mkfs.msdos -C $@ 10240
	mkdir -p $@.mnt
	$(SUDO) mount $@ $@.mnt

	$(SUDO) mkdir -p $@.mnt/EFI/BOOT
#	$(SUDO) cp $</efi64/efi/syslinux.efi $@.mnt/EFI/BOOT/BOOTX64.EFI
#	$(SUDO) cp $</efi64/com32/elflink/ldlinux/ldlinux.e64 $@.mnt/EFI/BOOT/
#	$(SUDO) cp $</efi64/com32/libutil/libutil.c32 $@.mnt/EFI/BOOT/
#	$(SUDO) cp $</efi64/com32/menu/menu.c32 $@.mnt/EFI/BOOT/

	$(SUDO) umount $@.mnt

$(IMAGE): src/$(SYSLIN_VER) efi.img
	mkdir -p $@.tmp/boot/isolinux
	cp -rv $</bios/core/isolinux.bin $</bios/com32/elflink/ldlinux/ldlinux.c32 isolinux.cfg efi.img $@.tmp/boot/isolinux
	cp -rv ../kernel/kernel-$(T)-$(KFLAV)/* $@.tmp
	mv -v $@.tmp/$(NAME).krnl $@.tmp/System.map $@.tmp/boot

#	mkisofs -o $@ \
#	-b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
#	-input-charset utf-8 -J -joliet-long -uid 0 -gid 0 -hide-rr-moved \
#	-no-emul-boot -boot-load-size 4 -boot-info-table \
#	-eltorito-alt-boot -e boot/isolinux/efi.img -no-emul-boot $@.tmp

#xorriso -as mkisofs -r -checksum_algorithm_iso sha256,sha512 -V 'Debian 12.5.0 amd64 n'
# -o /srv/cdbuilder.debian.org/dst/deb-cd/out/2bookwormamd64/debian-12.5.0-amd64-NETINST-1.iso
# -checksum-list /srv/cdbuilder.debian.org/src/deb-cd/tmp/2bookwormamd64/bookworm/checksum-check
# -jigdo-checksum-algorithm md5 -jigdo-force-checksum /pool/ -jigdo-min-file-size 1024 -jigdo-exclude 'README*' -jigdo-exclude /doc/ -jigdo-exclude /md5sum.txt -jigdo-exclude /.disk/ -jigdo-exclude /pics/ -jigdo-exclude 'Release*' -jigdo-exclude 'Packages*' -jigdo-exclude 'Sources*' -jigdo-jigdo /srv/cdbuilder.debian.org/dst/deb-cd/out/2bookwormamd64/debian-12.5.0-amd64-NETINST-1.jigdo -jigdo-template /srv/cdbuilder.debian.org/dst/deb-cd/out/2bookwormamd64/debian-12.5.0-amd64-NETINST-1.template -jigdo-map Debian=/srv/cdbuilder.debian.org/src/ftp/debian/ -jigdo-exclude boot1 -J -joliet-long -cache-inodes
# -isohybrid-mbr syslinux/usr/lib/ISOLINUX/isohdpfx.bin -b isolinux/isolinux.bin -c isolinux/boot.cat -boot-load-size 4 -boot-info-table -no-emul-boot -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -isohybrid-apm-hfsplus boot1 CD1

	xorriso -as mkisofs -r -o $@ -J -joliet-long -isohybrid-mbr $</bios/mbr/isohdpfx.bin -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
	-boot-load-size 4 -boot-info-table -no-emul-boot -eltorito-alt-boot -e boot/isolinux/efi.img -no-emul-boot -isohybrid-gpt-basdat -isohybrid-apm-hfsplus $@.tmp

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
