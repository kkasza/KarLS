IW_VER_CUR:=6.9
IW_VER:=iw-$(IW_VER_CUR)
$(IW_VER)-URL:=https://mirrors.edge.kernel.org/pub/software/network/iw
$(IW_VER)-FILE:=$(IW_VER).tar.xz
$(IW_VER)-SHA256:=3f2db22ad41c675242b98ae3942dbf3112548c60a42ff739210f2de4e98e4894

SRC_LIST+=IW
PKG_LIST+=iw

iw: $(BLD)/$(IW_VER)-$(T).kp

$(BLD)/$(IW_VER): | src/$(IW_VER) libnl
	$(call pkg_set_stat,"compile $@")
	mkdir -p $@/_kp_tmp/FILES/usr/bin
	cp -r src/$(IW_VER) $(BLD)
	$(XPATH) $(XPCF) $(XCCACHE) $(HCCACHE) $(MAKE) -C $@ V=1
	$(call pkg_set_stat,"package $@")
	$(STRIP) $@/iw
	cp $@/iw $@/_kp_tmp/FILES/usr/bin
	cp -r pkg/iw/$(IW_VER_CUR)/skel/* $@/_kp_tmp/FILES
	echo "busybox" > $@/_kp_tmp/PREREQ
	echo "libnl" >> $@/_kp_tmp/PREREQ
	echo "$(IW_VER) : iw is a new nl80211 based CLI configuration utility for wireless devices." > $@/_kp_tmp/DESC
