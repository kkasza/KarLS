#KarLS
#Common infrastructure

#Used in different parts of compiled programs
NAME:=karls
NICENAME:=KarLS
VERSION=1.0
VERSION_TAG=Ardi

UTAR:=tar -xvaf
PWD:=$(shell pwd)

#Disable parellel building
ifndef DBG_MAKE
MAKE+=-j$$(( $(shell nproc) +1 ))
endif

#Valid Targets - Architectures
VALID_T:=x86_64 arm
#Valid platforms per target
VALID_P_x86_64:=iso
VALID_P_arm:=rpi

#Default target
T?=$(firstword $(VALID_T))
TARGET-CPU:=$(T)

#Default platform for selected Target
P?=$(firstword $(VALID_P_$(T)))

ifeq ($(T),x86_64)
TARGET-ARCH:=$(TARGET-CPU)-$(NAME)-linux-musl
endif

ifeq ($(T),arm)
TARGET-ARCH:=$(TARGET-CPU)-$(NAME)-linux-musleabihf
endif

ifneq ($(T),$(filter $(T),$(VALID_T)))
$(error *** Target $(T) is not valid. Valid targets are: $(VALID_T) ***)
endif

ifneq ($(P),$(filter $(P),$(VALID_P_$(T))))
$(error *** Platform $(P) for target $(T) is not valid. Valid platforms for this target are: $(VALID_P_$(T)) ***)
endif

#Setup CCACHE
export CCACHE_DIR=$(PWD)/.ccache-$(T)
export CCACHE_MAXSIZE=10G

ifdef DBG_NOCC
CCACHE:=CC="gcc" CXX="g++"
else
CCACHE:=CC="ccache gcc" CXX="ccache g++"
endif

ifdef DBG_CCLOG
export CCACHE_LOGFILE=$(CCACHE_DIR)/debug_log
endif

#Test if ran as root (Should NOT)
ifneq ($(shell id -u),0)
SUDO:=sudo
else
$(error *** this Makefile should not be run as root *** )
endif

#Test if SUDO can be ran (Should be)
ifneq ($(shell $(SUDO) id -u),0)
$(error *** cannot get root access ***)
endif

BLD:=build-$(TARGET-CPU)

ifeq ($(P),rpi)
KFLAV:=$(P)
else
KFLAV:=generic
endif

#Dependencies on Debian build system
MYDEPS:=sudo wget tar rsync xz-utils bzip2 \
gcc g++ \
gawk bison bc sed flex texinfo \
libtool m4 pkg-config \
autotools-dev automake \
libncurses5-dev \
uuid-dev libelf-dev \
squashfs-tools lz4 \
libssl-dev mtools \
xorriso python3

MYDEPS_NATIVE:=ccache qemu-system-x86 qemu-system-arm

PHONY:="default install_deps _local_clean clean distclean download sha256sum genpatch"

#Test for debian
PLAT_DEB:=0
ifneq (,$(wildcard /etc/debian_version))
PLAT_DEB:=1
$(info *** Debian Linux found ***)
ifeq (,$(filter $(PHONY) , $(MAKECMDGOALS)))
ifneq ($(shell dpkg -l $(MYDEPS) >> /dev/null && echo 0),0)
$(error *** Dependencies not found, please run make install_deps ***)
endif
ifeq (,$(wildcard /.dockerenv))
ifneq ($(shell dpkg -l $(MYDEPS_NATIVE) >> /dev/null && echo 0),0)
$(error *** Dependencies not found, please run make install_deps ***)
endif
endif
endif
else
$(info *** Unsupported Linux found, dependency check should be done manually ***)
endif

define set_stat
	@echo $1 >> .status
	@echo --------------------
	@echo -- $1
	@echo --------------------
endef

.PHONY: $(PHONY)

#Status screen / component
default:
	@echo ==================================================================================================
	@echo TARGET-ARCH: $(TARGET-ARCH)
	@echo Platform: $(P)
	@echo Possible targets: $(VALID_T) - default: $(firstword $(VALID_T)) - use make T=\<target\> to choose
	@echo Possible platforms for $(T): $(VALID_P_$(T)) - default: $(firstword $(VALID_P_$(T))) - use make T=\<target\> P=\<platform\> to choose
	@echo Possible debug parameters: DBG_MAKE DBG_CCLOG DBG_NOCC DBG_NOCMPLARC
	@echo MAKE: $(MAKE)
ifdef DBG_MAKE
	@echo DEBUG enabled - no make -j*
endif
ifdef DBG_CCLOG
	@echo DEBUG enabled - ccache log: $(CCACHE_LOGFILE)
endif
ifdef DBG_NOCC
	@echo DEBUG enabled - no ccache
endif
ifdef DBG_NOCMPLARC
	@echo DEBUG enabled - no cmpl archive shall be made
endif
ifndef CALLEDFROMROOT
	@echo ==================================================================================================
	@ccache -s
else
	@echo ==================================================================================================
#	@echo -n "Current Kernel build number: #"
#	@cat kernel/buildno-$(T)-$(P)
#	@echo -n "Current Kernel build date  : "
#	@ls -al kernel/buildno-$(T)-$(P) | tr -s [:blank:] | cut -d' ' -f6-8

#	@echo -n "Current $(NICENAME) build number  : #"
#	@cat osimg/buildno-$(T)
#	@echo -n "Current $(NICENAME) build date    : "
#	@ls -al osimg/buildno-$(T) | tr -s [:blank:] | cut -d' ' -f6-8
endif

ifeq ($(PLAT_DEB),1)
#Install DEBIAN dependencies
install_deps:
	$(call set_stat,"install deps")
	$(SUDO) apt-get update
	$(SUDO) apt-get -y upgrade
	$(SUDO) apt-get -y install $(MYDEPS)
ifeq (,$(wildcard /.dockerenv))
	$(SUDO) apt-get -y install $(MYDEPS_NATIVE)
endif
	$(SUDO) apt-get clean
endif

WGET:=wget --no-verbose --show-progress -P

#Precious downloaded targets
.PRECIOUS: dl/%.tar.gz dl/%.tar.bz2 dl/%.tar.xz

#Default download (And sha256sum) action for files defined in local sources.mk includes
dl/%.tar.gz dl/%.tar.xz dl/%.tar.bz2:
	$(call set_stat,"download $@")
	$(if $($*-REALFILE),\
	$(WGET) dl $($*-URL)/$($*-REALFILE) && mv dl/$($*-REALFILE) dl/$($*-FILE),\
	$(WGET) dl $($*-URL)/$($*-FILE))
	echo "$($*-SHA256)  dl/$($*-FILE)" | sha256sum -c || { echo sha256sum failed for $($*-FILE); exit 1; };

.SECONDEXPANSION:

#Uncompressed source directories (patching is also done here)
src/%: dl/$$($$*-FILE)
	$(call set_stat,"extract $@")
	mkdir -p src
	$(UTAR) dl/$($*-FILE) -C src

	$(if $($*-REALDIR),mv src/$($*-REALDIR) src/$*)

	for I in `ls patch/$(*)-*.patch 2>/dev/null`; do \
		patch -d src -p1 -i ../$$I ; \
	done

	touch $@

#PPKG: Package name - from sources.mk - to patch
PPKG?=nonexistent_PPKG_variable
#PTCNAME: Patch name in file
PTCNAME?=temp
#if PTCCOMMENT is also defined, added to patch as comment

#Patch generation
genpatch:
	[ -d src/$(PPKG) ] || { echo $(PPKG) not found in src!; exit 1; }
	mkdir -p src/$(PPKG).orig patch
	$(UTAR) dl/$(PPKG).t* -C src/$(PPKG).orig
	$(if $($(PPKG)-REALDIR),mv src/$(PPKG).orig/$($(PPKG)-REALDIR) src/$(PPKG).orig/$(PPKG))
	echo $(PTCNAME) patch generated by $(NICENAME) Builder Infrastructure > patch/$(PPKG)-$(PTCNAME).patch
ifdef PTCCOMMENT
	echo $(PTCCOMMENT) >> patch/$(PPKG)-$(PTCNAME).patch
endif
	diff -ruN --no-dereference src/$(PPKG).orig/$(PPKG) src/$(PPKG) >> patch/$(PPKG)-$(PTCNAME).patch || true
	rm -rf src/$(PPKG).orig
	@echo =================================================
	@echo Generated patch PPKG=$(PPKG) - PTCNAME=$(PTCNAME) - PTCCOMMENT=$(PTCCOMMENT)

#Default clean action per component - _local_clean is in the component specific Makefile
clean: _local_clean
	@for I in $(VALID_T); do \
		echo rm -rf $(PWD)/build-$$I; \
		rm -rf $(PWD)/build-$$I; \
	done
	rm -rf .status

#Default distclean per component
distclean: clean
	rm -rf src

#also delete downloaded archives
mrproper: distclean
	@for I in $(VALID_T); do \
		echo rm -rf $(PWD)/.ccache-$$I; \
		rm -rf $(PWD)/.ccache-$$I; \
	done
	rm -rf dl

#Download everything
download:
	@$(foreach var,$(SRC_LIST),\
		make --no-print-directory dl/$($($(var)_VER)-FILE);)

#Download if needed and doublecheck with sha256sum everything
sha256sum: download
	@$(foreach var,$(SRC_LIST),\
		echo "$($($(var)_VER)-SHA256)  dl/$($($(var)_VER)-FILE)" | sha256sum -c || { echo sha256sum failed for $($($(var)_VER)-FILE);exit 1; }; )
