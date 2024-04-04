ROOTSKEL_VER:=rootskel-1.0

PKG_LIST+=rootskel

rootskel: $(BLD)/$(ROOTSKEL_VER).kp

$(BLD)/$(ROOTSKEL_VER):
	mkdir -p $@
	cp -r pkg/rootskel/* $@
	echo $(NICENAME) $(VERSION) $(VERSION_TAG) > $@/etc/version
	mkdir -p $@/dev $@/proc $@/sys $@/var/run $@/var/lock $@/var/log $@/tmp

$(BLD)/$(ROOTSKEL_VER).kp: $(BLD)/$(ROOTSKEL_VER)
	tar -C $< -cJv -f $@ --owner=0 --group=0 .
