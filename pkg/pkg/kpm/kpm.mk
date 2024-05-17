KPM_VER:=kpm-1.0

PKG_LIST+=kpm

kpm: $(BLD)/$(KPM_VER)-$(T).kp

$(BLD)/$(KPM_VER):
	mkdir -p $@/_kp_tmp/FILES/bin
	cp pkg/kpm/kpm $@/_kp_tmp/FILES/bin
	chmod 755 $@/_kp_tmp/FILES/bin/kpm
	echo "$(KPM_VER) : KarLS Package Manager" > $@/_kp_tmp/DESC
	touch $@/_kp_tmp/ESSENTIAL
