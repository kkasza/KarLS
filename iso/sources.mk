ifeq ($(T),x86_64)
SYSLIN_VER:=syslinux-6.03
$(SYSLIN_VER)-URL:=https://cdn.kernel.org/pub/linux/utils/boot/syslinux
$(SYSLIN_VER)-FILE:=$(SYSLIN_VER).tar.xz
$(SYSLIN_VER)-SHA256:=26d3986d2bea109d5dc0e4f8c4822a459276cf021125e8c9f23c3cca5d8c850e

SRC_LIST:=SYSLIN
endif
