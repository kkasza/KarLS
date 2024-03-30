MUSL_VER:=musl-1.2.5

PKG_LIST+=musl

musl: $(BLD)/$(MUSL_VER).txz

$(BLD)/$(MUSL_VER):
	mkdir -p $@/lib
	cp $(CMPL_INST)/lib/libc.so $@/lib
	ln -s libc.so $@/lib/ld-musl-$(T).so.1

$(BLD)/$(MUSL_VER).txz: $(BLD)/$(MUSL_VER)
	tar -C $< -cJv -f $@ --owner=0 --group=0 .
