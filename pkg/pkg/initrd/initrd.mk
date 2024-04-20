INITRD_VER:=initrd-1.0

PKG_LIST+=initrd

initrd: $(BLD)/$(INITRD_VER).kp

$(BLD)/$(INITRD_VER): | busybox
	mkdir -p $@/initrd-skel $@/_kp_tmp/FILES/usr/share/initrd $@/_kp_tmp/FILES/usr/sbin
	cp -r pkg/initrd/initrd-skel/* $@/initrd-skel

	cd $@/initrd-skel; mkdir -p \
	proc \
	dev \
	tmp \
	sys \
	lib/modules \
	usr/udhcpc \
	var/run \
	var/log \
	var/lock \
	var/tmp

#Static busybox from kernel initrd
	cp ../kernel/$(BLD)/$(BUSYBOX_VER)/busybox $@/initrd-skel/bin
	cp ../kernel/$(BLD)/$(BUSYBOX_VER)/examples/udhcp/simple.script $@/initrd-skel/usr/udhcpc/default.script

	$(SUDO) mknod -m 600 $@/initrd-skel/dev/console c 5 1
	echo $(NICENAME) $(VERSION) $(VERSION_TAG) > $@/initrd-skel/etc/version

	tar -C $@/initrd-skel -cJv -f $@/_kp_tmp/FILES/usr/share/initrd/initrd-skel.txz --owner=0 --group=0 .
	cp pkg/initrd/rebuild_initrd $@/_kp_tmp/FILES/usr/sbin
	chmod 755 $@/_kp_tmp/FILES/usr/sbin/rebuild_initrd

	echo "$(INITRD_VER) : Custom Initrd for the Kernel" > $@/_kp_tmp/DESC

	echo "#!/bin/sh" > $@/_kp_tmp/INSTALL
	echo "#KarLS INSTALL script for $(INITRD_VER)" >> $@/_kp_tmp/INSTALL
	echo "\$$1/usr/sbin/rebuild_initrd \$$1" >> $@/_kp_tmp/INSTALL
	echo "busybox-1.36.1" > $@/_kp_tmp/PREREQ
	touch $@/_kp_tmp/ESSENTIAL
