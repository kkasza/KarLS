INITRD_VER:=initrd-1.0

PKG_LIST+=initrd

initrd: $(BLD)/$(INITRD_VER).kp

$(BLD)/$(INITRD_VER): | busybox-static
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

	cp $(BLD)/$(BUSYBOX_VER)-static/busybox $@/initrd-skel/bin
	cp $(BLD)/$(BUSYBOX_VER)-static/examples/udhcp/simple.script $@/initrd-skel/usr/udhcpc/default.script

	$(SUDO) mknod -m 600 $@/initrd-skel/dev/console c 5 1
	echo $(NICENAME) $(VERSION) $(VERSION_TAG) > $@/initrd-skel/etc/version

	tar -C $@/initrd-skel -cJv -f $@/_kp_tmp/FILES/usr/share/initrd/initrd-skel.txz --owner=0 --group=0 .
	cp pkg/initrd/rebuild_initrd $@/_kp_tmp/FILES/usr/sbin
	chmod 755 $@/_kp_tmp/FILES/usr/sbin/rebuild_initrd

	echo "$(INITRD_VER) : Custom Initrd for the Kernel" > $@/_kp_tmp/DESC
	echo "busybox-1.36.1" > $@/_kp_tmp/PREREQ
	cp pkg/initrd/INSTALL $@/_kp_tmp
	touch $@/_kp_tmp/ESSENTIAL
