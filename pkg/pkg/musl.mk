MUSL_VER:=musl-1.2.5

PKG_LIST+=musl

musl: $(BLD)/$(MUSL_VER).kp

$(BLD)/$(MUSL_VER):
	mkdir -p $@/_kp_tmp/lib
	cp $(CMPL_INST)/lib/libc.so $@/_kp_tmp/lib
	ln -s libc.so $@/_kp_tmp/lib/ld-musl-$(T).so.1
