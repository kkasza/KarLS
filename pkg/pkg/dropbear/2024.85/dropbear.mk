DROPBEAR_VER_CUR:=2024.85
DROPBEAR_VER:=dropbear-$(DROPBEAR_VER_CUR)
$(DROPBEAR_VER)-URL:=https://matt.ucc.asn.au/dropbear/releases
$(DROPBEAR_VER)-FILE:=$(DROPBEAR_VER).tar.bz2
$(DROPBEAR_VER)-SHA256:=86b036c433a69d89ce51ebae335d65c47738ccf90d13e5eb0fea832e556da502

SRC_LIST+=DROPBEAR
PKG_LIST+=dropbear

DROPBEAR_OPTS:=--host=$(TARGET-ARCH) \
--disable-utmp \
--disable-utmpx \
--disable-wtmp \
--disable-wtmpx \
--disable-lastlog \
--disable-zlib \
$(XCCACHE) \
$(HCCACHE) \
AR=$(CMPL_INST)/bin/$(TARGET-ARCH)-ar \
RANLIB=$(CMPL_INST)/bin/$(TARGET-ARCH)-ranlib

DROPBEAR_CFLAGS:=CFLAGS="-DINETD_MODE=0 \
-DDROPBEAR_SMALL_CODE=0 \
-DDROPBEAR_X11FWD=0 \
-DDO_MOTD=1"

DROPBEAR_PROGS:=dropbear dbclient ssh dropbearkey dropbearconvert scp

DROPBEAR_MAKE_OPTS:=MULTI=1 PROGRAMS="$(DROPBEAR_PROGS)"

dropbear: $(BLD)/$(DROPBEAR_VER)-$(T).kp

$(BLD)/$(DROPBEAR_VER): src/$(DROPBEAR_VER)
	$(call pkg_set_stat,"configure $@")
	mkdir -p $@/_kp_tmp/FILES/usr/bin $@/_kp_tmp/FILES/etc/dropbear
	cd $@; $(XPATH) $(XPCF) ../../src/$(DROPBEAR_VER)/configure $(DROPBEAR_OPTS)
	$(call pkg_set_stat,"compile $@")
	$(XPATH) $(DROPBEAR_CFLAGS) $(MAKE) -C $@ $(DROPBEAR_MAKE_OPTS)
	$(call pkg_set_stat,"package $@")
	$(STRIP) $@/dropbearmulti
	cp $@/dropbearmulti $@/_kp_tmp/FILES/usr/bin
	for PRG in $(DROPBEAR_PROGS); do \
	ln -s dropbearmulti $@/_kp_tmp/FILES/usr/bin/$$PRG; \
	done
	cp -r pkg/dropbear/$(DROPBEAR_VER_CUR)/skel/* $@/_kp_tmp/FILES
	echo "$(DROPBEAR_VER) : Dropbear is a relatively small SSH server and client." > $@/_kp_tmp/DESC
	echo "busybox" > $@/_kp_tmp/PREREQ
