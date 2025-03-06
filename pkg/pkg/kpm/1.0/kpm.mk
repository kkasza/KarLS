KPM_VER_CUR:=1.0
KPM_VER:=kpm-$(KPM_VER_CUR)

PKG_LIST+=kpm

kpm: $(BLD)/$(KPM_VER)-$(T).kp

$(BLD)/$(KPM_VER):
	$(call pkg_set_stat,"package $@")
	mkdir -p $@/_kp_tmp/FILES/bin
	cp pkg/kpm/$(KPM_VER_CUR)/kpm $@/_kp_tmp/FILES/bin
	chmod 755 $@/_kp_tmp/FILES/bin/kpm
	echo "$(KPM_VER) : KarLS Package Manager" > $@/_kp_tmp/DESC
	touch $@/_kp_tmp/ESSENTIAL
