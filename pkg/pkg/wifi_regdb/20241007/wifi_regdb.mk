WIFI_REGDB_VER_CUR:=20241007
WIFI_REGDB_VER:=wifi_regdb-$(WIFI_REGDB_VER_CUR)
$(WIFI_REGDB_VER)-URL:=https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git/snapshot
$(WIFI_REGDB_VER)-FILE:=$(WIFI_REGDB_VER).tar.gz
$(WIFI_REGDB_VER)-REALFILE:=wireless-regdb-master-2024-10-07.tar.gz
$(WIFI_REGDB_VER)-REALDIR:=wireless-regdb-master-2024-10-07
$(WIFI_REGDB_VER)-SHA256:=e0b60c2947125ac81ef7818c5667ef93ef3a275c0e417cf36db6793a4c2ae415

SRC_LIST+=WIFI_REGDB
PKG_LIST+=wifi_regdb

wifi_regdb: $(BLD)/$(WIFI_REGDB_VER)-$(T).kp

$(BLD)/$(WIFI_REGDB_VER): src/$(WIFI_REGDB_VER)
	$(call pkg_set_stat,"package $@")
	mkdir -p $@/_kp_tmp/FILES
	cp $^/regulatory.db $^/regulatory.db.p7s $@
	cp $^/LICENSE $@/regulatory.db.LICENSE
	echo "$(WIFI_REGDB_VER) : Linux wifi regulatory database. This is a dummy package, the actual files are on the install iso." > $@/_kp_tmp/DESC
