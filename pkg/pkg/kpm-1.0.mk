KPM_VER:=kpm-1.2.5

PKG_LIST+=kpm

kpm: $(BLD)/$(KPM_VER).kp

$(BLD)/$(KPM_VER):
	mkdir -p $@/bin
	cp pkg/kpm $@/bin
	chmod 755 $@/bin/kpm

$(BLD)/$(KPM_VER).kp: $(BLD)/$(KPM_VER)
	tar -C $< -cJv -f $@ --owner=0 --group=0 .
