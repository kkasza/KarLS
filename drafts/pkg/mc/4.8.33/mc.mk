### DRAFT - mc reguires glib, which requires meson

#MC_VER_CUR:=4.8.33
#MC_VER:=mc-$(MC_VER_CUR)
#$(MC_VER)-URL:=http://ftp.midnight-commander.org/
#$(MC_VER)-FILE:=$(MC_VER).tar.xz
#$(MC_VER)-SHA256:=cae149d42f844e5185d8c81d7db3913a8fa214c65f852200a9d896b468af164c

#SRC_LIST+=MC
#PKG_LIST+=mc

#MC_OPTS:=--prefix=$(CMPL_INST) \
#--host=$(TARGET-ARCH) \
#--disable-doxygen-doc \
#$(XCCACHE) \
#$(HCCACHE)

#mc: $(BLD)/$(MC_VER)-$(T).kp

#$(BLD)/$(MC_VER): src/$(MC_VER)
#	mkdir -p $@/_kp_tmp/FILES/
#	cd $@; $(XPATH) $(XPCF) ../../src/$(MC_VER)/configure $(MC_OPTS)
