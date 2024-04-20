MUSL_VER:=musl-1.2.5

PKG_LIST+=musl

musl: $(BLD)/$(MUSL_VER).kp

$(BLD)/$(MUSL_VER):
	mkdir -p $@/_kp_tmp/FILES/lib
	cp $(CMPL_INST)/lib/libc.so $@/_kp_tmp/FILES/lib
	ln -s libc.so $@/_kp_tmp/FILES/lib/ld-musl-$(T).so.1
	echo "$(MUSL_VER) : musl is an implementation of the C standard library built on top of the Linux system call API" > $@/_kp_tmp/DESC
	touch $@/_kp_tmp/ESSENTIAL
