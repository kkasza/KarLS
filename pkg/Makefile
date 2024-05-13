#KarLS
#Build packages

include ../common.mk

CMPL:=$(PWD)/../cmpl
CMPL_INST:=$(CMPL)/cmpl-$(T)

#Setup HOST and CROSS compilers with or without ccache
ifdef DBG_NOCC
HCCACHE:=HOSTCC="gcc" HOSTCXX="g++"
XCCACHE:=CC="$(CMPL_INST)/bin/gcc" CXX="$(CMPL_INST)/bin/g++"
else
HCCACHE:=HOSTCC="ccache gcc" HOSTCXX="ccache g++"
XCCACHE:=CC="ccache $(CMPL_INST)/bin/gcc" CXX="ccache $(CMPL_INST)/bin/g++"
endif

STRIP:=$(CMPL_INST)/bin/$(TARGET-ARCH)-strip -d --strip-unneeded

XPATH:=PATH=$(PATH):$(CMPL_INST)/bin
XPCF:=PKG_CONFIG_PATH=$(PWD)/$(BLD)/xpc

include pkg/*.mk
include pkg/*/*.mk

$(BLD)/%.kp: $(BLD)/$$*
	echo "KarLS Package Format 1.0" > $</_kp_tmp/KARLS_PACKAGE
	cd $</_kp_tmp/FILES; find . -type f,l,c,b > ../MANIFEST
	tar -C $</_kp_tmp -cJv -f $@ --owner=0 --group=0 .

pkg: | $(PKG_LIST)

#ifneq ($(T),x86_64)
#gcc libs
#	cp -rP $(CMPL_INST)/$(TARGET-ARCH)/lib/lib*.so* $@/lib/
#endif

#other libs
#	cp -rP $(BLD)/xlib/* $@/usr/lib
