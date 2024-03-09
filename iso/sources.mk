ifeq ($(P),qemu)
SYSLIN_VER:=syslinux-6.03
$(SYSLIN_VER)-URL:=https://cdn.kernel.org/pub/linux/utils/boot/syslinux
$(SYSLIN_VER)-FILE:=$(SYSLIN_VER).tar.xz
$(SYSLIN_VER)-SHA256:=26d3986d2bea109d5dc0e4f8c4822a459276cf021125e8c9f23c3cca5d8c850e

SRC_LIST:=SYSLIN
endif

#ifeq ($(P),rpi)
#RPIFW_VER:=rpifw-220916
#$(RPIFW_VER)-URL:=https://github.com/raspberrypi/firmware/archive
#$(RPIFW_VER)-REALFILE:=93c576380c7bb20a6177f3163f01bc84445cc0e1.tar.gz
#$(RPIFW_VER)-FILE:=$(RPIFW_VER).tar.gz
#$(RPIFW_VER)-REALDIR:=firmware-93c576380c7bb20a6177f3163f01bc84445cc0e1
#$(RPIFW_VER)-SHA256:=c535b73a4d9e68b696a1ea58ef6dfbd4fc67f00a0232bcc86952622fd45e8b36

#SRC_LIST:=RPIFW
#endif
