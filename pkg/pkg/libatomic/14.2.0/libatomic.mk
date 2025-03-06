LIBATOMIC_VER_CUR:=14.2.0
LIBATOMIC_VER:=libatomic-$(LIBATOMIC_VER_CUR)

PKG_LIST+=libatomic

libatomic: $(BLD)/$(LIBATOMIC_VER)-$(T).kp

$(BLD)/$(LIBATOMIC_VER):
	$(call pkg_set_stat,"package $@")
	mkdir -p $@/_kp_tmp/FILES/usr/lib
	cp -P $(CMPL_INST)/$(TARGET-ARCH)/lib64/libatomic.so* $@/_kp_tmp/FILES/usr/lib
	echo "$(LIBATOMIC_VER) : Library providing __atomic built-in functions." > $@/_kp_tmp/DESC
