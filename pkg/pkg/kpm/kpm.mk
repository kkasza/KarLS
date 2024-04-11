KPM_VER:=kpm-1.0

PKG_LIST+=kpm

kpm: $(BLD)/$(KPM_VER).kp

$(BLD)/$(KPM_VER):
	mkdir -p $@/_kp_tmp/bin
	cp pkg/kpm/kpm $@/_kp_tmp/bin
	chmod 755 $@/_kp_tmp/bin/kpm
