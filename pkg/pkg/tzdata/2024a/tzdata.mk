TZ-VER:=2024a
TZ-URL:=https://data.iana.org/time-zones/releases

TZDATA_VER:=tzdata$(TZ-VER)
$(TZDATA_VER)-URL:=$(TZ-URL)
$(TZDATA_VER)-FILE:=$(TZDATA_VER).tar.gz
$(TZDATA_VER)-SHA256:=0d0434459acbd2059a7a8da1f3304a84a86591f6ed69c6248fffa502b6edffe3

TZCODE_VER:=tzcode$(TZ-VER)
$(TZCODE_VER)-URL:=$(TZ-URL)
$(TZCODE_VER)-FILE:=$(TZCODE_VER).tar.gz
$(TZCODE_VER)-SHA256:=80072894adff5a458f1d143e16e4ca1d8b2a122c9c5399da482cb68cba6a1ff8

SRC_LIST+=TZDATA TZCODE
PKG_LIST+=tzdata

tzdata: $(BLD)/tzdata-$(TZ-VER)-$(T).kp

src/tzdata-$(TZ-VER): | dl/$($(TZDATA_VER)-FILE) dl/$($(TZCODE_VER)-FILE)
	mkdir -p $@
	$(UTAR) dl/$($(TZDATA_VER)-FILE) -C $@
	$(UTAR) dl/$($(TZCODE_VER)-FILE) -C $@
	touch $@

ZICFLAGS:=ZFLAGS='-b fat'

$(BLD)/tzdata-$(TZ-VER): src/tzdata-$(TZ-VER)
	$(call pkg_set_stat,"package $@")
	cp -r $< $(BLD)
	$(MAKE) -C $@ $(HCCACHE) $(ZICFLAGS) DESTDIR=`pwd`/$@/install install
	mkdir -p $@/_kp_tmp/FILES/etc $@/_kp_tmp/FILES/usr/share
	cp -r $@/install/usr/share/zoneinfo $@/_kp_tmp/FILES/usr/share
	ln -s /usr/share/zoneinfo/Europe/Vienna $@/_kp_tmp/FILES/etc/localtime
	echo "tzdata-$(TZ-VER) : IANA Time Zone Database" > $@/_kp_tmp/DESC
