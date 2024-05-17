KARLS_BASE_VER:=karls_base-1.0

PKG_LIST+=karls_base

karls_base: $(BLD)/$(KARLS_BASE_VER)-$(T).kp

$(BLD)/$(KARLS_BASE_VER):
	mkdir -p $@/_kp_tmp/FILES
	echo "$(KARLS_BASE_VER) : This is a meta-package for installing the base system" > $@/_kp_tmp/DESC
	echo "rootskel-1.0" > $@/_kp_tmp/PREREQ
	echo "kpm-1.0" >> $@/_kp_tmp/PREREQ
#Initrd pulls busybox, which pulls musl
	echo "initrd-1.0" >> $@/_kp_tmp/PREREQ
	echo "util_linux" >> $@/_kp_tmp/PREREQ
	echo "e2fsprogs" >> $@/_kp_tmp/PREREQ
	echo "dropbear" >> $@/_kp_tmp/PREREQ
	echo "tzdata" >> $@/_kp_tmp/PREREQ
	echo "ca_certs" >> $@/_kp_tmp/PREREQ
	touch $@/_kp_tmp/ESSENTIAL
