LIBEXECINFO_VER_CUR:=20180201
LIBEXECINFO_VER:=libexecinfo-$(LIBEXECINFO_VER_CUR)
$(LIBEXECINFO_VER)-URL:=https://github.com/resslinux/libexecinfo/archive/refs/tags
$(LIBEXECINFO_VER)-REALFILE:=v20180201.tar.gz
$(LIBEXECINFO_VER)-FILE:=$(LIBEXECINFO_VER).tar.gz
$(LIBEXECINFO_VER)-SHA256:=93b00d29e42d76b621e4c316e08b08001f2c70267be8f062359c12da813888b0

SRC_LIST+=LIBEXECINFO
PKG_LIST+=libexecinfo

libexecinfo: $(BLD)/$(LIBEXECINFO_VER)-$(T).kp

$(BLD)/$(LIBEXECINFO_VER): src/$(LIBEXECINFO_VER)
	mkdir -p $@/_kp_tmp/FILES/usr/lib $(BLD)/xpc

	cp -r src/$(LIBEXECINFO_VER) $(BLD)
	$(XPATH) $(XPCF) $(XCCACHE) $(HCCACHE) $(MAKE) -C $@ V=1
	$(STRIP) $@/libexecinfo.so.1

	cp -rP $@/execinfo.h $(CMPL_INST)/include
	cp -P $@/libexecinfo.so.1 $(CMPL_INST)/lib

	cp -P $@/libexecinfo.so.1 $@/_kp_tmp/FILES/usr/lib
	echo "$(LIBEXECINFO_VER) : A quick-n-dirty BSD licensed clone of the GNU libc backtrace facility." > $@/_kp_tmp/DESC
