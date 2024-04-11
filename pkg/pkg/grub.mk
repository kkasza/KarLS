GRUB_VER:=grub-2.12
$(GRUB_VER)-URL:=https://ftp.gnu.org/gnu/grub
$(GRUB_VER)-FILE:=$(GRUB_VER).tar.xz
$(GRUB_VER)-SHA256:=f3c97391f7c4eaa677a78e090c7e97e6dc47b16f655f04683ebd37bef7fe0faa

SRC_LIST+=GRUB
PKG_LIST+=grub grub-efi

GRUB_OPTS_PC:=--with-platform=pc

GRUB_OPTS_EFI:=--with-platform=efi

GRUB_OPTS:= \
--prefix=/usr \
--disable-efiemu \
--disable-mm-debug \
--disable-cache-stats \
--disable-boot-time \
--disable-grub-emu-sdl \
--disable-grub-emu-pci \
--disable-grub-mkfont \
--disable-grub-themes \
--disable-grub-mount \
--disable-device-mapper \
--disable-liblzma \
--disable-libzfs \
--host=$(TARGET-ARCH) \
$(XCCACHE) \
$(HCCACHE)

grub: $(BLD)/$(GRUB_VER).kp

grub-efi: $(BLD)/$(GRUB_VER)-efi.kp

$(BLD)/$(GRUB_VER): src/$(GRUB_VER)
	mkdir -p $@
	cd $@; $(XPATH) $(XPCF) ../../src/$(GRUB_VER)/configure $(GRUB_OPTS) $(GRUB_OPTS_PC)
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1 DESTDIR=`pwd`/$@/_kp_tmp install
	rm $@/_kp_tmp/usr/lib/grub/i386-pc/*.module $@/_kp_tmp/usr/lib/grub/i386-pc/*.image

$(BLD)/$(GRUB_VER)-efi: src/$(GRUB_VER)
	mkdir -p $@
	cd $@; $(XPATH) $(XPCF) ../../src/$(GRUB_VER)/configure $(GRUB_OPTS) $(GRUB_OPTS_EFI)
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1
	$(XPATH) $(MAKE) -C $@ $(XCCACHE) $(HCCACHE) KBUILD_VERBOSE=1 DESTDIR=`pwd`/$@/_kp_tmp install
	rm $@/_kp_tmp/usr/lib/grub/x86_64-efi/*.module
