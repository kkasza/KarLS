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

$(IMAGE): src/$(SYSLIN_VER)
	mkdir -p $@.tmp/boot/isolinux
	cp -rv $</bios/core/isolinux.bin $</bios/com32/elflink/ldlinux/ldlinux.c32 isolinux.cfg $@.tmp/boot/isolinux
	cp -rv ../kernel/kernel-$(T)-$(KFLAV)/* $@.tmp
	mv -v $@.tmp/$(NAME).krnl $@.tmp/System.map $@.tmp/boot
	mkisofs -o $@ \
	-b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
	-input-charset utf-8 -J -joliet-long -uid 0 -gid 0 -hide-rr-moved \
	-no-emul-boot -boot-load-size 4 -boot-info-table $@.tmp
	touch $@

iso: $(IMAGE)

qemu: iso
ifeq ($(T),x86_64)
	qemu-system-x86_64 -enable-kvm -cpu host -m 1024 -nographic -vnc :0 \
	-drive file=$(IMAGE).img,if=virtio,format=raw
endif

_local_clean:
	rm -rf $(IMAGE).tmp
	rm -rf $(IMAGE)
