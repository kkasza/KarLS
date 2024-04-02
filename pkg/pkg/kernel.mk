KVER:=$(shell cat ../kernel/kernel-$(T)-$(KFLAV)/kernel_version)
KERNEL_VER:=kernel-$(KVER)

PKG_LIST+=kernel

kernel: $(BLD)/$(KERNEL_VER).kp

$(BLD)/$(KERNEL_VER):
	mkdir -p $@/boot $@/lib
	cp ../kernel/kernel-$(T)-$(KFLAV)/vmlinuz-$(KVER) $@/boot
	cp ../kernel/kernel-$(T)-$(KFLAV)/System.map-$(KVER) $@/boot
	cp ../kernel/kernel-$(T)-$(KFLAV)/initrd-$(KVER).gz $@/boot
	cp -r ../kernel/$(BLD)/linux-*-$(T)-$(KFLAV)/modules/* $@
	rm -f $@/lib/modules/*/build $@/lib/modules/*/source

$(BLD)/$(KERNEL_VER).kp: $(BLD)/$(KERNEL_VER)
	tar -C $< -cJv -f $@ --owner=0 --group=0 .
