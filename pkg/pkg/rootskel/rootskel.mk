ROOTSKEL_VER:=rootskel-1.0

PKG_LIST+=rootskel

rootskel: $(BLD)/$(ROOTSKEL_VER).kp

$(BLD)/$(ROOTSKEL_VER):
	mkdir -p $@/_kp_tmp
	cp -r pkg/rootskel/rootskel/* $@/_kp_tmp
	echo $(NICENAME) $(VERSION) $(VERSION_TAG) > $@/_kp_tmp/etc/version
	mkdir -p \
	$@/_kp_tmp/dev \
	$@/_kp_tmp/proc \
	$@/_kp_tmp/sys \
	$@/_kp_tmp/var/run \
	$@/_kp_tmp/var/lock \
	$@/_kp_tmp/var/log \
	$@/_kp_tmp/tmp \
	$@/_kp_tmp/var/tmp \
	$@/_kp_tmp/root
