KVER:=$(shell cat ../kernel/kernel-$(T)-$(KFLAV)/kernel_version)
KERNEL_VER:=kernel-$(KVER)

PKG_LIST+=kernel

kernel: $(BLD)/$(KERNEL_VER).kp

$(BLD)/$(KERNEL_VER):
	mkdir -p $@/_kp_tmp/boot $@/_kp_tmp/lib
	cp ../kernel/kernel-$(T)-$(KFLAV)/vmlinuz-$(KVER) $@/_kp_tmp/boot
	cp ../kernel/kernel-$(T)-$(KFLAV)/System.map-$(KVER) $@/_kp_tmp/boot
	cp ../kernel/kernel-$(T)-$(KFLAV)/initrd-$(KVER).gz $@/_kp_tmp/boot
	cp -r ../kernel/$(BLD)/linux-*-$(T)-$(KFLAV)/modules/* $@/_kp_tmp
	rm -f $@/_kp_tmp/lib/modules/*/build $@/_kp_tmp/lib/modules/*/source
