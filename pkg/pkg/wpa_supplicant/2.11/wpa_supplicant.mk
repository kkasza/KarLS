WPASUP_VER_CUR:=2.11
WPASUP_VER:=wpa_supplicant-$(WPASUP_VER_CUR)
$(WPASUP_VER)-URL:=https://w1.fi/releases
$(WPASUP_VER)-FILE:=$(WPASUP_VER).tar.gz
$(WPASUP_VER)-SHA256:=912ea06f74e30a8e36fbb68064d6cdff218d8d591db0fc5d75dee6c81ac7fc0a

SRC_LIST+=WPASUP
PKG_LIST+=wpa_supplicant

wpa_supplicant: $(BLD)/$(WPASUP_VER)-$(T).kp

$(BLD)/$(WPASUP_VER): | src/$(WPASUP_VER) libnl libexecinfo libatomic iw openssl
	$(call pkg_set_stat,"compile $@")
	mkdir -p $@/_kp_tmp/FILES/usr/bin
	cp -r src/$(WPASUP_VER) $(BLD)/
	cp pkg/wpa_supplicant/$(WPASUP_VER_CUR)/wpa_supplicant.config $@/wpa_supplicant/.config
	$(XPATH) $(XPCF) $(XCCACHE) $(HCCACHE) $(MAKE) -C $@/wpa_supplicant V=1 LDFLAGS="-L$(CMPL_INST)/$(TARGET-ARCH)/lib -latomic"
	$(call pkg_set_stat,"package $@")
	$(STRIP) $@/wpa_supplicant/wpa_supplicant
	$(STRIP) $@/wpa_supplicant/wpa_cli
	$(STRIP) $@/wpa_supplicant/wpa_passphrase
	cp $@/wpa_supplicant/wpa_supplicant $@/_kp_tmp/FILES/usr/bin
	cp $@/wpa_supplicant/wpa_cli $@/_kp_tmp/FILES/usr/bin
	cp $@/wpa_supplicant/wpa_passphrase $@/_kp_tmp/FILES/usr/bin
	cp -r pkg/wpa_supplicant/$(WPASUP_VER_CUR)/skel/* $@/_kp_tmp/FILES
	echo "libnl" > $@/_kp_tmp/PREREQ
	echo "libexecinfo" >> $@/_kp_tmp/PREREQ
	echo "libatomic" >> $@/_kp_tmp/PREREQ
	echo "iw" >> $@/_kp_tmp/PREREQ
	echo "openssl" >> $@/_kp_tmp/PREREQ
	echo "$(WPASUP_VER) : user space IEEE 802.1X/WPA supplicant (wireless client)" > $@/_kp_tmp/DESC
