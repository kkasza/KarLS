ifeq ($(T),x86_64)
SYSLIN_VER:=syslinux-6.03
$(SYSLIN_VER)-URL:=https://cdn.kernel.org/pub/linux/utils/boot/syslinux
$(SYSLIN_VER)-FILE:=$(SYSLIN_VER).tar.xz
$(SYSLIN_VER)-SHA256:=26d3986d2bea109d5dc0e4f8c4822a459276cf021125e8c9f23c3cca5d8c850e

GRUB_VER:=grub-2.12
$(GRUB_VER)-URL:=https://ftp.gnu.org/gnu/grub
$(GRUB_VER)-FILE:=$(GRUB_VER).tar.xz
$(GRUB_VER)-SHA256:=f3c97391f7c4eaa677a78e090c7e97e6dc47b16f655f04683ebd37bef7fe0faa

SRC_LIST:=SYSLIN GRUB
endif
