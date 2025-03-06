#KarLS
#Compiler infrastructure

include ../common.mk sources.mk

CMPL_VER:=1.0
CMPL_INST:=$(PWD)/cmpl-$(T)

STRIP:=$(CMPL_INST)/bin/$(TARGET-ARCH)-strip -d --strip-unneeded

BINU_OPTS:=--target=$(TARGET-ARCH) \
--with-pkgversion=$(NAME)-cmpl_$(CMPL_VER) \
--disable-nls \
--disable-werror \
--disable-multilib \
--with-sysroot=$(CMPL_INST) \
--prefix=$(CMPL_INST)

GCC_OPTS:=--target=$(TARGET-ARCH) \
--with-pkgversion=$(NAME)-cmpl_$(CMPL_VER) \
--enable-languages=c,c++ \
--enable-default-pic \
--enable-default-pie \
--disable-nls \
--disable-werror \
--disable-multilib \
--disable-libquadmath \
--disable-decimal-float \
--enable-tls \
--disable-libmudflap \
--disable-libsanitizer \
--disable-libmpx \
--enable-deterministic-archives \
--enable-libstdcxx-time \
--with-sysroot=$(CMPL_INST) \
--with-build-sysroot=$(CMPL_INST) \
--prefix=$(CMPL_INST) \
AR_FOR_TARGET=$(PWD)/$(BLD)/$(BINU_VER)/binutils/ar \
AS_FOR_TARGET=$(PWD)/$(BLD)/$(BINU_VER)/gas/as-new \
LD_FOR_TARGET=$(PWD)/$(BLD)/$(BINU_VER)/ld/ld-new \
NM_FOR_TARGET=$(PWD)/$(BLD)/$(BINU_VER)/binutils/nm-new \
OBJCOPY_FOR_TARGET=$(PWD)/$(BLD)/$(BINU_VER)/binutils/objcopy \
OBJDUMP_FOR_TARGET=$(PWD)/$(BLD)/$(BINU_VER)/binutils/objdump \
RANLIB_FOR_TARGET=$(PWD)/$(BLD)/$(BINU_VER)/binutils/ranlib \
READELF_FOR_TARGET=$(PWD)/$(BLD)/$(BINU_VER)/binutils/readelf \
STRIP_FOR_TARGET=$(PWD)/$(BLD)/$(BINU_VER)/binutils/strip-new

#--disable-gnu-indirect-function \

MUSL_OPTS:=--target=$(TARGET-ARCH) --disable-gcc-wrapper --enable-optimize --prefix=$(CMPL_INST) \
CC="../$(GCC_VER)/gcc/xgcc -B ../$(GCC_VER)/gcc" \
LIBCC="../$(GCC_VER)/$(TARGET-ARCH)/libgcc/libgcc.a"

MUSL_BINU:=AR="../$(BINU_VER)/binutils/ar" \
RANLIB="../$(BINU_VER)/binutils/ranlib"

binutils: $(BLD)/$(BINU_VER)

$(BLD)/$(BINU_VER): src/$(BINU_VER)
	$(call set_stat,"[1/11] configure $@")
	mkdir -p $@
	cd $@; $(CCACHE) ../../src/$(BINU_VER)/configure $(BINU_OPTS)
	$(call set_stat,"[2/11] compile $@")
	$(MAKE) -C $@ all
	$(MAKE) -C $@ install-strip

linux-headers: $(BLD)/$(LINUX_VER)

$(BLD)/$(LINUX_VER): | src/$(LINUX_VER)
	$(call set_stat,"[3/11] configure $@")
	make -C src/$(LINUX_VER) V=1 O=$(PWD)/$@ $(CCACHE) defconfig
	[ -d $(CMPL_INST)/usr/include/linux ] || $(MAKE) -C $(BLD)/$(LINUX_VER) V=1 O=$(PWD)/$@ INSTALL_HDR_PATH=$(CMPL_INST)/usr $(CCACHE) headers_install

xgcc: $(BLD)/$(GCC_VER)/gcc/xgcc

$(BLD)/$(GCC_VER)/gcc/xgcc: | $(BLD)/$(BINU_VER) $(BLD)/$(LINUX_VER) src/$(GCC_VER) src/$(GMP_VER) src/$(MPFR_VER) src/$(MPC_VER)
	$(call set_stat,"[4/11] configure $@")
	ln -sf ../$(GMP_VER) src/$(GCC_VER)/gmp
	ln -sf ../$(MPFR_VER) src/$(GCC_VER)/mpfr
	ln -sf ../$(MPC_VER) src/$(GCC_VER)/mpc
	mkdir -p $(BLD)/$(GCC_VER)
	cd $(BLD)/$(GCC_VER); $(CCACHE) ../../src/$(GCC_VER)/configure $(GCC_OPTS)
	$(call set_stat,"[5/11] compile $@")
	$(MAKE) -C $(BLD)/$(GCC_VER) all-gcc
	touch $@

$(BLD)/$(MUSL_VER)/Makefile: | $(BLD)/$(GCC_VER)/gcc/xgcc src/$(MUSL_VER)
	$(call set_stat,"[6/11] configure $@")
	mkdir -p $(BLD)/$(MUSL_VER)
	cd $(BLD)/$(MUSL_VER); $(CCACHE) ../../src/$(MUSL_VER)/configure $(MUSL_OPTS)
	$(call set_stat,"[7/11 ]compile $@")
	$(MAKE) -C $(BLD)/$(MUSL_VER) install-headers
	ln -sf ../include $(CMPL_INST)/$(TARGET-ARCH)/
	touch $@

$(BLD)/$(GCC_VER)/$(TARGET-ARCH)/libgcc/libgcc.a: | $(BLD)/$(MUSL_VER)/Makefile
	$(call set_stat,"[8/11] compile $@")
	$(MAKE) -C $(BLD)/$(GCC_VER) enable_shared=no all-target-libgcc
	touch $@

musl: $(BLD)/$(MUSL_VER)/lib/libc.so

$(BLD)/$(MUSL_VER)/lib/libc.so: | $(BLD)/$(GCC_VER)/$(TARGET-ARCH)/libgcc/libgcc.a
	$(call set_stat,"[9/11] compile $@")
	$(MAKE) -C $(BLD)/$(MUSL_VER) $(MUSL_BINU)
	$(MAKE) -C $(BLD)/$(MUSL_VER) install
	ln -sf libc.so $(CMPL_INST)/lib/ld-musl-$(TARGET-CPU).so.1
	touch $@

gcc: $(BLD)/$(GCC_VER)/$(TARGET-ARCH)/libgcc/ligcc_s.so

$(BLD)/$(GCC_VER)/$(TARGET-ARCH)/libgcc/ligcc_s.so: | $(BLD)/$(MUSL_VER)/lib/libc.so
	$(call set_stat,"[10/11] compile $@")
	$(MAKE) -C $(BLD)/$(GCC_VER)/$(TARGET-ARCH)/libgcc enable_shared=yes
	$(MAKE) -C $(BLD)/$(GCC_VER) enable_shared=yes
	$(MAKE) -C $(BLD)/$(GCC_VER) install-strip
	cp $(BLD)/$(GCC_VER)/gcc/libgcc_* $(CMPL_INST)/lib/

#extra headers added to cmpl include here (required by wpa_supplicant and possibly others)
	cp $(BLD)/$(BINU_VER)/bfd/bfd.h $(CMPL_INST)/include/
	cp src/$(BINU_VER)/include/*.h $(CMPL_INST)/include/
	cp src/$(GCC_VER)/include/*.h $(CMPL_INST)/include/

	find $(CMPL_INST) -type f | xargs file | grep ELF | grep "not stripped" | cut -d":" -f1 | xargs $(STRIP)

	for I in `ls $(CMPL_INST)/bin`; do \
		LN=`echo $$I | cut -d'-' -f5-` ; \
		ln -sf $$I $(CMPL_INST)/bin/$$LN; \
	done
	cd dl && ls -1 > $(CMPL_INST)/versions
	touch $@

dl/cmpl-$(TARGET-ARCH).txz: $(BLD)/$(GCC_VER)/$(TARGET-ARCH)/libgcc/ligcc_s.so
ifdef DBG_NOCMPLARC
	touch $@
else
	$(call set_stat,"[11/11] compress $@")
	tar -C $(CMPL_INST) -cJv -f $@ .
endif

cmpl: | dl/cmpl-$(TARGET-ARCH).txz
	$(call set_stat,"done")

reset_cmpl:
	@if [ -e dl/cmpl-$(TARGET-ARCH).txz ]; then \
		rm -rf $(CMPL_INST); \
		mkdir -p $(CMPL_INST); \
		tar -C $(CMPL_INST) -xJv -f dl/cmpl-$(TARGET-ARCH).txz; \
		touch $(CMPL_INST); \
	else \
		echo "build cmpl first"; \
	fi

_local_clean:
	@for I in $(VALID_T); do \
		echo rm -rf $(PWD)/cmpl-$$I; \
		rm -rf $(PWD)/cmpl-$$I; \
	done
