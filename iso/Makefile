#KarLS
#ISO creation

include ../common.mk sources.mk

ifneq ($(T),x86_64)
$(error ISO can only be built for x86_64 target)
endif

ifneq ($(P),iso)
$(error Not building an ISO as platform)
endif

IMAGE:=$(NAME)-$(T).iso

$(IMAGE): src/$(SYSLIN_VER)
	mkdir -p $@.tmp/isolinux
	cp -rv $</bios/core/isolinux.bin $</bios/com32/elflink/ldlinux/ldlinux.c32 isolinux.cfg $@.tmp/isolinux
	cp -rv ../kernel/kernel-$(T)-$(P)/* $@.tmp/
	mkdir -p $@.tmp/kernel
	mv -v $@.tmp/$(NAME).krnl $@.tmp/System.map $@.tmp/kernel
	mkisofs -o $@ \
	-b isolinux/isolinux.bin -c isolinux/boot.cat \
	-input-charset utf-8 -J -joliet-long -uid 0 -gid 0 \
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
