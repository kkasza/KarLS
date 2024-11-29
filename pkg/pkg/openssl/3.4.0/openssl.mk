OPENSSL_VER_CUR:=3.4.0
OPENSSL_VER:=openssl-$(OPENSSL_VER_CUR)
$(OPENSSL_VER)-URL:=https://www.openssl.org/source
$(OPENSSL_VER)-FILE:=$(OPENSSL_VER).tar.gz
$(OPENSSL_VER)-SHA256:=e15dda82fe2fe8139dc2ac21a36d4ca01d5313c75f99f46c4e8a27709b7294bf

SRC_LIST+=OPENSSL
PKG_LIST+=openssl

OPENSSL_OPTS:=--prefix=$(CMPL_INST) \
--libdir=lib \
$(XCCACHE) \
$(HCCACHE)

openssl: $(BLD)/$(OPENSSL_VER)-$(T).kp

ifeq ($(T),x86_64)
OPENSSL_TARGET:=linux-x86_64
endif

ifeq ($(T),arm)
OPENSSL_TARGET:=linux-armv4
endif

$(BLD)/$(OPENSSL_VER): src/$(OPENSSL_VER)
	mkdir -p $@/_kp_tmp/FILES/usr/bin $@/_kp_tmp/FILES/usr/lib $(BLD)/xpc

	cd $@; $(XPATH) $(XPCF) ../../src/$(OPENSSL_VER)/Configure $(OPENSSL_TARGET) $(OPENSSL_OPTS)
	$(XPATH) $(MAKE) -C $@ V=1
	cp -rP src/$(OPENSSL_VER)/include/openssl $@/include/openssl src/$(OPENSSL_VER)/include/crypto $@/include/crypto $(CMPL_INST)/include/
	$(STRIP) $@/apps/openssl $@/*.so*
	cp -P $@/*.so* $(CMPL_INST)/lib
	cp $@/*.pc $(BLD)/xpc

	cp -P $@/*.so* $@/_kp_tmp/FILES/usr/lib
	cp -P $@/apps/openssl $@/_kp_tmp/FILES/usr/bin
	echo "$(OPENSSL_VER) : OpenSSL software library" > $@/_kp_tmp/DESC
	echo "busybox" > $@/_kp_tmp/PREREQ
