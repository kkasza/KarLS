LINUX_FW_VER_CUR:=20241110
LINUX_FW_VER:=linux_firmware-$(LINUX_FW_VER_CUR)
$(LINUX_FW_VER)-URL:=https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/snapshot/
$(LINUX_FW_VER)-FILE:=$(LINUX_FW_VER).tar.gz
$(LINUX_FW_VER)-REALFILE:=linux-firmware-$(LINUX_FW_VER_CUR).tar.gz
$(LINUX_FW_VER)-REALDIR:=linux-firmware-$(LINUX_FW_VER_CUR)
$(LINUX_FW_VER)-SHA256:=c8a561dfdbd54157692fe166b84a173f9bc01f89c78f6196863beea2450e4938

SRC_LIST+=LINUX_FW
PKG_LIST+=linux_firmware

linux_firmware: $(BLD)/$(LINUX_FW_VER)-$(T).kp

$(BLD)/$(LINUX_FW_VER): src/$(LINUX_FW_VER)
	$(call pkg_set_stat,"package $@")
	mkdir -p $@/_kp_tmp/FILES
	cp -r $^/amd* $^/i915 $^/intel $^/LICENCE.iwlwifi_firmware $^/LICENSE.amd* $^/LICENSE.i915 $^/iwlwifi-* $@/
	echo "$(LINUX_FW_VER) : Linux kernel firmware blobs, for Intel and AMD devices. This is a dummy package, the actual files are on the install iso." > $@/_kp_tmp/DESC
