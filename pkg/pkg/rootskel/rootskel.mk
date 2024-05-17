ROOTSKEL_VER:=rootskel-1.0

PKG_LIST+=rootskel

rootskel: $(BLD)/$(ROOTSKEL_VER)-$(T).kp

$(BLD)/$(ROOTSKEL_VER):
	mkdir -p $@/_kp_tmp/FILES
	cp -r pkg/rootskel/rootskel/* $@/_kp_tmp/FILES
	echo $(NICENAME) $(VERSION) $(VERSION_TAG) > $@/_kp_tmp/FILES/etc/version
	printf '%s\n\n' '$(NICENAME) $(VERSION) $(VERSION_TAG) \n \l' > $@/_kp_tmp/FILES/etc/issue
	cd $@/_kp_tmp/FILES; mkdir -p \
	dev \
	proc \
	sys \
	var/run \
	var/lock \
	var/log \
	var/tmp \
	var/spool/cron/crontabs \
	tmp \
	home \
	root
	echo "$(ROOTSKEL_VER) : KarLS root FS skeleton" > $@/_kp_tmp/DESC
	cp pkg/rootskel/INSTALL $@/_kp_tmp
	touch $@/_kp_tmp/ESSENTIAL
