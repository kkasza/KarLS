KVER:=$(shell cat ../kernel/kernel-$(T)-$(KFLAV)/kernel_version)
KERNEL_VER:=kernel-$(KVER)

PKG_LIST+=kernel

kernel: $(BLD)/$(KERNEL_VER).kp

$(BLD)/$(KERNEL_VER):
	mkdir -p $@/_kp_tmp/FILES/boot $@/_kp_tmp/FILES/lib
	cp ../kernel/kernel-$(T)-$(KFLAV)/vmlinuz-$(KVER) $@/_kp_tmp/FILES/boot
	cp ../kernel/kernel-$(T)-$(KFLAV)/System.map-$(KVER) $@/_kp_tmp/FILES/boot
	cp -r ../kernel/$(BLD)/linux-*-$(T)-$(KFLAV)/modules/* $@/_kp_tmp/FILES
	rm -f $@/_kp_tmp/FILES/lib/modules/*/build $@/_kp_tmp/FILES/lib/modules/*/source
	echo "$(KERNEL_VER) : The LINUX Kernel" > $@/_kp_tmp/DESC
